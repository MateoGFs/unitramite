import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tramite_progress.dart';
import 'progress_store.dart';

/// Guarda el progreso en el almacenamiento local del dispositivo.
class SharedPrefsProgressStore implements ProgressStore {
  static const String _key = 'unitramite.progress.v1';

  @override
  Future<List<TramiteProgress>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((e) => TramiteProgress.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // datos dañados: se empieza de cero
    }
  }

  @override
  Future<void> save(List<TramiteProgress> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}