import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/tramite.dart';

/// Tarjeta de resultado con insignias, tiempo, costo y requisitos desplegables.
class TramiteResultCard extends StatefulWidget {
  const TramiteResultCard({
    super.key,
    required this.tramite,
    required this.onDetail,
    this.emphasized = false,
    this.initiallyExpanded = false,
  });

  final Tramite tramite;
  final VoidCallback onDetail;

  /// El mejor resultado lleva el botón principal relleno.
  final bool emphasized;
  final bool initiallyExpanded;

  @override
  State<TramiteResultCard> createState() => _TramiteResultCardState();
}

class _TramiteResultCardState extends State<TramiteResultCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final tramite = widget.tramite;
    final hasRequirements = tramite.requirements.isNotEmpty;
    final emphasized = widget.emphasized;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDark.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (tramite.isRecommended)
                      _Pill(
                        icon: Icons.star,
                        iconColor: AppColors.success,
                        label: 'Recomendado',
                        foreground: AppColors.successDark,
                        background: AppColors.successLight,
                        border: AppColors.success.withValues(alpha: 0.2),
                      ),
                    if (tramite.isVerified)
                      _Pill(
                        icon: Icons.verified,
                        iconColor: AppColors.brandPurple,
                        label: 'Fuente oficial verificada',
                        foreground: AppColors.brandPurple,
                        background: AppColors.brandPurpleLight,
                        border: AppColors.brandPurple.withValues(alpha: 0.15),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TagChip(
                label: tramite.badge,
                outlined: tramite.category == TramiteCategory.calendar,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tramite.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: AppColors.brandDark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  tramite.category.entityIcon,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tramite.entity,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.brandBorder),
          const SizedBox(height: 10),
          _MetaTiles(tramite: tramite),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded && hasRequirements
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _RequirementsBox(requirements: tramite.requirements),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.brandBorder),
          const SizedBox(height: 8),
          // Wrap evita desbordamiento en pantallas angostas.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              if (hasRequirements)
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                  ),
                  label: Text(_expanded ? 'Ocultar requisitos' : 'Ver requisitos'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: widget.onDetail,
                style: FilledButton.styleFrom(
                  backgroundColor: emphasized ? AppColors.primary : AppColors.tealSoft,
                  foregroundColor: emphasized ? Colors.white : AppColors.primaryDark,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emphasized ? 'Ver detalle de trámite' : 'Ver detalle'),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tiempo y costo: en columna en pantallas angostas, lado a lado si hay espacio.
class _MetaTiles extends StatelessWidget {
  const _MetaTiles({required this.tramite});

  final Tramite tramite;

  @override
  Widget build(BuildContext context) {
    final cost = tramite.cost;
    final time = _MetaTile(
      icon: Icons.schedule,
      label: 'Tiempo promedio',
      value: tramite.duration,
      valueColor: AppColors.brandDark,
      bold: false,
    );
    final price = _MetaTile(
      icon: cost == null ? Icons.price_check : Icons.payments_outlined,
      label: 'Costo estimado',
      value: cost ?? r'Gratuito ($0 COP)',
      valueColor: AppColors.primaryDark,
      bold: true,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 420) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: time),
                const SizedBox(width: 8),
                Expanded(child: price),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [time, const SizedBox(height: 8), price],
        );
      },
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.bold,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandMuted,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementsBox extends StatelessWidget {
  const _RequirementsBox({required this.requirements});

  final List<TramiteRequirement> requirements;

  @override
  Widget build(BuildContext context) {
    final count = requirements.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, size: 17, color: AppColors.primary),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Requisitos obligatorios',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandPurpleLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  count == 1 ? '1 requerido' : '$count requeridos',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.brandBorder),
          const SizedBox(height: 8),
          for (var i = 0; i < requirements.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == requirements.length - 1 ? 0 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requirements[i].title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandDark,
                          ),
                        ),
                        if (requirements[i].description != null)
                          Text(
                            requirements[i].description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.brandMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color foreground;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.outlined});

  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: outlined ? AppColors.warmWhite : AppColors.tealSoft,
        borderRadius: BorderRadius.circular(99),
        border: outlined ? Border.all(color: AppColors.brandBorder) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: outlined ? AppColors.brandMuted : AppColors.primaryDark,
        ),
      ),
    );
  }
}

extension on TramiteCategory {
  IconData get entityIcon => switch (this) {
        TramiteCategory.academic => Icons.apartment,
        TramiteCategory.calendar => Icons.groups_outlined,
        TramiteCategory.welfare => Icons.badge_outlined,
      };
}
