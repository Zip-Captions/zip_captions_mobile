// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settings => 'Configuración';

  @override
  String get stopRecording => 'Detener Grabación';

  @override
  String get language => 'Idioma';

  @override
  String get scrollDirection => 'Dirección de Desplazamiento';

  @override
  String get topToBottom => 'De Arriba a Abajo';

  @override
  String get bottomToTop => 'De Abajo a Arriba';

  @override
  String get topToBottomDescription =>
      'Subtítulos en vivo arriba, segmentos más recientes abajo';

  @override
  String get bottomToTopDescription =>
      'Segmentos más recientes arriba, subtítulos en vivo abajo';

  @override
  String get error => 'Error';

  @override
  String get ok => 'Aceptar';

  @override
  String get permissionRequired =>
      'Se requiere permiso de micrófono. Por favor, otorga el permiso en la configuración de tu dispositivo.';

  @override
  String get unknownError => 'Error Desconocido';

  @override
  String get display => 'Pantalla';

  @override
  String get languageSettings => 'Idioma';

  @override
  String get systemDefault => 'Predeterminado del Sistema';

  @override
  String get selectLanguage => 'Selecciona tu idioma preferido';
}
