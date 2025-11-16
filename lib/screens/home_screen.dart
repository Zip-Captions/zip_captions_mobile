import 'package:flutter/material.dart';
import '../widgets/recording/live_caption_display.dart';
import '../widgets/recording/finalized_segments_list.dart';
import '../services/speech/speech_recognition_service.dart';
import '../services/speech/speech_service_manager.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  String _liveText = '';
  List<String> _finalizedSegments = [];
  RecognitionEngine _selectedEngine = RecognitionEngine.platform;
  SpeechRecognitionService? _speechService;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechServiceManager.createService(_selectedEngine);
  }

  @override
  void dispose() {
    _speechService?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    print('[HomeScreen] Toggle recording called. Current state: $_isRecording');

    if (_speechService == null) {
      print('[HomeScreen] ERROR: Speech service is null');
      return;
    }

    if (_isRecording) {
      // Stopping
      print('[HomeScreen] Stopping listening...');
      await _speechService!.stopListening();
      setState(() {
        _isRecording = false;
        _liveText = '';
      });
    } else {
      // Starting
      print('[HomeScreen] Starting to listen...');

      String? errorMessage;

      final success = await _speechService!.startListening(
        // ⬅️ Capture return value
        onInterimResult: (text) {
          print('[HomeScreen] Interim result: "$text"');
          setState(() {
            _liveText = text;
          });
        },
        onFinalResult: (text) {
          print('[HomeScreen] Final result: "$text"');
          setState(() {
            _finalizedSegments.add(text);
            _liveText = '';
          });
        },
        onError: (error) {
          print('[HomeScreen] ERROR: $error');
          errorMessage = error;
          setState(() {
            _isRecording = false;
          });
        },
      );

      // Only update recording state if successfully started
      if (success) {
        setState(() {
          _isRecording = true;
        });
      } else if (errorMessage != null) {
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) {
              final l10n = AppLocalizations.of(context)!;
              return AlertDialog(
                title: Text(l10n.error),
                content: Text(errorMessage ?? l10n.unknownError),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.ok),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zip Captions'),
        actions: [
          if (_isRecording)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _toggleRecording,
              tooltip: l10n.stopRecording,
              color: Colors.red,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: _isRecording ? _buildRecordingView(context) : _buildIdleView(),
    );
  }

  Widget _buildIdleView() {
    return Center(
      child: FloatingActionButton.large(
        onPressed: _toggleRecording,
        child: const Icon(Icons.mic, size: 40),
      ),
    );
  }

  Widget _buildRecordingView(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    // Get segments in the right order based on scroll direction
    final displaySegments =
        settingsProvider.scrollDirection == ScrollDirection.topToBottom
        ? _finalizedSegments.reversed.toList()
        : _finalizedSegments;

    return Column(
      mainAxisAlignment:
          settingsProvider.scrollDirection == ScrollDirection.bottomToTop
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (settingsProvider.scrollDirection ==
            ScrollDirection.topToBottom) ...[
          LiveCaptionDisplay(text: _liveText),
          FinalizedSegmentsList(segments: displaySegments, reverseOrder: false),
        ] else ...[
          FinalizedSegmentsList(segments: displaySegments, reverseOrder: false),
          LiveCaptionDisplay(text: _liveText),
        ],
      ],
    );
  }
}
