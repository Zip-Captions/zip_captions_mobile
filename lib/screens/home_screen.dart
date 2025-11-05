import 'package:flutter/material.dart';
import '../widgets/recording/live_caption_display.dart';
import '../widgets/recording/finalized_segments_list.dart';
import '../widgets/recording/recording_controls.dart';

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

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _liveText = 'Live text appears here as you speak...';
        _finalizedSegments = [
          'This is the first finalized segment.',
          'Here is another complete sentence that was recognized.',
          'And a third segment for demonstration purposes.',
        ];
      } else {
        _liveText = '';
        _finalizedSegments = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zip Captions')),
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
    return Column(
      children: [
        if (_scrollDirection == ScrollDirection.topToBottom) ...[
          LiveCaptionDisplay(text: _liveText),
          FinalizedSegmentsList(
            segments: _finalizedSegments,
            reverseOrder: false,
          ),
        ] else ...[
          FinalizedSegmentsList(
            segments: _finalizedSegments,
            reverseOrder: true,
          ),
          LiveCaptionDisplay(text: _liveText),
        ],
        RecordingControls(onStop: _toggleRecording),
      ],
    );
  }
}
