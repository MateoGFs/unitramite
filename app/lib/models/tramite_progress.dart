/// Avance del estudiante en un trámite: qué pasos ya marcó como hechos.
class TramiteProgress {
  const TramiteProgress({
    required this.tramiteId,
    required this.nombre,
    required this.totalSteps,
    required this.completed,
    required this.startedAt,
    required this.updatedAt,
  });

  factory TramiteProgress.start({
    required String id,
    required String nombre,
    required int totalSteps,
  }) {
    final now = DateTime.now();
    return TramiteProgress(
      tramiteId: id,
      nombre: nombre,
      totalSteps: totalSteps,
      completed: const <int>{},
      startedAt: now,
      updatedAt: now,
    );
  }

  factory TramiteProgress.fromJson(Map<String, dynamic> json) {
    return TramiteProgress(
      tramiteId: json['id'] as String,
      nombre: json['nombre'] as String,
      totalSteps: json['total'] as int,
      completed: (json['done'] as List<dynamic>).map((e) => e as int).toSet(),
      startedAt: DateTime.parse(json['started'] as String),
      updatedAt: DateTime.parse(json['updated'] as String),
    );
  }

  final String tramiteId;
  final String nombre;
  final int totalSteps;
  final Set<int> completed;
  final DateTime startedAt;
  final DateTime updatedAt;

  int get completedCount => completed.where((i) => i < totalSteps).length;
  double get fraction => totalSteps == 0 ? 0 : completedCount / totalSteps;
  bool get isDone => totalSteps > 0 && completedCount >= totalSteps;

  /// Devuelve una copia con el paso [index] marcado o desmarcado.
  TramiteProgress toggled(int index) {
    final next = {...completed};
    if (!next.add(index)) next.remove(index);
    return TramiteProgress(
      tramiteId: tramiteId,
      nombre: nombre,
      totalSteps: totalSteps,
      completed: next,
      startedAt: startedAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': tramiteId,
        'nombre': nombre,
        'total': totalSteps,
        'done': (completed.toList()..sort()),
        'started': startedAt.toIso8601String(),
        'updated': updatedAt.toIso8601String(),
      };
}