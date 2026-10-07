import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import 'status_badge.dart';

/// Reusable card displaying student summary info with actions.
class StudentCard extends StatelessWidget {
  final String name;
  final String branch;
  final String year;
  final String roomNumber;
  final String phone;
  final String admissionStatus;
  final String? profileImageUrl;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onMoreOptions;

  const StudentCard({
    super.key,
    required this.name,
    required this.branch,
    required this.year,
    required this.roomNumber,
    required this.phone,
    required this.admissionStatus,
    this.profileImageUrl,
    this.onView,
    this.onEdit,
    this.onMoreOptions,
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
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: (isDark ? AppColors.primaryLight : AppColors.primary)
                      .withValues(alpha: 0.12),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge.fromStatus(admissionStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$branch • $year',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 14,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Room $roomNumber',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onView != null || onEdit != null || onMoreOptions != null) ...[
              const SizedBox(height: AppDimensions.spaceSm),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onView != null)
                    TextButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('View', style: TextStyle(fontSize: 13)),
                    ),
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit', style: TextStyle(fontSize: 13)),
                    ),
                  if (onMoreOptions != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 18),
                      onPressed: onMoreOptions,
                      tooltip: 'More options',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
