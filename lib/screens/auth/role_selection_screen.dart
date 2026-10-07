import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive.dart';
import 'warden_login_screen.dart';
import 'student_login_screen.dart';
import '../showcase/design_system_screen.dart';

/// Role selection gateway for Warden and Student portals.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          // Shortcut to Phase 1 Showcase so design system is always accessible
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DesignSystemScreen()),
              );
            },
            icon: const Icon(Icons.palette_outlined, size: 16),
            label: const Text('Showcase', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContentContainer(
        maxWidth: 720,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLg,
            vertical: AppDimensions.spaceXl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo / Icon header
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  boxShadow: AppDimensions.mediumShadow,
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLg),
              Text(
                AppStrings.selectRolePrompt,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceSm),
              Text(
                AppStrings.selectRoleSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space2xl),

              // Large Role Cards
              _buildRoleCard(
                context,
                title: 'Warden / Rector',
                subtitle: 'Hostel administrator portal',
                description:
                    'Manage room allocations, student admissions, verify fee records, and resolve maintenance complaints.',
                icon: Icons.admin_panel_settings_rounded,
                badgeLabel: 'ADMIN ACCESS',
                accentColor: isDark ? AppColors.primaryLight : AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WardenLoginScreen()),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.spaceMd),

              _buildRoleCard(
                context,
                title: 'Student Resident',
                subtitle: 'Hostel resident portal',
                description:
                    'Access your room details, monitor pending fees, review hostel menu, and submit maintenance tickets.',
                icon: Icons.school_rounded,
                badgeLabel: 'RESIDENT PORTAL',
                accentColor: AppColors.secondary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required String badgeLabel,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
            boxShadow: isDark ? null : AppDimensions.softShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Icon(icon, color: accentColor, size: 30),
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
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
