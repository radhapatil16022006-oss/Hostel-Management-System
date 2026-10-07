import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

enum BadgeType { success, warning, error, info, neutral }

/// Modern rounded status badge with soft background and contrasting text.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.icon,
    this.showDot = true,
  });

  /// Factory constructors for domain-specific statuses
  factory StatusBadge.fromStatus(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('paid') && !lower.contains('partially')) {
      return StatusBadge(label: status, type: BadgeType.success);
    } else if (lower.contains('partially') || lower.contains('pending')) {
      return StatusBadge(label: status, type: BadgeType.warning);
    } else if (lower.contains('present') ||
        lower.contains('approved') ||
        lower.contains('resolved') ||
        lower.contains('active')) {
      return StatusBadge(label: status, type: BadgeType.success);
    } else if (lower.contains('absent') ||
        lower.contains('rejected') ||
        lower.contains('deleted') ||
        lower.contains('inactive')) {
      return StatusBadge(label: status, type: BadgeType.error);
    } else if (lower.contains('progress')) {
      return StatusBadge(label: status, type: BadgeType.info);
    }
    return StatusBadge(label: status, type: BadgeType.neutral);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.successLight;
        fg = AppColors.successDark;
        break;
      case BadgeType.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warningDark;
        break;
      case BadgeType.error:
        bg = AppColors.errorLight;
        fg = AppColors.errorDark;
        break;
      case BadgeType.info:
        bg = AppColors.infoLight;
        fg = AppColors.infoDark;
        break;
      case BadgeType.neutral:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
