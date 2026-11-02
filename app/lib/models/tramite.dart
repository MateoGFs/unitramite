/// Tipo de trámite. La interfaz decide ícono y colores según este valor,
/// así el modelo no depende de Flutter.
enum TramiteCategory { academic, calendar, welfare }

/// Un requisito de un trámite, con una aclaración opcional.
class TramiteRequirement {
  const TramiteRequirement(this.title, {this.description});

  final String title;
  final String? description;
}

class Tramite {
  const Tramite({
    required this.title,
    required this.entity,
    required this.badge,
    required this.category,
    required this.duration,
    this.cost,
    this.isRecommended = false,
    this.isVerified = false,
    this.requirements = const [],
    this.costCop,
    this.minDurationHours,
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

  /// Muestra la insignia "Recomendado".
  final bool isRecommended;

  /// Muestra la insignia "Fuente oficial verificada". Debe ser true solo si
  /// el dato realmente fue contrastado con un documento oficial.
  final bool isVerified;

  final List<TramiteRequirement> requirements;

  /// Valores numéricos solo para ordenar. null = sin dato (va al final).
  final int? costCop;

  /// Aproximado: 1 día hábil = 24 h.
  final int? minDurationHours;
}
