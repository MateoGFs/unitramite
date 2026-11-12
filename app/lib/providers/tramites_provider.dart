import 'package:flutter/foundation.dart';

import '../models/tramite.dart';
import '../services/tramites_service.dart';

enum LoadStatus { idle, loading, loaded, error }

/// Estado del catálogo de trámites: lista, carga, error y detalles en caché.
class TramitesProvider extends ChangeNotifier {
  TramitesProvider(this._service);

  final TramitesService _service;
  final Map<String, TramiteDetail> _details = {};

  List<TramiteSummary> _items = const [];
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  List<TramiteSummary> get items => _items;
  LoadStatus get status => _status;
  String? get error => _error;

  Future<void> load() async {
    if (_status == LoadStatus.loading) return;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _items = await _service.list();
      _status = LoadStatus.loaded;
    } on TramitesException catch (e) {
      _error = e.message;
      _status = LoadStatus.error;
    } catch (_) {
      _error = 'Ocurrió un error inesperado. Intenta de nuevo.';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<TramiteDetail> detail(String id) async {
    final cached = _details[id];
    if (cached != null) return cached;
    final detail = await _service.detail(id);
    _details[id] = detail;
    return detail;
  }
}