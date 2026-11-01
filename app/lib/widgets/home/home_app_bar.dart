import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Encabezado institucional: menú, marca y acceso al perfil.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.onMenuPressed,
    required this.onProfilePressed,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      centerTitle: true,
      shape: const Border(bottom: BorderSide(color: AppColors.brandBorder)),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menú principal',
        onPressed: onMenuPressed,
      ),
      title: const _Brand(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _ProfileButton(onPressed: onProfilePressed),
        ),
      ],
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reemplazar por Image.asset(...) cuando exista el logo oficial.
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.school_outlined,
            size: 22,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.brandName,
                style: GoogleFonts.robotoFlex(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  height: 1.1,
                  color: AppColors.brandDark,
                ).copyWith(fontVariations: const [FontVariation('wdth', 75)]),
              ),
              const Text(
                AppConstants.brandTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Perfil y accesos',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.brandLime,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
