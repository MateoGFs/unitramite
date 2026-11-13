import 'chat_message.dart';

/// Una conversación completa con el asistente.
class Conversation {
  Conversation({
    required this.id,
    required this.createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
  })  : updatedAt = updatedAt ?? createdAt,
        messages = messages ?? [];

  factory Conversation.create() {
    final now = DateTime.now();
    return Conversation(
      id: now.microsecondsSinceEpoch.toString(),
      createdAt: now,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created'] as String),
      updatedAt: DateTime.parse(json['updated'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<ChatMessage> messages;

  bool get isEmpty => messages.isEmpty;

  int get questionCount =>
      messages.where((m) => m.role == MessageRole.user).length;

  /// Título: la primera pregunta del estudiante, acortada.
  String get title {
    for (final message in messages) {
      if (message.role == MessageRole.user) {
        final text = message.text.trim().replaceAll(RegExp(r'\s+'), ' ');
        return text.length > 70 ? '${text.substring(0, 67)}…' : text;
      }
    }
    return 'Conversación';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created': createdAt.toIso8601String(),
        'updated': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}