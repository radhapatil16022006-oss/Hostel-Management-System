import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/complaint_model.dart';
import '../../models/fee_model.dart';
import '../../models/room_model.dart';
import '../../models/student_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fee_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../auth/role_selection_screen.dart';
import '../showcase/design_system_screen.dart';

/// Student Resident Dashboard with live room, fee, complaint, and profile status.
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              child: const Icon(
                Icons.school_rounded,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentUser?.fullName ?? 'Student Resident',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Resident Portal',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Showcase shortcut
          IconButton(
            tooltip: 'Design System Showcase',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DesignSystemScreen()),
              );
            },
            icon: const Icon(Icons.palette_outlined, size: 20),
          ),
          // Theme Switcher
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : AppColors.primary,
              size: 20,
            ),
          ),
          // Logout Button
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context: context,
                title: 'Sign Out?',
                message:
                    'Are you sure you want to log out of the Student Portal?',
                confirmText: 'Sign Out',
              );
              if (confirmed && context.mounted) {
                await authService.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 20),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ResponsiveContentContainer(
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            _buildOverviewTab(context),
            _buildRoomTab(context),
            _buildFeesTab(context),
            _buildComplaintsTab(context),
            _buildProfileTab(context),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room_rounded),
            label: 'Room',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Fees',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem_rounded),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // 1. HOME / OVERVIEW TAB
  Widget _buildOverviewTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser?.id ?? 'student_01';
    final isMobile = Responsive.isMobile(context);

    return StreamBuilder<List<StudentModel>>(
      stream: firestoreService.streamStudents(),
      builder: (context, studSnap) {
        final students = studSnap.data ?? [];
        final me = students.firstWhere(
          (s) =>
              s.id == currentUserId ||
              s.username == authService.currentUser?.username,
          orElse: () => students.isNotEmpty
              ? students.first
              : StudentModel(
                  id: 'demo',
                  fullName: 'Rahul Deshmukh',
                  phone: '9876543210',
                  email: 'rahul@hostel.com',
                  parentPhone: '9811223344',
                  branch: 'Computer Science',
                  year: 'Second Year (SE)',
                  address: 'Pune',
                  roomNumber: '101',
                  username: 'rahul',
                  createdAt: DateTime(2025, 1, 1),
                ),
        );

        return StreamBuilder<List<RoomModel>>(
          stream: firestoreService.streamRooms(),
          builder: (context, roomSnap) {
            final rooms = roomSnap.data ?? [];
            final myRoom = rooms.firstWhere(
              (r) => r.roomNumber == me.roomNumber,
              orElse: () => const RoomModel(
                id: 'none',
                roomNumber: '101',
                capacity: 3,
                occupied: 2,
                studentNames: ['Rahul Deshmukh', 'Priya Sharma'],
              ),
            );

            return StreamBuilder<FeeModel?>(
              stream: firestoreService.streamFeeForStudent(me.id),
              builder: (context, feeSnap) {
                final myFee = feeSnap.data;
                final paid = myFee?.paidAmount ?? 30000;
                final pending = myFee?.pendingAmount ?? 20000;

                return StreamBuilder<List<ComplaintModel>>(
                  stream: firestoreService.streamComplaintsForStudent(me.id),
                  builder: (context, compSnap) {
                    final myComplaints = compSnap.data ?? [];
                    final activeComp = myComplaints
                        .where((c) => c.status != ComplaintStatus.resolved)
                        .length;

                    return ListView(
                      padding: const EdgeInsets.all(AppDimensions.spaceMd),
                      children: [
                        // Welcome Resident Banner
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spaceMd),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLg,
                            ),
                            boxShadow: AppDimensions.softShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spaceMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back, ${me.fullName}!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Room ${me.roomNumber ?? "Not allocated"} • ${me.branch}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),

                        // Metric summary grid
                        const SectionHeader(
                          title: 'My Residency Overview',
                          subtitle:
                              'Live room, fee balance, and ticket statuses',
                        ),
                        GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: isMobile ? 2 : 4,
                          crossAxisSpacing: AppDimensions.spaceSm,
                          mainAxisSpacing: AppDimensions.spaceSm,
                          childAspectRatio: isMobile ? 1.2 : 1.3,
                          children: [
                            StatCard(
                              title: 'My Room',
                              value: 'Room ${me.roomNumber ?? "-"}',
                              subtitle:
                                  '${myRoom.occupied} of ${myRoom.capacity} beds',
                              icon: Icons.meeting_room_rounded,
                              color: AppColors.primary,
                              onTap: () => setState(() => _currentNavIndex = 1),
                            ),
                            StatCard(
                              title: 'Attendance',
                              value: '88.9%',
                              subtitle: '24 present, 3 absent',
                              icon: Icons.fact_check_rounded,
                              color: AppColors.success,
                            ),
                            StatCard(
                              title: 'Pending Fee',
                              value: Formatters.currency(pending),
                              subtitle: '${Formatters.currency(paid)} paid',
                              icon: Icons.currency_rupee_rounded,
                              color: pending > 0
                                  ? AppColors.warning
                                  : AppColors.success,
                              onTap: () => setState(() => _currentNavIndex = 2),
                            ),
                            StatCard(
                              title: 'My Tickets',
                              value: '$activeComp',
                              subtitle: 'Active complaints',
                              icon: Icons.report_problem_rounded,
                              color: activeComp > 0
                                  ? AppColors.error
                                  : AppColors.secondary,
                              onTap: () => setState(() => _currentNavIndex = 3),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),

                        // Quick Actions
                        const SectionHeader(
                          title: 'Quick Resident Actions',
                          subtitle: 'Submit requests directly to warden office',
                        ),
                        Wrap(
                          spacing: AppDimensions.spaceSm,
                          runSpacing: AppDimensions.spaceSm,
                          children: [
                            AppButton(
                              label: 'Submit Complaint',
                              icon: Icons.add_comment_rounded,
                              isFullWidth: false,
                              isSmall: true,
                              onPressed: () =>
                                  _openSubmitComplaintDialog(context, me),
                            ),
                            AppButton(
                              label: 'View Roommates',
                              variant: AppButtonVariant.secondary,
                              icon: Icons.group_rounded,
                              isFullWidth: false,
                              isSmall: true,
                              onPressed: () =>
                                  setState(() => _currentNavIndex = 1),
                            ),
                            AppButton(
                              label: 'Payment Ledger',
                              variant: AppButtonVariant.outline,
                              icon: Icons.receipt_long_rounded,
                              isFullWidth: false,
                              isSmall: true,
                              onPressed: () =>
                                  setState(() => _currentNavIndex = 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),

                        // Today's Mess Menu Card
                        DashboardCard(
                          title: "Today's Mess Menu",
                          subtitle: 'Daily breakfast, lunch, and dinner meal schedule',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMealRow(
                                'Breakfast',
                                'Poha + Tea / Milk (7:30 AM - 9:00 AM)',
                              ),
                              const Divider(height: 16),
                              _buildMealRow(
                                'Lunch',
                                'Rice + Dal Tadka + Paneer Sabzi + Chapati (12:30 PM - 2:00 PM)',
                              ),
                              const Divider(height: 16),
                              _buildMealRow(
                                'Dinner',
                                'Chapati + Mixed Veg + Jeera Rice + Kheer (8:00 PM - 9:30 PM)',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMealRow(String title, String items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMd),
        Expanded(
          child: Text(
            items,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // 2. ROOM TAB
  Widget _buildRoomTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser?.id ?? 'student_01';

    return StreamBuilder<List<StudentModel>>(
      stream: firestoreService.streamStudents(),
      builder: (context, studSnap) {
        final students = studSnap.data ?? [];
        final me = students.firstWhere(
          (s) =>
              s.id == currentUserId ||
              s.username == authService.currentUser?.username,
          orElse: () => students.isNotEmpty
              ? students.first
              : StudentModel(
                  id: 'demo',
                  fullName: 'Rahul Deshmukh',
                  phone: '9876543210',
                  email: 'rahul@hostel.com',
                  parentPhone: '9811223344',
                  branch: 'Computer Science',
                  year: 'Second Year (SE)',
                  address: 'Pune',
                  roomNumber: '101',
                  username: 'rahul',
                  createdAt: DateTime(2025, 1, 1),
                ),
        );

        return StreamBuilder<List<RoomModel>>(
          stream: firestoreService.streamRooms(),
          builder: (context, roomSnap) {
            final rooms = roomSnap.data ?? [];
            final myRoom = rooms.firstWhere(
              (r) => r.roomNumber == me.roomNumber,
              orElse: () => const RoomModel(
                id: '101',
                roomNumber: '101',
                floor: 1,
                capacity: 3,
                occupied: 2,
                studentNames: ['Rahul Deshmukh', 'Priya Sharma'],
                notes: 'East wing room with balcony',
              ),
            );

            final roommates = myRoom.studentNames
                .where((n) => n != me.fullName)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              children: [
                const SectionHeader(
                  title: 'My Room Information',
                  subtitle: 'Room assignment and occupant details',
                ),
                DashboardCard(
                  title: 'Room ${myRoom.roomNumber}',
                  subtitle:
                      'Floor ${myRoom.floor} • ${myRoom.capacity} Bed Capacity',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRoomMetric('Total Beds', '${myRoom.capacity}'),
                          _buildRoomMetric('Occupied', '${myRoom.occupied}'),
                          _buildRoomMetric(
                            'Available',
                            '${myRoom.availableBeds}',
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text(
                        'My Roommates:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (roommates.isEmpty)
                        const Text(
                          'No other roommates allocated in this room yet.',
                        )
                      else
                        ...roommates.map(
                          (name) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                name[0],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text('Roommate Resident'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),

                // Hostel Room Guidelines
                const DashboardCard(
                  title: 'Hostel Room Guidelines',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Keep room and common corridors clean and tidy.'),
                      SizedBox(height: 4),
                      Text('• Night quiet hours begin at 10:30 PM.'),
                      SizedBox(height: 4),
                      Text(
                        '• For any electrical or plumbing repairs, submit a complaint in the tickets tab.',
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Room switching requests must be formally submitted to Warden.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRoomMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  // 3. FEES TAB
  Widget _buildFeesTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser?.id ?? 'student_01';

    return StreamBuilder<FeeModel?>(
      stream: firestoreService.streamFeeForStudent(currentUserId),
      builder: (context, snapshot) {
        final fee =
            snapshot.data ??
            FeeModel(
              id: 'fee_demo',
              studentId: currentUserId,
              studentName: authService.currentUser?.fullName ?? 'Student',
              roomNumber: '101',
              academicYear: '2025-2026',
              totalFee: 50000,
              paidAmount: 30000,
              transactions: [
                FeePaymentTransaction(
                  id: 'tx_01',
                  amount: 30000,
                  date: DateTime.now().subtract(const Duration(days: 30)),
                  paymentMode: 'UPI / Online',
                  receiptNumber: 'REC-2025-001',
                ),
              ],
            );

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          children: [
            const SectionHeader(
              title: 'My Hostel Fees & Payments',
              subtitle:
                  'Transparent fee status, balance, and transaction history',
            ),
            FeeCard(
              studentName: fee.studentName,
              roomNumber: fee.roomNumber,
              totalFee: fee.totalFee,
              paidFee: fee.paidAmount,
              pendingFee: fee.pendingAmount,
              status: fee.status.name,
            ),
            const SizedBox(height: AppDimensions.spaceLg),

            const SectionHeader(
              title: 'Official Payment Receipts',
              subtitle:
                  'Verified transactions recorded by warden administration',
            ),
            if (fee.transactions.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No Payments Yet',
                description:
                    'Payment receipts will appear once approved by Warden.',
              )
            else
              ...fee.transactions.map(
                (tx) => Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                    ),
                    title: Text(
                      Formatters.currency(tx.amount),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${tx.paymentMode} • ${Formatters.date(tx.date)}',
                    ),
                    trailing: Text(
                      tx.receiptNumber ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // 4. COMPLAINTS TAB
  Widget _buildComplaintsTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser?.id ?? 'student_01';

    return StreamBuilder<List<StudentModel>>(
      stream: firestoreService.streamStudents(),
      builder: (context, studSnap) {
        final students = studSnap.data ?? [];
        final me = students.firstWhere(
          (s) =>
              s.id == currentUserId ||
              s.username == authService.currentUser?.username,
          orElse: () => students.isNotEmpty
              ? students.first
              : StudentModel(
                  id: 'demo',
                  fullName: 'Rahul Deshmukh',
                  phone: '9876543210',
                  email: 'rahul@hostel.com',
                  parentPhone: '9811223344',
                  branch: 'Computer Science',
                  year: 'Second Year (SE)',
                  address: 'Pune',
                  roomNumber: '101',
                  username: 'rahul',
                  createdAt: DateTime(2025, 1, 1),
                ),
        );

        return StreamBuilder<List<ComplaintModel>>(
          stream: firestoreService.streamComplaintsForStudent(me.id),
          builder: (context, snapshot) {
            final complaints = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionHeader(
                      title: 'My Maintenance Complaints',
                      subtitle: 'Track resolution status & warden replies',
                    ),
                    AppButton(
                      label: 'File Ticket',
                      icon: Icons.add_rounded,
                      isFullWidth: false,
                      isSmall: true,
                      onPressed: () => _openSubmitComplaintDialog(context, me),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                if (complaints.isEmpty)
                  EmptyState(
                    icon: Icons.task_alt_rounded,
                    title: 'No Complaints Submitted',
                    description: 'Need plumbing, electricity, or mess maintenance? Submit a ticket.',
                    actionLabel: 'Submit Complaint',
                    onAction: () => _openSubmitComplaintDialog(context, me),
                  )
                else
                  ...complaints.map(
                    (comp) => Card(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.spaceSm,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusSm,
                                    ),
                                  ),
                                  child: Text(
                                    comp.category.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                StatusBadge.fromStatus(comp.status.name),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spaceSm),
                            Text(
                              comp.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              comp.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceSm),
                            Text(
                              'Submitted on ${Formatters.date(comp.createdAt)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            if (comp.rectorResponse != null &&
                                comp.rectorResponse!.isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.spaceSm),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.reply_rounded,
                                      size: 16,
                                      color: AppColors.successDark,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Warden reply: ${comp.rectorResponse}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.successDark,
                                          fontWeight: FontWeight.w600,
                                        ),
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
              ],
            );
          },
        );
      },
    );
  }

  // 5. PROFILE TAB
  Widget _buildProfileTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.currentUser?.id ?? 'student_01';

    return StreamBuilder<List<StudentModel>>(
      stream: firestoreService.streamStudents(),
      builder: (context, snapshot) {
        final students = snapshot.data ?? [];
        final me = students.firstWhere(
          (s) =>
              s.id == currentUserId ||
              s.username == authService.currentUser?.username,
          orElse: () => students.isNotEmpty
              ? students.first
              : StudentModel(
                  id: 'demo',
                  fullName: 'Rahul Deshmukh',
                  phone: '9876543210',
                  email: 'rahul@hostel.com',
                  parentPhone: '9811223344',
                  branch: 'Computer Science & Engineering',
                  year: 'Second Year (SE)',
                  address: 'Pune, Maharashtra',
                  roomNumber: '101',
                  username: 'rahul',
                  createdAt: DateTime(2025, 1, 1),
                ),
        );

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  me.fullName.isNotEmpty ? me.fullName[0] : 'S',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Center(
              child: Text(
                me.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Center(
              child: Text(
                '${me.branch} • ${me.year}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLg),

            DashboardCard(
              title: 'Resident Information',
              child: Column(
                children: [
                  _buildProfileRow(
                    'Allocated Room',
                    me.roomNumber != null
                        ? 'Room ${me.roomNumber}'
                        : 'Not Allocated',
                  ),
                  _buildProfileRow('Mobile Number', me.phone),
                  _buildProfileRow('Email ID', me.email),
                  _buildProfileRow('Parent Mobile', me.parentPhone),
                  _buildProfileRow('Date of Birth', Formatters.date(me.dob)),
                  _buildProfileRow('Permanent Address', me.address),
                  _buildProfileRow('Admission Status', me.admissionStatus.name),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // DIALOGS

  void _openSubmitComplaintDialog(BuildContext context, StudentModel me) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Room';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Submit Maintenance Complaint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Title',
                hintText: 'e.g. Bathroom tap leaking',
                controller: titleCtrl,
                prefixIcon: Icons.title_rounded,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AppDropdown<String>(
                label: 'Category',
                value: category,
                items: AppConstants.complaintCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setModalState(() => category = v!),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AppTextField(
                label: 'Description',
                hintText: 'Describe the issue clearly...',
                controller: descCtrl,
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            AppButton(
              label: 'Submit Ticket',
              isFullWidth: false,
              isSmall: true,
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty ||
                    descCtrl.text.trim().isEmpty) {
                  return;
                }

                final newComplaint = ComplaintModel(
                  id: 'cmp_${DateTime.now().millisecondsSinceEpoch}',
                  studentId: me.id,
                  studentName: me.fullName,
                  roomNumber: me.roomNumber,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  category: category,
                  status: ComplaintStatus.pending,
                  createdAt: DateTime.now(),
                );

                await firestoreService.submitComplaint(newComplaint);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Maintenance ticket submitted successfully!',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
