import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

/// Language selection tab in settings
///
/// Allows users to:
/// - Use system language (default)
/// - Override with a specific language
///
/// Uses Provider to access and update the LocaleProvider
class LanguageSettingsTab extends StatelessWidget {
  const LanguageSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Access the LocaleProvider to read/update language
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Get the current locale (null = system default)
    final currentLocale = localeProvider.locale;

    return ListView(
      children: [
        // Instruction text
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.selectLanguage,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),

        // RadioGroup manages the selected value and handles changes
        RadioGroup<String?>(
          groupValue: currentLocale?.languageCode,
          onChanged: (String? value) {
            // Convert language code back to Locale
            if (value == null) {
              localeProvider.setLocale(null); // System default
            } else {
              localeProvider.setLocale(Locale(value));
            }
          },
          child: Column(
            children: [
              // System Default option
              RadioListTile<String?>(
                value: null,
                title: Text(l10n.systemDefault),
              ),

              const Divider(),

              // English option
              RadioListTile<String?>(value: 'en', title: const Text('English')),

              // French option
              RadioListTile<String?>(
                value: 'fr',
                title: const Text('Français'),
              ),

              // Spanish option
              RadioListTile<String?>(value: 'es', title: const Text('Español')),
            ],
          ),
        ),
      ],
    );
  }
}
