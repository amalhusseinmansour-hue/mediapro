import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/locale_controller.dart';
import '../constants/app_colors.dart';

class LanguageToggleButton extends StatelessWidget {
  final bool showLabel;
  final IconData? customIcon;
  final Color? backgroundColor;
  final Color? textColor;

  const LanguageToggleButton({
    super.key,
    this.showLabel = true,
    this.customIcon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return Obx(() {
      return GestureDetector(
        onTap: () => localeController.toggleLanguage(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                customIcon ?? Icons.language,
                color: textColor ?? AppColors.neonCyan,
                size: 20,
              ),
              if (showLabel) ...[
                const SizedBox(width: 8),
                Text(
                  localeController.otherLanguageName,
                  style: TextStyle(
                    color: textColor ?? AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

// Simple icon-only version
class LanguageToggleIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const LanguageToggleIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return IconButton(
      icon: Icon(
        Icons.language,
        size: size,
        color: color ?? AppColors.neonCyan,
      ),
      onPressed: () => localeController.toggleLanguage(),
      tooltip: 'change_language'.tr,
    );
  }
}

// Animated language switch button
class AnimatedLanguageSwitch extends StatelessWidget {
  const AnimatedLanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return Obx(() {
      return GestureDetector(
        onTap: () => localeController.toggleLanguage(),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.neonCyan.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('AR', localeController.isArabic),
              const SizedBox(width: 4),
              _buildLanguageOption('EN', localeController.isEnglish),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLanguageOption(String label, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.neonCyan : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : AppColors.textSecondary,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
