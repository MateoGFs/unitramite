import '../models/tramite.dart';

// DATOS DE EJEMPLO tomados del mockup de diseño.
// Los costos, plazos, nombres de acuerdos y fechas NO están verificados con
// documentos oficiales. Reemplazar por datos reales (backend o documentos
// cargados) antes de mostrarlos a usuarios.

const List<Tramite> sampleTramites = [
  Tramite(
    title: 'Certificado de notas y promedio',
    entity: 'OCARA • Registro Académico',
    badge: 'Frecuente',
    category: TramiteCategory.academic,
    duration: '2 a 3 días hábiles',
    cost: r'$18.500 COP',
  ),
  Tramite(
    title: 'Cancelación extemporánea de asignatura',
    entity: 'Consejo de Facultad • Acuerdo 028',
    badge: 'Calendario activo',
    category: TramiteCategory.calendar,
    duration: '5 días hábiles',
  ),
  Tramite(
    title: 'Subsidio alimentario / Restaurante',
    entity: 'Bienestar Universitario • Sede Torobajo',
    badge: 'Convocatoria',
    category: TramiteCategory.welfare,
    duration: 'Periodo vigente',
  ),
];

const String sampleDataValidity = 'Febrero 2025 (Acuerdo 028)';
const String sampleVersionLabel =
    'TRAMITAU Udenar v2.4 • Conexión oficial segura';
