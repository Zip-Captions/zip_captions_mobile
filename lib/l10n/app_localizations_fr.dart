// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Zip Sous-titres';

  @override
  String get settings => 'Paramètres';

  @override
  String get stopRecording => 'Arrêter l\'Enregistrement';

  @override
  String get language => 'Langue';

  @override
  String get scrollDirection => 'Direction de Défilement';

  @override
  String get topToBottom => 'De Haut en Bas';

  @override
  String get bottomToTop => 'De Bas en Haut';

  @override
  String get topToBottomDescription =>
      'Sous-titres en direct en haut, segments récents en bas';

  @override
  String get bottomToTopDescription =>
      'Segments récents en haut, sous-titres en direct en bas';

  @override
  String get error => 'Erreur';

  @override
  String get ok => 'OK';

  @override
  String get permissionRequired =>
      'L\'autorisation du microphone est requise. Veuillez accorder l\'autorisation dans les paramètres de votre appareil.';

  @override
  String get unknownError => 'Erreur Inconnue';
}
