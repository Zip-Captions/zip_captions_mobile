import 'package:flutter/material.dart';
import '../widgets/recording/live_caption_display.dart';
import '../widgets/recording/finalized_segments_list.dart';
import '../services/speech/speech_recognition_service.dart';
import '../services/speech/speech_service_manager.dart';

enum ScrollDirection { topToBottom, bottomToTop }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRecording = false;
  String _liveText = '';
  List<String> _finalizedSegments = [];
  ScrollDirection _scrollDirection = ScrollDirection.bottomToTop;
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
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(errorMessage ?? 'Unknown Error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _showScrollDirectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scroll Direction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ScrollDirection>(
                title: const Text('Top to Bottom'),
                subtitle: const Text(
                  'Live captions at top, newest segments at bottom',
                ),
                value: ScrollDirection.topToBottom,
                groupValue: _scrollDirection,
                onChanged: (ScrollDirection? value) {
                  if (value != null) {
                    setState(() {
                      _scrollDirection = value;
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ScrollDirection>(
                title: const Text('Bottom to Top'),
                subtitle: const Text(
                  'Newest segments at top, live captions at bottom',
                ),
                value: ScrollDirection.bottomToTop,
                groupValue: _scrollDirection,
                onChanged: (ScrollDirection? value) {
                  if (value != null) {
                    setState(() {
                      _scrollDirection = value;
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zip Captions'),
        actions: [
          if (_isRecording)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _toggleRecording,
              tooltip: 'Stop Recording',
              color: Colors.red,
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showScrollDirectionDialog,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isRecording ? _buildRecordingView() : _buildIdleView(),
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

  Widget _buildRecordingView() {
    // Get segments in the right order based on scroll direction
    final displaySegments = _scrollDirection == ScrollDirection.topToBottom
        ? _finalizedSegments.reversed.toList()
        : _finalizedSegments;

    return Column(
      mainAxisAlignment: _scrollDirection == ScrollDirection.bottomToTop
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (_scrollDirection == ScrollDirection.topToBottom) ...[
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
