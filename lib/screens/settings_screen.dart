import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/settings/language_settings_tab.dart';
import '../widgets/settings/display_settings_tab.dart';

/// Main settings screen with tabbed navigation
///
/// This screen uses TabBar for organizing settings into categories.
/// Currently has 2 tabs, designed to scale to 4+ tabs as features are added.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Define tab configuration once - prevents length mismatch bugs
    final tabs = [
      Tab(icon: const Icon(Icons.language), text: l10n.languageSettings),
      Tab(icon: const Icon(Icons.display_settings), text: l10n.display),
      // Future tabs will go here:
      // Tab(icon: const Icon(Icons.mic), text: "Audio"),
      // Tab(icon: const Icon(Icons.info), text: "About"),
    ];

    // Define tab content - must match tabs list order
    const tabViews = [
      LanguageSettingsTab(),
      DisplaySettingsTab(),
      // Future tab content will go here
    ];

    // DefaultTabController manages tab state automatically
    return DefaultTabController(
      length: tabs.length, // Computed from tabs list - always stays in sync!
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          // TabBar goes in the bottom of the AppBar
          bottom: TabBar(tabs: tabs),
        ),
        // TabBarView displays the content for each tab
        body: TabBarView(children: tabViews),
      ),
    );
  }
}
