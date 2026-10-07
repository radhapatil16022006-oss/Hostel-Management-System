import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/utils/formatters.dart';
import 'status_badge.dart';

/// Reusable card displaying fee records, payment balances, and status.
class FeeCard extends StatelessWidget {
  final String studentName;
  final String? roomNumber;
  final num totalFee;
  final num paidFee;
  final num pendingFee;
  final String status;
  final VoidCallback? onRecordPayment;
  final VoidCallback? onViewHistory;

  const FeeCard({
    super.key,
    required this.studentName,
    this.roomNumber,
    required this.totalFee,
    required this.paidFee,
    required this.pendingFee,
    required this.status,
    this.onRecordPayment,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress = totalFee > 0 ? (paidFee / totalFee).clamp(0.0, 1.0) : 0.0;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (roomNumber != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Room $roomNumber',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                StatusBadge.fromStatus(status),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Row(
              children: [
                _buildFeeItem('Total Fee', Formatters.currency(totalFee),
                    isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                _buildFeeItem('Paid', Formatters.currency(paidFee), AppColors.success),
                _buildFeeItem('Pending', Formatters.currency(pendingFee),
                    pendingFee > 0 ? AppColors.error : AppColors.success),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}% Paid',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            if (onRecordPayment != null || onViewHistory != null) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onViewHistory != null)
                    TextButton.icon(
                      onPressed: onViewHistory,
                      icon: const Icon(Icons.history_rounded, size: 16),
                      label: const Text('History', style: TextStyle(fontSize: 13)),
                    ),
                  if (pendingFee > 0 && onRecordPayment != null)
                    TextButton.icon(
                      onPressed: onRecordPayment,
                      icon: const Icon(Icons.payment_rounded, size: 16),
                      label: const Text('Record Payment',
                          style: TextStyle(fontSize: 13)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeeItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
