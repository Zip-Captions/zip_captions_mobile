import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'l10n/app_localizations.dart'; // Generated localization file

void main() {
  runApp(
    // Wrap app with LocaleProvider so all widgets can access it
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const ZipCaptionsApp(),
    ),
  );
}

class ZipCaptionsApp extends StatelessWidget {
  const ZipCaptionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to locale changes and rebuild when language changes
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Zip Captions',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,

          // Set the current locale (null = use system language)
          locale: localeProvider.locale,

          // Register localization delegates
          localizationsDelegates: const [
            AppLocalizations.delegate, // Your app translations
            GlobalMaterialLocalizations
                .delegate, // Material widgets translations
            GlobalWidgetsLocalizations.delegate, // Text direction, etc.
            GlobalCupertinoLocalizations.delegate, // iOS-style widgets
          ],

          // Define which languages your app supports
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
            Locale('es'), // Spanish
          ],

          home: const SplashScreen(),
        );
      },
    );
  }
}
