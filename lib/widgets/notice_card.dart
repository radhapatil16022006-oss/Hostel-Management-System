import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';

/// Reusable card displaying notice item with priority badge and attachment flag.
class NoticeCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
  final NoticePriority priority;
  final bool hasAttachment;
  final VoidCallback? onTap;

  const NoticeCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    this.priority = NoticePriority.medium,
    this.hasAttachment = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isUrgent = priority == NoticePriority.urgent || priority == NoticePriority.high;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isUrgent
              ? (isDark ? AppColors.error.withValues(alpha: 0.5) : AppColors.error.withValues(alpha: 0.3))
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isUrgent ? 1.5 : 1.0,
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
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.campaign_rounded, size: 14, color: AppColors.errorDark),
                            const SizedBox(width: 4),
                            Text(
                              priority == NoticePriority.urgent ? 'URGENT' : 'IMPORTANT',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.errorDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'NOTICE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    Row(
                      children: [
                        if (hasAttachment) ...[
                          Icon(
                            Icons.attach_file_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          Formatters.date(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
