import 'speech_recognition_service.dart';
import 'platform_speech_service.dart';

enum RecognitionEngine {
  platform,
  // vosk,     // We'll add this later
  // azure,    // And this for paid option
}

class SpeechServiceManager {
  static SpeechRecognitionService createService(RecognitionEngine engine) {
    switch (engine) {
      case RecognitionEngine.platform:
        return PlatformSpeechService();
      // case RecognitionEngine.vosk:
      //   return VoskSpeechService();
      // case RecognitionEngine.azure:
      //   return AzureSpeechService();
    }
  }

  static List<RecognitionEngine> getAvailableEngines() {
    return [
      RecognitionEngine.platform,
      // Add others as they become available
    ];
  }

  static String getEngineName(RecognitionEngine engine) {
    switch (engine) {
      case RecognitionEngine.platform:
        return 'Platform Default (Google/Apple)';
    }
  }
}
