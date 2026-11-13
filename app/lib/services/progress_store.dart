import '../models/tramite_progress.dart';

/// Dónde se guarda el progreso del estudiante.
abstract class ProgressStore {
  Future<List<TramiteProgress>> load();
  Future<void> save(List<TramiteProgress> items);
}