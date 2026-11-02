/// Tipo de trámite. La interfaz decide ícono y colores según este valor,
/// así el modelo no depende de Flutter.
enum TramiteCategory { academic, calendar, welfare }

class Tramite {
  const Tramite({
    required this.title,
    required this.entity,
    required this.badge,
    required this.category,
    required this.duration,
    this.cost,
  });

  final String title;

  /// Dependencia responsable, por ejemplo "OCARA • Registro Académico".
  final String entity;

  /// Etiqueta corta de la tarjeta: "Frecuente", "Convocatoria"...
  final String badge;
  final TramiteCategory category;
  final String duration;

  /// Costo como texto. null significa que el trámite es gratuito.
  final String? cost;
}
