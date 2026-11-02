import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/tramite.dart';

const Color _emerald700 = Color(0xFF047857);

/// Tarjeta de un trámite recomendado.
class TramiteCard extends StatelessWidget {
  const TramiteCard({super.key, required this.tramite, required this.onTap});

  final Tramite tramite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = tramite.category.style;
    final cost = tramite.cost;

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.brandBorder),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: style.iconBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(style.icon, size: 20, color: style.iconColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tramite.title,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: AppColors.brandDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tramite.entity,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.brandMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Badge(label: tramite.badge, style: style),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.brandBorder),
              const SizedBox(height: 10),
              // Wrap evita desbordamiento en pantallas angostas.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  _InfoItem(
                    icon: Icons.timer_outlined,
                    text: tramite.duration,
                    iconColor: AppColors.primary,
                    textColor: AppColors.brandMuted,
                  ),
                  if (cost == null)
                    const _InfoItem(
                      icon: Icons.check_circle_outline,
                      text: 'Gratuito',
                      iconColor: _emerald700,
                      textColor: _emerald700,
                      bold: true,
                    )
                  else
                    _InfoItem(
                      icon: Icons.payments_outlined,
                      text: cost,
                      iconColor: AppColors.brandMuted,
                      textColor: AppColors.brandDark,
                      bold: true,
                    ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Consultar paso a paso',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.textColor,
    this.bold = false,
  });

  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.style});

  final String label;
  final _CategoryStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.badgeBackground,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: style.badgeBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: style.badgeForeground,
        ),
      ),
    );
  }
}

/// Apariencia asociada a cada categoría de trámite.
class _CategoryStyle {
  const _CategoryStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.badgeForeground,
    required this.badgeBackground,
    required this.badgeBorder,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color badgeForeground;
  final Color badgeBackground;
  final Color badgeBorder;
}

extension on TramiteCategory {
  _CategoryStyle get style => switch (this) {
        TramiteCategory.academic => _CategoryStyle(
            icon: Icons.description_outlined,
            iconColor: AppColors.primaryDark,
            iconBackground: AppColors.primary.withValues(alpha: 0.1),
            badgeForeground: AppColors.primaryDark,
            badgeBackground: AppColors.primaryLight,
            badgeBorder: AppColors.primary.withValues(alpha: 0.2),
          ),
        TramiteCategory.calendar => _CategoryStyle(
            icon: Icons.event_busy_outlined,
            iconColor: const Color(0xFF7A6F11),
            iconBackground: AppColors.brandYellow.withValues(alpha: 0.15),
            badgeForeground: const Color(0xFF92400E),
            badgeBackground: const Color(0xFFFFFBEB),
            badgeBorder: const Color(0xFFFDE68A),
          ),
        TramiteCategory.welfare => _CategoryStyle(
            icon: Icons.restaurant_outlined,
            iconColor: const Color(0xFF59851F),
            iconBackground: AppColors.brandLime.withValues(alpha: 0.2),
            badgeForeground: const Color(0xFF065F46),
            badgeBackground: const Color(0xFFECFDF5),
            badgeBorder: const Color(0xFFA7F3D0),
          ),
      };
}
