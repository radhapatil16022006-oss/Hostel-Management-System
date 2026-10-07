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
import '../../widgets/empty_state.dart';
import '../../widgets/fee_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/room_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/student_card.dart';
import '../auth/role_selection_screen.dart';
import '../showcase/design_system_screen.dart';

/// Full Warden / Rector Administration Dashboard with persistent Firestore operations.
class WardenDashboardScreen extends StatefulWidget {
  const WardenDashboardScreen({super.key});

  @override
  State<WardenDashboardScreen> createState() => _WardenDashboardScreenState();
}

class _WardenDashboardScreenState extends State<WardenDashboardScreen> {
  int _currentNavIndex = 0;
  String _studentSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isMobile = Responsive.isMobile(context);
    final authService = Provider.of<AuthService>(context);
    final wardenUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: (isDark ? AppColors.primaryLight : AppColors.primary)
                  .withValues(alpha: 0.15),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                size: 20,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  wardenUser?.fullName ?? 'Hostel Warden',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const Text(
                  'Admin Management Portal',
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
                message: 'Are you sure you want to log out of the Warden Portal?',
                confirmText: 'Sign Out',
              );
              if (confirmed && context.mounted) {
                await authService.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
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
            _buildRoomsTab(context),
            _buildStudentsTab(context),
            _buildFeesTab(context),
            _buildComplaintsTab(context),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room_rounded),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Students',
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
        ],
      ),
    );
  }

  // 1. OVERVIEW TAB
  Widget _buildOverviewTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final isMobile = Responsive.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<StudentModel>>(
      stream: firestoreService.streamStudents(),
      builder: (context, studentsSnap) {
        return StreamBuilder<List<RoomModel>>(
          stream: firestoreService.streamRooms(),
          builder: (context, roomsSnap) {
            return StreamBuilder<List<FeeModel>>(
              stream: firestoreService.streamFees(),
              builder: (context, feesSnap) {
                return StreamBuilder<List<ComplaintModel>>(
                  stream: firestoreService.streamComplaints(),
                  builder: (context, complaintsSnap) {
                    final students = studentsSnap.data ?? [];
                    final rooms = roomsSnap.data ?? [];
                    final fees = feesSnap.data ?? [];
                    final complaints = complaintsSnap.data ?? [];

                    final totalBeds =
                        rooms.fold<int>(0, (sum, r) => sum + r.capacity);
                    final occupiedBeds =
                        rooms.fold<int>(0, (sum, r) => sum + r.occupied);
                    final availableBeds =
                        (totalBeds - occupiedBeds).clamp(0, totalBeds);

                    final pendingFeeTotal = fees.fold<num>(
                        0, (sum, f) => sum + f.pendingAmount);

                    final activeComplaints = complaints
                        .where((c) => c.status != ComplaintStatus.resolved)
                        .length;

                    return ListView(
                      padding: const EdgeInsets.all(AppDimensions.spaceMd),
                      children: [
                        // Quick Welcome Banner
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spaceMd),
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? AppColors.darkCardGradient
                                : AppColors.primaryGradient,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
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
                                  Icons.shield_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spaceMd),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hostel Administration Live',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Cloud Firestore syncing rooms, fees & student records',
                                      style: TextStyle(
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

                        // KPI Cards
                        const SectionHeader(
                          title: 'Live Hostel Statistics',
                          subtitle: 'Real-time aggregated metrics from database',
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
                              title: 'Total Residents',
                              value: '${students.length}',
                              subtitle: '${students.length} admitted',
                              icon: Icons.people_alt_rounded,
                              color: AppColors.primary,
                              onTap: () => setState(() => _currentNavIndex = 2),
                            ),
                            StatCard(
                              title: 'Available Beds',
                              value: '$availableBeds',
                              subtitle: '$occupiedBeds of $totalBeds occupied',
                              icon: Icons.single_bed_rounded,
                              color: AppColors.secondary,
                              onTap: () => setState(() => _currentNavIndex = 1),
                            ),
                            StatCard(
                              title: 'Pending Fees',
                              value: Formatters.currency(pendingFeeTotal),
                              subtitle: '${fees.where((f) => f.pendingAmount > 0).length} students pending',
                              icon: Icons.currency_rupee_rounded,
                              color: AppColors.warning,
                              onTap: () => setState(() => _currentNavIndex = 3),
                            ),
                            StatCard(
                              title: 'Complaints',
                              value: '$activeComplaints',
                              subtitle: 'Active pending tickets',
                              icon: Icons.report_problem_rounded,
                              color: AppColors.error,
                              onTap: () => setState(() => _currentNavIndex = 4),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),

                        // Quick Actions
                        const SectionHeader(
                          title: 'Quick Operations',
                          subtitle: 'Direct shortcuts to common hostel administrative actions',
                        ),
                        Wrap(
                          spacing: AppDimensions.spaceSm,
                          runSpacing: AppDimensions.spaceSm,
                          children: [
                            AppButton(
                              label: 'Allocate Student',
                              icon: Icons.person_add_alt_1_rounded,
                              isFullWidth: false,
                              isSmall: true,
                              onPressed: () => _openAllocateStudentDialog(context),
                            ),
                            AppButton(
                              label: 'Add New Room',
                              variant: AppButtonVariant.secondary,
                              icon: Icons.add_home_work_rounded,
                              isFullWidth: false,
                              isSmall: true,
                              onPressed: () => _openAddRoomDialog(context),
                            ),
                            AppButton(
                              label: 'Record Fee Payment',
                              variant: AppButtonVariant.outline,
                              icon: Icons.payment_rounded,
                              isFullWidth: false,
                              isSmall: true,
                              onPressed: () => _openRecordFeeDialog(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spaceLg),

                        // Recent Room Availability Preview
                        SectionHeader(
                          title: 'Room Occupancy Overview',
                          subtitle: 'Current room capacities and bed counts',
                          actionText: 'View All Rooms',
                          onAction: () => setState(() => _currentNavIndex = 1),
                        ),
                        ...rooms.take(2).map(
                              (r) => RoomCard(
                                roomNumber: r.roomNumber,
                                capacity: r.capacity,
                                occupied: r.occupied,
                                studentNames: r.studentNames,
                                onView: () => setState(() => _currentNavIndex = 1),
                                onAllocate: () => _openAllocateStudentDialog(
                                  context,
                                  preselectedRoomId: r.id,
                                ),
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

  // 2. ROOMS TAB
  Widget _buildRoomsTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder<List<RoomModel>>(
      stream: firestoreService.streamRooms(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingWidget(message: 'Loading hostel rooms...');
        }
        final rooms = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(
                  title: 'Hostel Rooms & Availability',
                  subtitle: 'Manage capacities and student bed allocations',
                ),
                AppButton(
                  label: 'Add Room',
                  icon: Icons.add,
                  isFullWidth: false,
                  isSmall: true,
                  onPressed: () => _openAddRoomDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            if (rooms.isEmpty)
              const EmptyState(
                icon: Icons.meeting_room_outlined,
                title: 'No Rooms Configured',
                description: 'Add your first hostel room to start allocations.',
              )
            else
              ...rooms.map(
                (room) => RoomCard(
                  roomNumber: room.roomNumber,
                  capacity: room.capacity,
                  occupied: room.occupied,
                  studentNames: room.studentNames,
                  onAllocate: room.isFull
                      ? null
                      : () => _openAllocateStudentDialog(
                            context,
                            preselectedRoomId: room.id,
                          ),
                  onView: () => _showRoomDetailsModal(context, room),
                ),
              ),
          ],
        );
      },
    );
  }

  // 3. STUDENTS TAB
  Widget _buildStudentsTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder<List<StudentModel>>(
      stream: firestoreService.streamStudents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingWidget(message: 'Loading student directory...');
        }
        final allStudents = snapshot.data!;
        final filtered = allStudents.where((s) {
          final query = _studentSearchQuery.toLowerCase();
          return s.fullName.toLowerCase().contains(query) ||
              s.branch.toLowerCase().contains(query) ||
              (s.roomNumber ?? '').contains(query);
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          children: [
            const SectionHeader(
              title: 'Student Residents Directory',
              subtitle: 'Active admissions, branches, and contact records',
            ),
            AppTextField(
              hintText: 'Search by student name, branch, or room number...',
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => setState(() => _studentSearchQuery = val),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.person_search_rounded,
                title: 'No Matching Students',
                description: 'Try searching with a different name or room number.',
              )
            else
              ...filtered.map(
                (student) => StudentCard(
                  name: student.fullName,
                  branch: student.branch,
                  year: student.year,
                  roomNumber: student.roomNumber ?? 'Unassigned',
                  phone: student.phone,
                  admissionStatus: student.admissionStatus.name,
                  onView: () => _showStudentProfileModal(context, student),
                ),
              ),
          ],
        );
      },
    );
  }

  // 4. FEES TAB
  Widget _buildFeesTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder<List<FeeModel>>(
      stream: firestoreService.streamFees(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingWidget(message: 'Loading fee balances...');
        }
        final fees = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(
                  title: 'Hostel Fees Ledger',
                  subtitle: 'Resident payments, balances, and transaction logs',
                ),
                AppButton(
                  label: 'Record Payment',
                  icon: Icons.payment_rounded,
                  isFullWidth: false,
                  isSmall: true,
                  onPressed: () => _openRecordFeeDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            if (fees.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No Fee Records',
                description: 'Fee records will appear here as students are admitted.',
              )
            else
              ...fees.map(
                (fee) => FeeCard(
                  studentName: fee.studentName,
                  roomNumber: fee.roomNumber,
                  totalFee: fee.totalFee,
                  paidFee: fee.paidAmount,
                  pendingFee: fee.pendingAmount,
                  status: fee.status.name,
                  onRecordPayment: fee.pendingAmount > 0
                      ? () => _openRecordFeeDialog(
                            context,
                            preselectedStudentId: fee.studentId,
                          )
                      : null,
                  onViewHistory: () => _showFeeHistoryModal(context, fee),
                ),
              ),
          ],
        );
      },
    );
  }

  // 5. COMPLAINTS TAB
  Widget _buildComplaintsTab(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder<List<ComplaintModel>>(
      stream: firestoreService.streamComplaints(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingWidget(message: 'Loading maintenance complaints...');
        }
        final complaints = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          children: [
            const SectionHeader(
              title: 'Resident Maintenance Tickets',
              subtitle: 'Review student issues, update statuses, and submit responses',
            ),
            if (complaints.isEmpty)
              const EmptyState(
                icon: Icons.task_alt_rounded,
                title: 'No Active Complaints',
                description: 'All resident maintenance tickets have been resolved.',
              )
            else
              ...complaints.map(
                (comp) => Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
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
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusSm),
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
                          '${comp.studentName} • Room ${comp.roomNumber ?? "-"} • ${Formatters.date(comp.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        if (comp.rectorResponse != null &&
                            comp.rectorResponse!.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.spaceSm),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.reply_rounded,
                                    size: 16, color: AppColors.successDark),
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
                        const SizedBox(height: AppDimensions.spaceSm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppButton(
                            label: 'Review & Respond',
                            isFullWidth: false,
                            isSmall: true,
                            variant: AppButtonVariant.outline,
                            icon: Icons.edit_note_rounded,
                            onPressed: () =>
                                _openReviewComplaintDialog(context, comp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // MODALS & DIALOGS

  // 1. Student Profile Modal
  void _showStudentProfileModal(BuildContext context, StudentModel student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    student.fullName.isNotEmpty ? student.fullName[0] : 'S',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${student.branch} • ${student.year}',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                StatusBadge.fromStatus(student.admissionStatus.name),
              ],
            ),
            const Divider(height: 28),
            _buildProfileRow('Room Assigned', student.roomNumber != null ? 'Room ${student.roomNumber}' : 'Unassigned'),
            _buildProfileRow('Phone Number', student.phone),
            _buildProfileRow('Email Address', student.email),
            _buildProfileRow('Parent Contact', student.parentPhone),
            _buildProfileRow('Date of Birth', Formatters.date(student.dob)),
            _buildProfileRow('Permanent Address', student.address),
            _buildProfileRow('Admission Date', Formatters.date(student.createdAt)),
            const SizedBox(height: AppDimensions.spaceLg),
            AppButton(
              label: 'Close Profile',
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  // 2. Room Details Modal
  void _showRoomDetailsModal(BuildContext context, RoomModel room) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room ${room.roomNumber} Details',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                StatusBadge(
                  label: room.isFull ? 'FULL' : '${room.availableBeds} Available',
                  type: room.isFull ? BadgeType.error : BadgeType.success,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Floor: ${room.floor} • Capacity: ${room.capacity} Beds • Occupied: ${room.occupied}'),
            if (room.notes != null) ...[
              const SizedBox(height: 6),
              Text('Notes: ${room.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            const Divider(height: 24),
            const Text(
              'Allocated Occupants:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (room.studentNames.isEmpty)
              const Text('No students currently allocated to this room.')
            else
              ...List.generate(room.studentNames.length, (idx) {
                final sName = room.studentNames[idx];
                final sId = room.studentIds.length > idx ? room.studentIds[idx] : '';
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline_rounded),
                  title: Text(sName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: IconButton(
                    icon: const Icon(Icons.person_remove_rounded, color: AppColors.error, size: 20),
                    tooltip: 'Remove from room',
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final confirmed = await ConfirmationDialog.show(
                        context: context,
                        title: 'Remove Student from Room?',
                        message: 'Are you sure you want to remove $sName from Room ${room.roomNumber}?',
                        confirmText: 'Remove',
                        isDestructive: true,
                      );
                      if (confirmed) {
                        await firestoreService.removeStudentFromRoom(
                          roomId: room.id,
                          studentId: sId,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$sName removed from Room ${room.roomNumber}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              }),
            const SizedBox(height: AppDimensions.spaceMd),
            AppButton(
              label: 'Close',
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Allocate Student Dialog
  void _openAllocateStudentDialog(BuildContext context, {String? preselectedRoomId}) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) {
        return StreamBuilder<List<StudentModel>>(
          stream: firestoreService.streamStudents(),
          builder: (context, studSnap) {
            return StreamBuilder<List<RoomModel>>(
              stream: firestoreService.streamRooms(),
              builder: (context, roomSnap) {
                final students = studSnap.data ?? [];
                final rooms = (roomSnap.data ?? []).where((r) => !r.isFull).toList();

                if (students.isEmpty || rooms.isEmpty) {
                  return AlertDialog(
                    title: const Text('Allocation Notice'),
                    content: Text(rooms.isEmpty
                        ? 'All rooms are currently at full capacity.'
                        : 'No student records available.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }

                String selectedStudentId = students.first.id;
                String selectedRoomId = preselectedRoomId ?? rooms.first.id;

                return StatefulBuilder(
                  builder: (context, setModalState) {
                    final selectedStud = students.firstWhere(
                        (s) => s.id == selectedStudentId,
                        orElse: () => students.first);

                    return AlertDialog(
                      title: const Text('Allocate Student to Room'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppDropdown<String>(
                            label: 'Select Student',
                            value: selectedStudentId,
                            items: students
                                .map((s) => DropdownMenuItem(
                                      value: s.id,
                                      child: Text('${s.fullName} (${s.branch.split(' ').first})'),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setModalState(() => selectedStudentId = v!),
                          ),
                          const SizedBox(height: AppDimensions.spaceMd),
                          AppDropdown<String>(
                            label: 'Select Target Room',
                            value: selectedRoomId,
                            items: rooms
                                .map((r) => DropdownMenuItem(
                                      value: r.id,
                                      child: Text('Room ${r.roomNumber} (${r.availableBeds} beds available)'),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setModalState(() => selectedRoomId = v!),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        AppButton(
                          label: 'Allocate Bed',
                          isFullWidth: false,
                          isSmall: true,
                          onPressed: () async {
                            try {
                              await firestoreService.allocateStudentToRoom(
                                roomId: selectedRoomId,
                                studentId: selectedStud.id,
                                studentName: selectedStud.fullName,
                              );
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${selectedStud.fullName} allocated successfully!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
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

  // 4. Add Room Dialog
  void _openAddRoomDialog(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final roomNoCtrl = TextEditingController();
    int capacity = 3;
    int floor = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Create New Hostel Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Room Number',
                hintText: 'e.g. 202',
                controller: roomNoCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.meeting_room_outlined,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AppDropdown<int>(
                label: 'Bed Capacity',
                value: capacity,
                items: [1, 2, 3, 4, 6]
                    .map((c) => DropdownMenuItem(value: c, child: Text('$c Beds')))
                    .toList(),
                onChanged: (v) => setModalState(() => capacity = v!),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AppDropdown<int>(
                label: 'Floor',
                value: floor,
                items: [1, 2, 3, 4]
                    .map((f) => DropdownMenuItem(value: f, child: Text('Floor $f')))
                    .toList(),
                onChanged: (v) => setModalState(() => floor = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            AppButton(
              label: 'Create Room',
              isFullWidth: false,
              isSmall: true,
              onPressed: () async {
                if (roomNoCtrl.text.trim().isEmpty) return;
                final newRoom = RoomModel(
                  id: 'room_${roomNoCtrl.text.trim()}',
                  roomNumber: roomNoCtrl.text.trim(),
                  floor: floor,
                  capacity: capacity,
                  occupied: 0,
                  studentIds: [],
                  studentNames: [],
                  notes: 'Standard residential hostel room',
                );
                await firestoreService.createRoom(newRoom);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Room ${newRoom.roomNumber} created successfully!'),
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

  // 5. Record Fee Payment Dialog
  void _openRecordFeeDialog(BuildContext context, {String? preselectedStudentId}) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final amountCtrl = TextEditingController(text: '10000');
    String paymentMode = 'UPI / Online';

    showDialog(
      context: context,
      builder: (ctx) {
        return StreamBuilder<List<StudentModel>>(
          stream: firestoreService.streamStudents(),
          builder: (context, studSnap) {
            final students = studSnap.data ?? [];
            if (students.isEmpty) {
              return const AlertDialog(
                title: Text('No Students'),
                content: Text('Add students before recording fee payments.'),
              );
            }

            String selectedStudentId = preselectedStudentId ?? students.first.id;

            return StatefulBuilder(
              builder: (context, setModalState) => AlertDialog(
                title: const Text('Record Fee Payment'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppDropdown<String>(
                      label: 'Student',
                      value: selectedStudentId,
                      items: students
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text('${s.fullName} (Room ${s.roomNumber ?? "-"})'),
                              ))
                          .toList(),
                      onChanged: (v) => setModalState(() => selectedStudentId = v!),
                    ),
                    const SizedBox(height: AppDimensions.spaceMd),
                    AppTextField(
                      label: 'Amount Paid (₹)',
                      hintText: 'e.g. 15000',
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee_rounded,
                    ),
                    const SizedBox(height: AppDimensions.spaceMd),
                    AppDropdown<String>(
                      label: 'Payment Mode',
                      value: paymentMode,
                      items: ['UPI / Online', 'Cash', 'Net Banking', 'Demand Draft']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setModalState(() => paymentMode = v!),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  AppButton(
                    label: 'Record Payment',
                    isFullWidth: false,
                    isSmall: true,
                    onPressed: () async {
                      final amount = num.tryParse(amountCtrl.text.trim()) ?? 0;
                      if (amount <= 0) return;

                      await firestoreService.recordFeePayment(
                        studentId: selectedStudentId,
                        amount: amount,
                        paymentMode: paymentMode,
                      );
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment of ₹$amount recorded successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 6. Fee History Modal
  void _showFeeHistoryModal(BuildContext context, FeeModel fee) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${fee.studentName} - Payment History',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text('Total Fee: ${Formatters.currency(fee.totalFee)} • Paid: ${Formatters.currency(fee.paidAmount)} • Pending: ${Formatters.currency(fee.pendingAmount)}'),
            const Divider(height: 24),
            if (fee.transactions.isEmpty)
              const Text('No payment transactions recorded yet.')
            else
              ...fee.transactions.map((t) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                    title: Text(Formatters.currency(t.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${t.paymentMode} • ${Formatters.date(t.date)}'),
                    trailing: Text(t.receiptNumber ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  )),
            const SizedBox(height: AppDimensions.spaceMd),
            AppButton(
              label: 'Close',
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  // 7. Review & Respond to Complaint Dialog
  void _openReviewComplaintDialog(BuildContext context, ComplaintModel comp) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final responseCtrl = TextEditingController(text: comp.rectorResponse ?? '');
    ComplaintStatus selectedStatus = comp.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Review Complaint: ${comp.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resident: ${comp.studentName} (Room ${comp.roomNumber ?? "-"})',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Text(comp.description, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const Divider(height: 24),
              AppDropdown<ComplaintStatus>(
                label: 'Update Status',
                value: selectedStatus,
                items: ComplaintStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedStatus = v!),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              AppTextField(
                label: 'Official Warden Response',
                hintText: 'e.g. Electrician scheduled for maintenance...',
                controller: responseCtrl,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            AppButton(
              label: 'Update Ticket',
              isFullWidth: false,
              isSmall: true,
              onPressed: () async {
                await firestoreService.updateComplaintStatus(
                  complaintId: comp.id,
                  status: selectedStatus,
                  rectorResponse: responseCtrl.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complaint status and response updated!'),
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
