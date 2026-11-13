import 'package:flutter/foundation.dart';

import '../models/tramite.dart';
import '../models/tramite_progress.dart';
import '../services/progress_store.dart';

/// Estado de los trámites que el estudiante está siguiendo.
class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._store);

  final ProgressStore _store;
  List<TramiteProgress> _items = [];

  List<TramiteProgress> get items => List.unmodifiable(_items);

  /// Trámites iniciados que aún no están completos.
  int get activeCount => _items.where((p) => !p.isDone).length;

  TramiteProgress? byId(String id) {
    for (final item in _items) {
      if (item.tramiteId == id) return item;
    }
    return null;
  }

  Future<void> load() async {
    _items = await _store.load();
    notifyListeners();
  }

  Future<void> start(TramiteDetail detail) async {
    if (byId(detail.id) != null) return;
    _items = [
      TramiteProgress.start(
        id: detail.id,
        nombre: detail.nombre,
        totalSteps: detail.pasos.length,
      ),
      ..._items,
    ];
    await _persist();
  }

  Future<void> toggleStep(String id, int index) async {
    _items = [
      for (final item in _items)
        if (item.tramiteId == id) item.toggled(index) else item,
    ];
    await _persist();
  }

  Future<void> remove(String id) async {
    _items = _items.where((p) => p.tramiteId != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    try {
      await _store.save(_items);
    } catch (_) {
      // Si no se puede guardar, la app sigue funcionando con lo que tiene en memoria.
    }
  }
}