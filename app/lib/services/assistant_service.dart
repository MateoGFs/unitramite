import '../models/assistant_answer.dart';

abstract class AssistantService {
  Future<AssistantAnswer> ask(String question);
}

/// Error esperado con un mensaje que se puede mostrar al usuario.
class AssistantException implements Exception {
  const AssistantException(this.message);

  final String message;

  @override
  String toString() => message;
}