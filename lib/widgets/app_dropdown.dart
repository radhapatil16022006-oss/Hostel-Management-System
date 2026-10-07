import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Modern dropdown selector component.
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSm),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
