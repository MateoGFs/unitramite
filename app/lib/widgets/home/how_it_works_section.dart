import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class _Step {
  const _Step(this.color, this.onColor, this.title, this.subtitle);

  final Color color;
  final Color onColor;
  final String title;
  final String subtitle;
}

// Texto oscuro sobre amarillo y lima: el blanco no tiene contraste suficiente.
const List<_Step> _steps = [
  _Step(AppColors.primary, Colors.white, 'Encuentra',
      'Busca el trámite que necesitas'),
  _Step(AppColors.brandYellow, AppColors.brandDark, 'Comprende',
      'Revisa requisitos y costos oficiales'),
  _Step(AppColors.brandLime, AppColors.brandDark, 'Consulta',
      'Sigue el flujo guiado con apoyo IA'),
  _Step(AppColors.brandPurple, Colors.white, 'Verifica',
      'Accede a los enlaces oficiales Udenar'),
];

/// Lista de 4 pasos. Si [onStepTap] es null las filas son solo informativas
/// y no muestran la flecha (no se ofrece una acción que no existe).
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key, this.onStepTap});

  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) {
    final onTap = onStepTap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Cómo funciona?', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.brandBorder),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _steps.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.brandBorder),
                _StepTile(
                  number: i + 1,
                  step: _steps[i],
                  onTap: onTap == null ? null : () => onTap(i + 1),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.number, required this.step, this.onTap});

  final int number;
  final _Step step;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: step.color,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: step.onColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDark,
                    ),
                  ),
                  Text(
                    step.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.brandMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 18, color: AppColors.brandMuted),
          ],
        ),
      ),
    );
  }
}
