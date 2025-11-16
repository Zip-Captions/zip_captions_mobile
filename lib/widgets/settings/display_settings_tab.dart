import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

/// Display settings tab in settings
///
/// Currently contains:
/// - Scroll direction preference
///
/// Will contain additional display-related settings as features are added
class DisplaySettingsTab extends StatelessWidget {
  const DisplaySettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Access the SettingsProvider to read/update scroll direction
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currentDirection = settingsProvider.scrollDirection;

    return ListView(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.scrollDirection,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        // RadioGroup manages the selected value and handles changes
        RadioGroup<ScrollDirection>(
          groupValue: currentDirection,
          onChanged: (ScrollDirection? value) {
            if (value != null) {
              settingsProvider.setScrollDirection(value);
            }
          },
          child: Column(
            children: [
              // Top to Bottom option
              RadioListTile<ScrollDirection>(
                value: ScrollDirection.topToBottom,
                title: Text(l10n.topToBottom),
                subtitle: Text(l10n.topToBottomDescription),
              ),

              // Bottom to Top option
              RadioListTile<ScrollDirection>(
                value: ScrollDirection.bottomToTop,
                title: Text(l10n.bottomToTop),
                subtitle: Text(l10n.bottomToTopDescription),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
