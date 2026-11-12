import 'source_ref.dart';

/// Datos para la lista de trámites.
class TramiteSummary {
  const TramiteSummary({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
  });

  factory TramiteSummary.fromJson(Map<String, dynamic> json) {
    return TramiteSummary(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
}

/// Datos completos de un trámite, para la pantalla de detalle.
class TramiteDetail extends TramiteSummary {
  const TramiteDetail({
    required super.id,
    required super.nombre,
    required super.categoria,
    required super.descripcion,
    required this.requisitos,
    required this.pasos,
    required this.condiciones,
    required this.referencia,
    required this.dependencia,
    required this.contacto,
    required this.fechaVerificacion,
    required this.preguntas,
    required this.fuentes,
  });

  factory TramiteDetail.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) =>
        (json[key] as List<dynamic>? ?? []).map((e) => e as String).toList();

    return TramiteDetail(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
      descripcion: json['descripcion'] as String,
      requisitos: strings('requisitos'),
      pasos: strings('pasos'),
      condiciones: strings('condiciones'),
      referencia: strings('referencia'),
      dependencia: json['dependencia'] as String? ?? '',
      contacto: json['contacto'] as String? ?? '',
      fechaVerificacion: json['fecha_verificacion'] as String? ?? '',
      preguntas: strings('preguntas'),
      fuentes: (json['fuentes'] as List<dynamic>? ?? []).map((item) {
        final map = item as Map<String, dynamic>;
        return SourceRef(
          documentName: map['document_name'] as String,
          page: map['page'] as int?,
          url: map['url'] as String?,
        );
      }).toList(),
    );
  }

  final List<String> requisitos;
  final List<String> pasos;
  final List<String> condiciones;
  final List<String> referencia;
  final String dependencia;
  final String contacto;
  final String fechaVerificacion;
  final List<String> preguntas;
  final List<SourceRef> fuentes;
}