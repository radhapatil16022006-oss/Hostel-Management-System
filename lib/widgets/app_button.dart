import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

enum AppButtonVariant { primary, secondary, outline, danger, text }

/// Production-ready modern action button with multiple variants and loading indicator.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isSmall;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isSmall = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final height = isSmall ? AppDimensions.buttonHeightSm : AppDimensions.buttonHeight;
    final borderRadius = BorderRadius.circular(AppDimensions.radiusMd);

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isDark ? AppColors.secondaryLight : AppColors.secondary;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
        borderSide = BorderSide(color: foregroundColor, width: 1.5);
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.primaryLight : AppColors.primary;
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: isSmall ? 16 : 20,
            height: isSmall ? 16 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 16 : 20, color: foregroundColor),
            const SizedBox(width: AppDimensions.spaceSm),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 13 : 15,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: borderSide ?? BorderSide.none,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppDimensions.spaceSm : AppDimensions.spaceLg,
      ),
    );

    Widget button = SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : width,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    );

    return button;
  }
}
