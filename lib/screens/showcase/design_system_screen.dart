import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fee_card.dart';
import '../../widgets/notice_card.dart';
import '../../widgets/room_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/student_card.dart';
import '../../widgets/complaint_card.dart';

/// Phase 1 Showcase & Preview screen demonstrating the entire design system,
/// theme switching, responsive behavior, and reusable component library.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  final _demoTextController = TextEditingController(text: 'Rahul Deshmukh');
  final _demoPasswordController = TextEditingController(text: 'SecretPass123');
  String? _selectedBranch = AppConstants.branches.first;
  bool _isButtonLoading = false;

  @override
  void dispose() {
    _demoTextController.dispose();
    _demoPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryLight : AppColors.primary)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(
                Icons.apartment_rounded,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Phase 1 Architecture & Design System',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Switcher Button
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContentContainer(
        child: ListView(
          padding: EdgeInsets.all(isMobile ? AppDimensions.spaceMd : AppDimensions.spaceLg),
          children: [
            // Status Banner
            _buildStatusBanner(context, isDark, isMobile, isTablet),
            const SizedBox(height: AppDimensions.spaceLg),

            // Statistics / KPI Grid
            const SectionHeader(
              title: 'Dashboard Metrics & KPI Cards',
              subtitle: 'Material 3 interactive statistics cards',
            ),
            _buildStatCardsGrid(context),
            const SizedBox(height: AppDimensions.spaceLg),

            // Color Palette
            const SectionHeader(
              title: 'Design System Color Palette',
              subtitle: 'Semantic branding tokens and accents',
            ),
            _buildColorPalette(context, isDark),
            const SizedBox(height: AppDimensions.spaceLg),

            // Form Components
            const SectionHeader(
              title: 'Form Inputs & Controls',
              subtitle: 'Inputs with validation, password toggle & dropdowns',
            ),
            _buildFormInputs(context, isDark),
            const SizedBox(height: AppDimensions.spaceLg),

            // Buttons & Actions
            const SectionHeader(
              title: 'AppButton System',
              subtitle: 'Multi-variant buttons with loading states',
            ),
            _buildButtonsSection(context),
            const SizedBox(height: AppDimensions.spaceLg),

            // Status Badges
            const SectionHeader(
              title: 'Status Indicators & Badges',
              subtitle: 'Categorical and semantic status pills',
            ),
            _buildBadgesSection(context),
            const SizedBox(height: AppDimensions.spaceLg),

            // Complex Components
            const SectionHeader(
              title: 'Domain Component Cards',
              subtitle: 'Reusable cards for Students, Rooms, Fees & Complaints',
            ),
            _buildComplexCardsSection(context),
            const SizedBox(height: AppDimensions.spaceLg),

            // Dialog Interaction Demo
            const SectionHeader(
              title: 'Confirmation Dialogs',
              subtitle: 'Destructive operation confirmation with feedback',
            ),
            _buildDialogDemo(context),
            const SizedBox(height: AppDimensions.spaceLg),

            // Empty State Component Demo
            const SectionHeader(
              title: 'Empty State View',
              subtitle: 'Clean UX placeholder when zero records exist',
            ),
            _buildEmptyStateDemo(context),
            const SizedBox(height: AppDimensions.space2xl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
    BuildContext context,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    final screenType = isMobile
        ? 'Mobile Phone (< 600px)'
        : isTablet
            ? 'Tablet (600px - 1024px)'
            : 'Desktop / Large Screen (> 1024px)';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 22,
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
                    const Expanded(
                      child: Text(
                        'Phase 1: Project Setup & Design System Ready',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: isDark ? 'DARK MODE' : 'LIGHT MODE',
                      type: BadgeType.info,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Clean architecture initialized. M3 Theme, constants, responsive layouts, '
                  'reusable widgets, domain models, and service contracts are all active.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.devices_rounded, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Viewport: $screenType',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsGrid(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final stats = [
      const StatCard(
        title: 'Total Students',
        value: '128',
        subtitle: '+8 this month',
        icon: Icons.people_alt_rounded,
        color: AppColors.primary,
      ),
      const StatCard(
        title: 'Rooms',
        value: '42',
        subtitle: '35 occupied',
        icon: Icons.meeting_room_rounded,
        color: AppColors.secondary,
      ),
      const StatCard(
        title: 'Pending Fees',
        value: '₹85,000',
        subtitle: '14 unpaid records',
        icon: Icons.currency_rupee_rounded,
        color: AppColors.warning,
      ),
      const StatCard(
        title: 'Complaints',
        value: '7',
        subtitle: '3 urgent tickets',
        icon: Icons.report_problem_rounded,
        color: AppColors.error,
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: AppDimensions.spaceSm,
        mainAxisSpacing: AppDimensions.spaceSm,
        childAspectRatio: isMobile ? 1.2 : 1.3,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => stats[index],
    );
  }

  Widget _buildColorPalette(BuildContext context, bool isDark) {
    final colors = [
      {'name': 'Primary Indigo', 'color': AppColors.primary, 'hex': '#1E3A8A'},
      {'name': 'Primary Light', 'color': AppColors.primaryLight, 'hex': '#3B82F6'},
      {'name': 'Secondary Teal', 'color': AppColors.secondary, 'hex': '#0D9488'},
      {'name': 'Success Emerald', 'color': AppColors.success, 'hex': '#10B981'},
      {'name': 'Warning Amber', 'color': AppColors.warning, 'hex': '#F59E0B'},
      {'name': 'Error Crimson', 'color': AppColors.error, 'hex': '#EF4444'},
    ];

    return Wrap(
      spacing: AppDimensions.spaceSm,
      runSpacing: AppDimensions.spaceSm,
      children: colors.map((item) {
        final color = item['color'] as Color;
        return Container(
          width: 110,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['name'] as String,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item['hex'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFormInputs(BuildContext context, bool isDark) {
    return DashboardCard(
      title: 'Interactive Form Elements',
      child: Column(
        children: [
          AppTextField(
            label: 'Full Name',
            hintText: 'Enter student full name',
            controller: _demoTextController,
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          AppTextField(
            label: 'Password',
            hintText: 'Enter account password',
            controller: _demoPasswordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          AppDropdown<String>(
            label: 'Branch / Department',
            hintText: 'Select student branch',
            value: _selectedBranch,
            prefixIcon: Icons.school_outlined,
            items: AppConstants.branches
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (val) => setState(() => _selectedBranch = val),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spaceSm,
      runSpacing: AppDimensions.spaceSm,
      children: [
        SizedBox(
          width: 160,
          child: AppButton(
            label: 'Primary Button',
            icon: Icons.check_circle_outline,
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 160,
          child: AppButton(
            label: 'Secondary',
            variant: AppButtonVariant.secondary,
            icon: Icons.tune_rounded,
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 160,
          child: AppButton(
            label: 'Outline',
            variant: AppButtonVariant.outline,
            icon: Icons.edit_outlined,
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 160,
          child: AppButton(
            label: 'Danger',
            variant: AppButtonVariant.danger,
            icon: Icons.delete_outline,
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 160,
          child: AppButton(
            label: 'Loading State',
            isLoading: _isButtonLoading,
            onPressed: () async {
              setState(() => _isButtonLoading = true);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) setState(() => _isButtonLoading = false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        StatusBadge.fromStatus('Paid'),
        StatusBadge.fromStatus('Pending'),
        StatusBadge.fromStatus('Partially Paid'),
        StatusBadge.fromStatus('Present'),
        StatusBadge.fromStatus('Absent'),
        StatusBadge.fromStatus('Approved'),
        StatusBadge.fromStatus('Rejected'),
        StatusBadge.fromStatus('In Progress'),
        StatusBadge.fromStatus('Active'),
        StatusBadge.fromStatus('Inactive'),
      ],
    );
  }

  Widget _buildComplexCardsSection(BuildContext context) {
    return Column(
      children: [
        // Student Card Demo
        StudentCard(
          name: 'Priya Sharma',
          branch: 'Computer Science & Engineering',
          year: 'Second Year (SE)',
          roomNumber: '101',
          phone: '9876543210',
          admissionStatus: 'New Admission',
          onView: () {},
          onEdit: () {},
          onMoreOptions: () {},
        ),
        const SizedBox(height: AppDimensions.spaceSm),

        // Room Card Demo
        RoomCard(
          roomNumber: '101',
          capacity: 3,
          occupied: 2,
          studentNames: const ['Priya Sharma', 'Ananya Patel'],
          onView: () {},
          onAllocate: () {},
          onEdit: () {},
        ),
        const SizedBox(height: AppDimensions.spaceSm),

        // Fee Card Demo
        FeeCard(
          studentName: 'Priya Sharma',
          roomNumber: '101',
          totalFee: 50000,
          paidFee: 30000,
          pendingFee: 20000,
          status: 'Partially Paid',
          onRecordPayment: () {},
          onViewHistory: () {},
        ),
        const SizedBox(height: AppDimensions.spaceSm),

        // Complaint Card Demo
        ComplaintCard(
          title: 'Ceiling Fan Not Working in Room 101',
          category: 'Electricity',
          description:
              'The ceiling fan regulator sparks and does not spin at speed 3 and 4.',
          status: 'In Progress',
          date: DateTime.now().subtract(const Duration(days: 1)),
          studentName: 'Priya Sharma',
          roomNumber: '101',
          rectorResponse: 'Electrician has been assigned for inspection today at 4 PM.',
          onTap: () {},
        ),
        const SizedBox(height: AppDimensions.spaceSm),

        // Notice Card Demo
        NoticeCard(
          title: 'Hostel Night Curfew & Gate Timing Reminder',
          description:
              'All residents must return to the hostel premises by 9:00 PM. Gate entry logs will be strictly verified with biometrics.',
          date: DateTime.now(),
          priority: NoticePriority.urgent,
          hasAttachment: true,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildDialogDemo(BuildContext context) {
    return DashboardCard(
      title: 'Modal & Dialog System',
      subtitle: 'Test animated confirmation dialogs with callbacks',
      child: AppButton(
        label: 'Open Destructive Confirmation Dialog',
        variant: AppButtonVariant.outline,
        icon: Icons.warning_amber_rounded,
        onPressed: () async {
          final confirmed = await ConfirmationDialog.show(
            context: context,
            title: 'Deactivate Student Account?',
            message:
                'Are you sure you want to deactivate Rahul Deshmukh? The student will not be able to log in to the hostel portal until reactivated.',
            confirmText: 'Deactivate',
            isDestructive: true,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  confirmed ? 'Student deactivated successfully' : 'Action cancelled',
                ),
                backgroundColor: confirmed ? AppColors.error : AppColors.primary,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyStateDemo(BuildContext context) {
    return const DashboardCard(
      child: EmptyState(
        icon: Icons.group_off_rounded,
        title: 'No Students Found',
        description:
            'No matching student admissions found for the selected filter criteria. Try adjusting your search query.',
        actionLabel: 'Reset Filters',
      ),
    );
  }
}
