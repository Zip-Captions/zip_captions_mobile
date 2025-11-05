import 'package:flutter/material.dart';

class RecordingControls extends StatelessWidget {
  final VoidCallback onStop;

  const RecordingControls({super.key, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FloatingActionButton(
        onPressed: onStop,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      ),
    );
  }
}
