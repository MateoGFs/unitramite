import '../models/tramite.dart';

// DATOS DE EJEMPLO tomados de los mockups de diseño.
// Los costos, plazos, requisitos, nombres de acuerdos y fechas NO están
// verificados con documentos oficiales (los dos mockups incluso se
// contradicen en el costo del certificado de notas). Reemplazar por datos
// reales (backend o documentos cargados) antes de mostrarlos a usuarios.

/// Tarjetas del Home.
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

/// Pantalla de resultados de búsqueda (pestaña Trámites).
/// isVerified está en true solo para igualar el diseño; ponerlo en false
/// hasta contrastar cada trámite con su documento oficial.
const List<Tramite> sampleSearchResults = [
  Tramite(
    title: 'Certificado de Notas y Promedio Ponderado',
    entity: 'OCARA - Oficina de Registro y Control Académico',
    badge: 'Digital',
    category: TramiteCategory.academic,
    duration: '24 a 48 horas hábiles',
    cost: r'Estampilla Pro-Udenar ($12.500 COP)',
    isRecommended: true,
    isVerified: true,
    costCop: 12500,
    minDurationHours: 24,
    requirements: [
      TramiteRequirement(
        'Paz y salvo de Biblioteca Central',
        description:
            'Biblioteca Alberto Quijano Guerrero (validación automática en SAPIENS).',
      ),
      TramiteRequirement(
        'Recibo de estampilla cancelado',
        description:
            'Pago en línea PSE o Banco de Bogotá con referencia asignada.',
      ),
      TramiteRequirement(
        'Código estudiantil activo',
        description:
            'Matrícula vigente o calidad de egresado registrado en OCARA.',
      ),
    ],
  ),
  Tramite(
    title: 'Cancelación Extemporánea de Materias',
    entity: 'Comité Curricular y Consejo de Facultad',
    badge: 'Calendario Académico',
    category: TramiteCategory.calendar,
    duration: '5 a 8 días hábiles',
    isVerified: true,
    costCop: 0,
    minDurationHours: 120,
    requirements: [
      TramiteRequirement(
        'Carta motivada con soporte de fuerza mayor o caso fortuito.',
      ),
      TramiteRequirement(
        'Concepto previo del director del departamento o docente.',
      ),
    ],
  ),
  Tramite(
    title: 'Carné Universitario Digital Udenar',
    entity: 'Bienestar Universitario / TIC Udenar',
    badge: 'Inmediato',
    category: TramiteCategory.welfare,
    duration: 'Inmediato / Emisión en app',
    isRecommended: true,
    isVerified: true,
    costCop: 0,
    minDurationHours: 0,
    requirements: [
      TramiteRequirement(
        'Matrícula financiera y académica asentada del periodo actual.',
      ),
      TramiteRequirement(
        'Fotografía en fondo blanco actualizada en el sistema SAPIENS.',
      ),
    ],
  ),
];

const String sampleDataValidity = 'Febrero 2025 (Acuerdo 028)';
const String sampleVersionLabel =
    'TRAMITAU Udenar v2.4 • Conexión oficial segura';
