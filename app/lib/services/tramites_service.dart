import '../models/tramite.dart';

abstract class TramitesService {
  Future<List<TramiteSummary>> list();
  Future<TramiteDetail> detail(String id);
}

/// Error esperado con un mensaje que se puede mostrar al usuario.
class TramitesException implements Exception {
  const TramitesException(this.message);

  final String message;

  @override
  String toString() => message;
}