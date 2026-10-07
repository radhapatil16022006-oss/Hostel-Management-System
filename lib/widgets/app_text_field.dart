import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Reusable form input text field conforming to the application design system.
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? helperText;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.helperText,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget? suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffixIcon != null) {
      suffix = widget.suffixIcon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSm),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword ? _obscureText : false,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  )
                : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
