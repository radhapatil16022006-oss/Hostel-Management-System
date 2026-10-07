import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import 'status_badge.dart';

/// Reusable card displaying room statistics, student allocations, and actions.
class RoomCard extends StatelessWidget {
  final String roomNumber;
  final int capacity;
  final int occupied;
  final List<String> studentNames;
  final VoidCallback? onView;
  final VoidCallback? onAllocate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RoomCard({
    super.key,
    required this.roomNumber,
    required this.capacity,
    required this.occupied,
    this.studentNames = const [],
    this.onView,
    this.onAllocate,
    this.onEdit,
    this.onDelete,
  });

  int get available => (capacity - occupied).clamp(0, capacity);
  bool get isFull => occupied >= capacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final statusText = isFull ? 'Full' : '$available Available';
    final badgeType = isFull ? BadgeType.error : BadgeType.success;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryLight : AppColors.primary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Icon(
                        Icons.meeting_room_rounded,
                        size: 20,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceSm),
                    Text(
                      'ROOM $roomNumber',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                StatusBadge(label: statusText, type: badgeType),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Row(
              children: [
                _buildMetric(
                  context,
                  label: 'Capacity',
                  value: '$capacity',
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                _buildMetric(
                  context,
                  label: 'Occupied',
                  value: '$occupied',
                  color: isFull ? AppColors.error : AppColors.warning,
                ),
                _buildMetric(
                  context,
                  label: 'Available',
                  value: '$available',
                  color: available > 0 ? AppColors.success : AppColors.error,
                ),
              ],
            ),
            if (studentNames.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spaceSm),
              Text(
                'Occupants:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: studentNames
                    .map(
                      (name) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
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
                if (!isFull && onAllocate != null)
                  TextButton.icon(
                    onPressed: onAllocate,
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                    label:
                        const Text('Allocate', style: TextStyle(fontSize: 13)),
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: onEdit,
                    tooltip: 'Edit room',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.error),
                    onPressed: onDelete,
                    tooltip: 'Delete room',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
