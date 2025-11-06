import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'speech_recognition_service.dart';

class PlatformSpeechService implements SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _shouldKeepListening = false;
  bool _isRestarting = false;
  String _currentSegmentText = '';
  DateTime? _sessionStartTime;

  Function(String)? _onInterimResult;
  Function(String)? _onFinalResult;
  Function(String)? _onError;

  @override
  String get engineName => 'Platform Default (Google/Apple)';

  @override
  Future<bool> initialize() async {
    if (_isInitialized) {
      print('[SpeechService] Already initialized');
      return true;
    }

    print('[SpeechService] Initializing...');

    bool hasPermission = await _speech.hasPermission;
    print('[SpeechService] Has permission before init: $hasPermission');

    _isInitialized = await _speech.initialize(
      onError: (error) => print('[SpeechService] ERROR: $error'),
      onStatus: (status) {
        print('[SpeechService] Status: $status');

        if ((status == 'done' || status == 'notListening') &&
            _shouldKeepListening &&
            !_isRestarting) {
          // Check how long this session has been running
          final now = DateTime.now();
          final sessionDuration = _sessionStartTime != null
              ? now.difference(_sessionStartTime!)
              : Duration.zero;

          print(
            '[SpeechService] Session duration: ${sessionDuration.inSeconds}s',
          );

          // If session ran for close to browser's limit (~50-60 seconds),
          // this is likely an arbitrary timeout, not a real pause.
          // Otherwise, it's a real pause triggered by our pauseFor setting.
          final likelyArbitraryTimeout = sessionDuration.inSeconds > 45;

          if (_currentSegmentText.isNotEmpty) {
            if (likelyArbitraryTimeout) {
              print(
                '[SpeechService] Arbitrary timeout (${sessionDuration.inSeconds}s), keeping segment: "${_currentSegmentText.substring(0, 50)}..."',
              );
              // Don't finalize - will carry over to next session
            } else {
              print(
                '[SpeechService] Real pause detected (${sessionDuration.inSeconds}s), finalizing: "$_currentSegmentText"',
              );
              _onFinalResult?.call(_currentSegmentText);
              _currentSegmentText = '';
            }
          }

          print('[SpeechService] Restarting for continuous listening...');
          _restartListening();
        }
      },
    );

    print('[SpeechService] Initialized: $_isInitialized');
    return _isInitialized;
  }

  @override
  Future<bool> isAvailable() async {
    print('[SpeechService] Checking availability...');
    return await _speech.initialize();
  }

  @override
  Future<bool> startListening({
    required Function(String interimText) onInterimResult,
    required Function(String finalText) onFinalResult,
    required Function(String error) onError,
  }) async {
    _onInterimResult = onInterimResult;
    _onFinalResult = onFinalResult;
    _onError = onError;
    _shouldKeepListening = true;
    _currentSegmentText = '';
    _sessionStartTime = DateTime.now();

    if (!_isInitialized) {
      print('[SpeechService] Not initialized, initializing now...');
      final success = await initialize();
      if (!success) {
        _shouldKeepListening = false;
        onError(
          'Microphone permission is required. Please grant permission in your device settings.',
        );
        return false;
      }
    }

    print('[SpeechService] Starting to listen...');
    _sessionStartTime = DateTime.now();
    await _speech.listen(
      onResult: (result) {
        print(
          '[SpeechService] Result - Final: ${result.finalResult}, Text: "${result.recognizedWords}"',
        );

        if (result.finalResult) {
          // Browser gave us a definitive final result
          final finalText = _combineText(
            _currentSegmentText,
            result.recognizedWords,
          );
          onFinalResult(finalText);
          _currentSegmentText = '';
        } else {
          // Interim result - combine with any carried-over text
          _currentSegmentText = _combineText(
            _currentSegmentText,
            result.recognizedWords,
          );
          onInterimResult(_currentSegmentText);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
      listenFor: const Duration(hours: 24),
      pauseFor: const Duration(seconds: 2),
    );
    print('[SpeechService] Listen started');
    return true;
  }

  Future<void> _restartListening() async {
    if (!_shouldKeepListening || _isRestarting) {
      print('[SpeechService] Not restarting');
      return;
    }

    _isRestarting = true;

    // Store the current segment text to carry over
    final carryOverText = _currentSegmentText;

    await Future.delayed(const Duration(milliseconds: 100));

    if (!_shouldKeepListening) {
      print('[SpeechService] Cancelled during delay');
      _isRestarting = false;
      return;
    }

    print(
      '[SpeechService] Restarting listening... (carrying over: "${carryOverText.length} chars")',
    );
    _sessionStartTime = DateTime.now();
    await _speech.listen(
      onResult: (result) {
        print(
          '[SpeechService] Result - Final: ${result.finalResult}, Text: "${result.recognizedWords}"',
        );

        if (result.finalResult) {
          final finalText = _combineText(carryOverText, result.recognizedWords);
          _onFinalResult?.call(finalText);
          _currentSegmentText = '';
        } else {
          _currentSegmentText = _combineText(
            carryOverText,
            result.recognizedWords,
          );
          _onInterimResult?.call(_currentSegmentText);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
      listenFor: const Duration(hours: 24),
      pauseFor: const Duration(seconds: 2),
    );

    _isRestarting = false;
    print('[SpeechService] Restarted successfully');
  }

  /// Intelligently combine carried-over text with new text
  String _combineText(String existing, String newText) {
    if (existing.isEmpty) {
      return newText;
    }

    if (newText.isEmpty) {
      return existing;
    }

    // Check if newText already contains the existing text
    // (Web Speech API sometimes repeats previous results)
    if (newText.toLowerCase().startsWith(existing.toLowerCase())) {
      return newText;
    }

    // Check if there's overlap at the boundary
    final existingWords = existing.trim().split(' ');
    final newWords = newText.trim().split(' ');

    // Look for overlap (last few words of existing match first few words of new)
    int overlapLength = 0;
    for (int i = 1; i <= existingWords.length.clamp(0, 5); i++) {
      final lastWords = existingWords
          .sublist(existingWords.length - i)
          .join(' ')
          .toLowerCase();
      final firstWords = newWords
          .sublist(0, i.clamp(0, newWords.length))
          .join(' ')
          .toLowerCase();

      if (lastWords == firstWords) {
        overlapLength = i;
      }
    }

    if (overlapLength > 0) {
      // Remove the overlapping part from new text
      final uniqueNewWords = newWords.sublist(overlapLength);
      return '${existing.trim()} ${uniqueNewWords.join(' ')}';
    }

    // No overlap detected, just append with space
    return '${existing.trim()} ${newText.trim()}';
  }

  @override
  Future<void> stopListening() async {
    print('[SpeechService] Stopping...');
    _shouldKeepListening = false;
    _isRestarting = false;

    // Finalize any remaining text
    if (_currentSegmentText.isNotEmpty) {
      print(
        '[SpeechService] Finalizing remaining text on stop: "$_currentSegmentText"',
      );
      _onFinalResult?.call(_currentSegmentText);
      _currentSegmentText = '';
    }

    await _speech.stop();
    print('[SpeechService] Stopped');
  }

  @override
  Future<void> dispose() async {
    print('[SpeechService] Disposing...');
    await _speech.cancel();
    _isInitialized = false;
  }
}
