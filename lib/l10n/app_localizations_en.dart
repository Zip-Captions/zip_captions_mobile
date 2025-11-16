// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get language => 'Language';

  @override
  String get scrollDirection => 'Scroll Direction';

  @override
  String get topToBottom => 'Top to Bottom';

  @override
  String get bottomToTop => 'Bottom to Top';

  @override
  String get topToBottomDescription =>
      'Live captions at top, newest segments at bottom';

  @override
  String get bottomToTopDescription =>
      'Newest segments at top, live captions at bottom';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get permissionRequired =>
      'Microphone permission is required. Please grant permission in your device settings.';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get display => 'Display';

  @override
  String get languageSettings => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get selectLanguage => 'Select your preferred language';
}
