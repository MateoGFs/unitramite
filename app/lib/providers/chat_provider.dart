import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/assistant_service.dart';
import '../services/conversation_store.dart';

/// Estado del chat: conversación actual, historial y estado de carga.
class ChatProvider extends ChangeNotifier {
  ChatProvider(this._service, this._store);

  static const int _maxConversations = 30;

  final AssistantService _service;
  final ConversationStore _store;
  final List<Conversation> _conversations = [];

  Conversation _current = Conversation.create();
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_current.messages);
  bool get isLoading => _isLoading;
  bool get hasMessages => _current.messages.isNotEmpty;

  /// Conversaciones guardadas, la más reciente primero.
  List<Conversation> get history {
    final sorted = [..._conversations]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  Future<void> load() async {
    final saved = await _store.load();
    _conversations.addAll(saved.where((c) => !c.isEmpty));
    notifyListeners();
  }

  /// Empieza una conversación nueva. La anterior queda en el historial.
  void startConversation() {
    if (_isLoading || _current.isEmpty) return;
    _current = Conversation.create();
    notifyListeners();
  }

  /// Reabre una conversación guardada para continuarla.
  void open(String id) {
    if (_isLoading) return;
    for (final conversation in _conversations) {
      if (conversation.id == id) {
        _current = conversation;
        notifyListeners();
        return;
      }
    }
  }

  Future<void> delete(String id) async {
    if (_isLoading && _current.id == id) return;
    _conversations.removeWhere((c) => c.id == id);
    if (_current.id == id) _current = Conversation.create();
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    if (_isLoading) return;
    _conversations.clear();
    _current = Conversation.create();
    notifyListeners();
    await _persist();
  }

  Future<void> sendQuestion(String question) async {
    final text = question.trim();
    if (text.isEmpty || _isLoading) return;

    final conversation = _current;
    final history = _recentHistory(conversation);

    conversation.messages.add(ChatMessage(text: text, role: MessageRole.user));
    conversation.updatedAt = DateTime.now();
    if (!_conversations.contains(conversation)) {
      _conversations.insert(0, conversation);
      _trimHistory();
    }
    _isLoading = true;
    notifyListeners();
    await _persist();

    try {
      final answer = await _service.ask(text, history: history);
      conversation.messages.add(
        ChatMessage(
          text: answer.text,
          role: MessageRole.assistant,
          sources: answer.sources,
          status: answer.found ? MessageStatus.normal : MessageStatus.notFound,
        ),
      );
    } on AssistantException catch (e) {
      conversation.messages.add(
        ChatMessage(
          text: e.message,
          role: MessageRole.assistant,
          status: MessageStatus.error,
        ),
      );
    } catch (_) {
      conversation.messages.add(
        const ChatMessage(
          text: 'Ocurrió un error inesperado. Intenta de nuevo.',
          role: MessageRole.assistant,
          status: MessageStatus.error,
        ),
      );
    } finally {
      conversation.updatedAt = DateTime.now();
      _isLoading = false;
      notifyListeners();
      await _persist();
    }
  }

  /// Últimos mensajes útiles de la conversación, para dar contexto a la IA.
  List<ChatMessage> _recentHistory(Conversation conversation) {
    final useful = conversation.messages
        .where((m) => m.status != MessageStatus.error)
        .toList();
    return useful.length > 6 ? useful.sublist(useful.length - 6) : useful;
  }

  /// Conserva solo las conversaciones más recientes.
  void _trimHistory() {
    while (_conversations.length > _maxConversations) {
      final candidates = _conversations.where((c) => c != _current).toList()
        ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      if (candidates.isEmpty) return;
      _conversations.remove(candidates.first);
    }
  }

  Future<void> _persist() async {
    try {
      await _store.save(_conversations.where((c) => !c.isEmpty).toList());
    } catch (_) {
      // Si no se puede guardar, la conversación sigue disponible en memoria.
    }
  }
}