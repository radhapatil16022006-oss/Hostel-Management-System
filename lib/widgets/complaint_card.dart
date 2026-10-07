import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/utils/formatters.dart';
import 'status_badge.dart';

/// Reusable card displaying complaints with category, status, and rector response preview.
class ComplaintCard extends StatelessWidget {
  final String title;
  final String category;
  final String description;
  final String status;
  final DateTime date;
  final String? studentName;
  final String? roomNumber;
  final String? rectorResponse;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.date,
    this.studentName,
    this.roomNumber,
    this.rectorResponse,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: isDark ? null : AppDimensions.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryLight : AppColors.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                    StatusBadge.fromStatus(status),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (studentName != null)
                      Text(
                        '$studentName • Room ${roomNumber ?? '-'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Text(
                      Formatters.date(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
                if (rectorResponse != null && rectorResponse!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spaceSm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.spaceSm),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.reply_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Admin response: $rectorResponse',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
