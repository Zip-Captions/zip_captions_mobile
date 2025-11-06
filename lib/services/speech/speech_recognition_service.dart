/// Abstract interface that all recognition engines must implement
abstract class SpeechRecognitionService {
  /// Initialize the service and request permissions
  Future<bool> initialize();

  /// Start listening for speech
  Future<void> startListening({
    required Function(String interimText) onInterimResult,
    required Function(String finalText) onFinalResult,
    required Function(String error) onError,
  });

  /// Stop listening
  Future<void> stopListening();

  /// Check if service is available on this device
  Future<bool> isAvailable();

  /// Get the name of this recognition engine
  String get engineName;

  /// Dispose resources
  Future<void> dispose();
}
