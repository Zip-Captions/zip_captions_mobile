import 'package:flutter/material.dart';

class FinalizedSegmentsList extends StatelessWidget {
  final List<String> segments;
  final bool reverseOrder;

  const FinalizedSegmentsList({
    super.key,
    required this.segments,
    required this.reverseOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        reverse: reverseOrder,
        padding: const EdgeInsets.all(16),
        itemCount: segments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              segments[index],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }
}
