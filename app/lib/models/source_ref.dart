/// Referencia a un documento oficial que respalda una respuesta.
class SourceRef {
  const SourceRef({
    required this.documentName,
    this.page,
    this.url,
  });

  final String documentName;
  final int? page;
  final String? url;

  /// Texto para mostrar en pantalla.
  String get label =>
      page != null ? '$documentName, pág. $page' : documentName;
}