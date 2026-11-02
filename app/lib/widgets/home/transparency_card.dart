import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

const Color _emerald500 = Color(0xFF10B981);

/// Tarjeta informativa sobre la vigencia de los datos y la versión.
class TransparencyCard extends StatelessWidget {
  const TransparencyCard({
    super.key,
    required this.validityLabel,
    required this.versionLabel,
  });

  final String validityLabel;
  final String versionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 19, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Transparencia y Validez Institucional',
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Oficial',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DotLine(
            color: _emerald500,
            child: Text.rich(
              TextSpan(
                text: 'Datos y normativas actualizados a: ',
                children: [
                  TextSpan(
                    text: validityLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          _DotLine(color: AppColors.primary, child: Text(versionLabel)),
        ],
      ),
    );
  }
}

class _DotLine extends StatelessWidget {
  const _DotLine({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.3,
              color: AppColors.brandMuted,
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}
