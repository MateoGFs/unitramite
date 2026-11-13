import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation.dart';
import 'conversation_store.dart';

/// Guarda las conversaciones en el almacenamiento local del dispositivo.
class SharedPrefsConversationStore implements ConversationStore {
  static const String _key = 'unitramite.conversations.v1';

  @override
  Future<List<Conversation>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final data = jsonDecode(raw) as List<dynamic>;

      final result = <Conversation>[];
      for (final item in data) {
        try {
          result.add(Conversation.fromJson(item as Map<String, dynamic>));
        } catch (_) {
          // Una conversación dañada se omite; las demás se conservan.
        }
      }
      return result;
    } catch (_) {
      return []; // datos dañados: se empieza de cero
    }
  }

  @override
  Future<void> save(List<Conversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(conversations.map((c) => c.toJson()).toList()),
    );
  }
}