import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'speech_recognition_service.dart';

class PlatformSpeechService implements SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  @override
  String get engineName => 'Platform Default (Google/Apple)';

  @override
  Future<bool> initialize() async {
    if (_isInitialized) {
      print('[SpeechService] Already initialized');
      return true;
    }

    print('[SpeechService] Initializing...');

    // Check current permission status
    bool hasPermission = await _speech.hasPermission;
    print('[SpeechService] Has permission before init: $hasPermission');

    _isInitialized = await _speech.initialize(
      onError: (error) => print('[SpeechService] ERROR: $error'),
      onStatus: (status) => print('[SpeechService] Status: $status'),
    );

    print('[SpeechService] Initialized: $_isInitialized');
    return _isInitialized;
  }

  @override
  Future<bool> isAvailable() async {
    print('[SpeechService] Checking availability...');
    // Don't modify _isInitialized here, just check if it's possible
    return await _speech.initialize();
  }

  @override
  Future<bool> startListening({
    required Function(String interimText) onInterimResult,
    required Function(String finalText) onFinalResult,
    required Function(String error) onError,
  }) async {
    // Ensure initialized before listening
    if (!_isInitialized) {
      print('[SpeechService] Not initialized, initializing now...');
      final success = await initialize();
      if (!success) {
        onError(
          'Microphone permission is required. Please grant permission in your device settings.',
        );
        return false;
      }
    }

    print('[SpeechService] Starting to listen...');
    await _speech.listen(
      onResult: (result) {
        print(
          '[SpeechService] Result - Final: ${result.finalResult}, Text: "${result.recognizedWords}"',
        );
        if (result.finalResult) {
          onFinalResult(result.recognizedWords);
        } else {
          onInterimResult(result.recognizedWords);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
      listenFor: const Duration(hours: 3),
      pauseFor: const Duration(seconds: 3),
    );
    print('[SpeechService] Listen started');
    return true;
  }

  @override
  Future<void> stopListening() async {
    print('[SpeechService] Stopping...');
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
