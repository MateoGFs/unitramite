import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/assistant_service.dart';

/// Maneja el estado de la conversación: mensajes y estado de carga.
class ChatProvider extends ChangeNotifier {
  ChatProvider(this._service);

  final AssistantService _service;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendQuestion(String question) async {
    final text = question.trim();
    if (text.isEmpty || _isLoading) return;

    _messages.add(ChatMessage(text: text, role: MessageRole.user));
    _isLoading = true;
    notifyListeners();

    try {
      final answer = await _service.ask(text);
      _messages.add(
        ChatMessage(
          text: answer.text,
          role: MessageRole.assistant,
          sources: answer.sources,
          status: answer.found ? MessageStatus.normal : MessageStatus.notFound,
        ),
      );
    } on AssistantException catch (e) {
      _messages.add(
        ChatMessage(
          text: e.message,
          role: MessageRole.assistant,
          status: MessageStatus.error,
        ),
      );
    } catch (_) {
      _messages.add(
        const ChatMessage(
          text: 'Ocurrió un error inesperado. Intenta de nuevo.',
          role: MessageRole.assistant,
          status: MessageStatus.error,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    if (_isLoading) return;
    _messages.clear();
    notifyListeners();
  }
}