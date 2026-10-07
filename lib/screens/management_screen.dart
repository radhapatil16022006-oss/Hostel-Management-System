import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/theme_provider.dart';
import '../core/utils/formatters.dart';
import '../models/attendance_model.dart';
import '../models/complaint_model.dart';
import '../models/fee_model.dart';
import '../models/mess_model.dart';
import '../models/room_model.dart';
import '../models/student_model.dart';
import '../models/user_model.dart';
import '../services/hostel_store.dart';
import '../widgets/complaint_card.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/fee_card.dart';
import '../widgets/notice_card.dart';
import '../widgets/room_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';
import '../widgets/student_card.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({
    super.key,
    required this.user,
    required this.section,
    required this.onNavigate,
  });

  final UserModel user;
  final String section;
  final ValueChanged<String> onNavigate;

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final _searchController = TextEditingController();
  String _studentYear = 'All years';
  bool get _isAdmin => widget.user.role == UserRole.rector;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HostelStore>();
    return switch (widget.section) {
      'students' => _studentsPage(store),
      'rooms' || 'room' => _roomsPage(store),
      'fees' => _feesPage(store),
      'complaints' => _complaintsPage(store),
      'notices' => _noticesPage(store),
      'attendance' => _attendancePage(store),
      'visitors' => _visitorsPage(store),
      'mess' => _messPage(store),
      'reports' => _reportsPage(store),
      'profile' || 'settings' => _profilePage(store),
      _ => _morePage(),
    };
  }

  Widget _studentsPage(HostelStore store) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = store.students.where((student) {
      final matchesQuery =
          query.isEmpty ||
          student.fullName.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.phone.contains(query) ||
          student.roomNumber?.contains(query) == true;
      return matchesQuery &&
          (_studentYear == 'All years' || student.year == _studentYear);
    }).toList();
    return _page(
      title: 'Student directory',
      subtitle: '${store.students.length} enrolled residents',
      action: _isAdmin
          ? ('Add student', Icons.person_add_alt_1_rounded, _addStudent)
          : null,
      children: [
        _searchField('Search by name, room or contact'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _studentYear,
          decoration: const InputDecoration(labelText: 'Academic year'),
          items: ['All years', ...AppConstants.academicYears]
              .map((year) => DropdownMenuItem(value: year, child: Text(year)))
              .toList(),
          onChanged: (value) =>
              setState(() => _studentYear = value ?? 'All years'),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          const EmptyState(
            icon: Icons.groups_2_outlined,
            title: 'No students found',
            description: 'Try another search or year filter.',
          )
        else
          for (final student in filtered)
            StudentCard(
              name: student.fullName,
              branch: student.branch,
              year: student.year,
              roomNumber: student.roomNumber ?? 'Unassigned',
              phone: student.phone,
              admissionStatus: student.accountStatus.name,
              onView: () => _showStudentDetails(student, store),
              onEdit: _isAdmin ? () => _editStudent(student) : null,
              onMoreOptions: _isAdmin
                  ? () => _studentActions(student, store)
                  : null,
            ),
      ],
    );
  }

  Widget _roomsPage(HostelStore store) {
    return _page(
      title: _isAdmin ? 'Room inventory' : 'My room',
      subtitle: _isAdmin
          ? '${store.rooms.length} rooms · ${store.availableBeds} beds available'
          : 'Room and roommate information',
      action: _isAdmin
          ? ('Add room', Icons.add_home_work_outlined, _addRoom)
          : null,
      children: [
        if (store.rooms.isEmpty)
          const EmptyState(
            icon: Icons.meeting_room_outlined,
            title: 'No rooms yet',
            description: 'Add rooms to begin assigning residents.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 960
                  ? 3
                  : constraints.maxWidth > 580
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _isAdmin
                    ? store.rooms.length
                    : store.rooms
                          .where(
                            (room) => room.studentIds.contains(widget.user.id),
                          )
                          .length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: columns == 1 ? 300 : 286,
                ),
                itemBuilder: (context, index) {
                  final rooms = _isAdmin
                      ? store.rooms
                      : store.rooms
                            .where(
                              (room) =>
                                  room.studentIds.contains(widget.user.id),
                            )
                            .toList();
                  final room = rooms[index];
                  return RoomCard(
                    roomNumber: room.roomNumber,
                    capacity: room.capacity,
                    occupied: room.occupied,
                    studentNames: room.studentNames,
                    onView: () => _showRoomDetails(room),
                    onAllocate: _isAdmin
                        ? () => _allocateStudent(room, store)
                        : null,
                    onEdit: _isAdmin ? () => _editRoom(room) : null,
                    onDelete: _isAdmin ? () => _deleteRoom(room, store) : null,
                  );
                },
              );
            },
          ),
        if (!_isAdmin && store.roomForStudent(widget.user.id) == null)
          const EmptyState(
            icon: Icons.meeting_room_outlined,
            title: 'Room not assigned',
            description: 'Please contact the warden for your room allocation.',
          ),
      ],
    );
  }

  Widget _feesPage(HostelStore store) {
    final fees = _isAdmin
        ? store.fees
        : store.fees.where((fee) => fee.studentId == widget.user.id).toList();
    return _page(
      title: _isAdmin ? 'Fee management' : 'My fee account',
      subtitle: _isAdmin
          ? '${Formatters.currency(store.pendingFees)} outstanding across all accounts'
          : 'Academic year 2026-27',
      children: [
        if (fees.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No fee records',
            description: 'Fee information will appear here once available.',
          )
        else
          for (final fee in fees)
            FeeCard(
              studentName: fee.studentName,
              roomNumber: fee.roomNumber,
              totalFee: fee.totalFee,
              paidFee: fee.paidAmount,
              pendingFee: fee.pendingAmount,
              status: _feeLabel(fee.status),
              onRecordPayment: _isAdmin && fee.pendingAmount > 0
                  ? () => _recordPayment(fee)
                  : null,
              onViewHistory: () =>
                  _showPaymentHistory(fee.studentName, fee.transactions),
            ),
      ],
    );
  }

  Widget _complaintsPage(HostelStore store) {
    final complaints = _isAdmin
        ? store.complaints
        : store.complaints
              .where((item) => item.studentId == widget.user.id)
              .toList();
    return _page(
      title: _isAdmin ? 'Complaint desk' : 'My requests',
      subtitle: _isAdmin
          ? '${store.activeComplaints} open requests'
          : 'Submit a request and follow its progress',
      action: !_isAdmin
          ? ('New request', Icons.add_comment_outlined, _addComplaint)
          : null,
      children: [
        if (complaints.isEmpty)
          EmptyState(
            icon: Icons.support_agent_outlined,
            title: 'No complaints here',
            description: _isAdmin
                ? 'New student requests will appear here.'
                : 'Your submitted requests will appear here.',
            actionLabel: !_isAdmin ? 'Submit request' : null,
            onAction: !_isAdmin ? _addComplaint : null,
          )
        else
          for (final complaint in complaints)
            Column(
              children: [
                ComplaintCard(
                  title: complaint.title,
                  category: complaint.category,
                  description: complaint.description,
                  status: _complaintLabel(complaint.status),
                  date: complaint.createdAt,
                  studentName: _isAdmin ? complaint.studentName : null,
                  roomNumber: complaint.roomNumber,
                  rectorResponse: complaint.rectorResponse,
                  onTap: () => _complaintActions(complaint, store),
                ),
                if (_isAdmin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DropdownButton<ComplaintStatus>(
                        value: complaint.status,
                        isDense: true,
                        underline: const SizedBox.shrink(),
                        onChanged: (value) {
                          if (value != null) {
                            store.updateComplaintStatus(complaint.id, value);
                          }
                        },
                        items: ComplaintStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(_complaintLabel(status)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
              ],
            ),
      ],
    );
  }

  Widget _noticesPage(HostelStore store) {
    return _page(
      title: 'Notice board',
      subtitle: 'Announcements for hostel residents',
      action: _isAdmin
          ? ('Post notice', Icons.campaign_outlined, _addNotice)
          : null,
      children: [
        if (store.notices.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'No notices',
            description: 'There are no announcements to display.',
          )
        else
          for (final notice in store.notices)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NoticeCard(
                      title: notice.title,
                      description: notice.description,
                      date: notice.date,
                      priority: notice.priority,
                      hasAttachment: notice.hasAttachment,
                    ),
                  ),
                  if (_isAdmin)
                    IconButton(
                      tooltip: 'Delete notice',
                      onPressed: () => _deleteNotice(notice.id, store),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _attendancePage(HostelStore store) {
    final records = _isAdmin
        ? store.students
        : store.students
              .where((student) => student.id == widget.user.id)
              .toList();
    return _page(
      title: 'Attendance',
      subtitle: 'Today · ${DateFormat('EEEE, d MMMM').format(DateTime.now())}',
      children: [
        if (!_isAdmin)
          _AttendanceStudentSummary(store: store, studentId: widget.user.id)
        else
          ...records.map((student) {
            final record = store.attendance.firstWhere(
              (item) =>
                  item.studentId == student.id &&
                  _isSameDay(item.date, DateTime.now()),
              orElse: () => AttendanceModel(
                id: 'absent_${student.id}',
                studentId: student.id,
                studentName: student.fullName,
                date: DateTime.now(),
                status: AttendanceStatus.absent,
                markedBy: 'Not marked',
              ),
            );
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(student.fullName[0])),
                title: Text(student.fullName),
                subtitle: Text(
                  'Room ${student.roomNumber ?? '-'} · ${student.branch}',
                ),
                trailing: SegmentedButton<AttendanceStatus>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: AttendanceStatus.present,
                      label: Text('Present'),
                    ),
                    ButtonSegment(
                      value: AttendanceStatus.absent,
                      label: Text('Absent'),
                    ),
                  ],
                  selected: {record.status},
                  onSelectionChanged: (value) =>
                      store.markAttendance(student.id, value.first),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _visitorsPage(HostelStore store) {
    final visitors = _isAdmin
        ? store.visitors
        : store.visitors
              .where((visitor) => visitor.studentId == widget.user.id)
              .toList();
    return _page(
      title: 'Visitor register',
      subtitle: _isAdmin
          ? '${visitors.where((item) => !item.hasExited).length} visitors currently checked in'
          : 'Visitor records linked to your account',
      action: _isAdmin
          ? ('Record visitor', Icons.person_add_alt_rounded, _addVisitor)
          : null,
      children: [
        if (visitors.isEmpty)
          const EmptyState(
            icon: Icons.badge_outlined,
            title: 'No visitor records',
            description: 'There are no visitor entries to show.',
          )
        else
          for (final visitor in visitors)
            Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(visitor.visitorName[0].toUpperCase()),
                ),
                title: Text(visitor.visitorName),
                subtitle: Text(
                  '${visitor.relation} of ${visitor.studentName} · ${visitor.entryTime} in${visitor.hasExited ? ' · ${visitor.exitTime} out' : ''}',
                ),
                isThreeLine: true,
                trailing: visitor.hasExited
                    ? const StatusBadge(
                        label: 'Checked out',
                        type: BadgeType.neutral,
                      )
                    : _isAdmin
                    ? TextButton(
                        onPressed: () => store.recordVisitorExit(visitor.id),
                        child: const Text('Check out'),
                      )
                    : const StatusBadge(
                        label: 'On site',
                        type: BadgeType.success,
                      ),
                onTap: () => _showInfo('Visit purpose', visitor.purpose),
              ),
            ),
      ],
    );
  }

  Widget _messPage(HostelStore store) {
    final menu = store.todayMenu;
    return _page(
      title: 'Mess & dining',
      subtitle:
          '${menu.dayOfWeek} menu · Updated ${Formatters.date(menu.updatedAt)}',
      action: _isAdmin ? ('Edit menu', Icons.edit_outlined, _editMenu) : null,
      children: [
        for (final meal in [
          (
            'Breakfast',
            menu.breakfast,
            Icons.wb_twilight_rounded,
            '7:00 – 9:00 AM',
          ),
          ('Lunch', menu.lunch, Icons.wb_sunny_outlined, '12:30 – 2:30 PM'),
          ('Dinner', menu.dinner, Icons.nights_stay_outlined, '7:30 – 9:30 PM'),
        ])
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: Icon(
                meal.$3,
                size: 28,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              title: Text(
                meal.$1,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${meal.$2}\n${meal.$4}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              isThreeLine: true,
            ),
          ),
        const SizedBox(height: 12),
        const SectionHeader(
          title: 'Dining hours',
          subtitle:
              'The dining hall closes 15 minutes after each serving window.',
        ),
      ],
    );
  }

  Widget _reportsPage(HostelStore store) {
    final capacity = store.rooms.fold<int>(
      0,
      (sum, room) => sum + room.capacity,
    );
    final present = store.attendance
        .where(
          (item) =>
              item.status == AttendanceStatus.present &&
              _isSameDay(item.date, DateTime.now()),
        )
        .length;
    final metrics = [
      ('Residents', '${store.students.length}', Icons.groups_2_outlined),
      ('Beds filled', '${store.occupiedBeds} / $capacity', Icons.bed_outlined),
      (
        'Fee collection',
        Formatters.currency(
          store.fees.fold<num>(0, (sum, fee) => sum + fee.paidAmount),
        ),
        Icons.payments_outlined,
      ),
      (
        'Attendance today',
        '$present / ${store.students.length}',
        Icons.fact_check_outlined,
      ),
      (
        'Open requests',
        '${store.activeComplaints}',
        Icons.support_agent_outlined,
      ),
      (
        'Pending fee balance',
        Formatters.currency(store.pendingFees),
        Icons.currency_rupee_rounded,
      ),
    ];
    return _page(
      title: 'Reports',
      subtitle: 'Live summary based on current presentation data',
      action: (
        'Copy summary',
        Icons.content_copy_rounded,
        () => _copyReport(metrics),
      ),
      children: [
        for (final metric in metrics)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(metric.$3),
              title: Text(metric.$1),
              trailing: Text(
                metric.$2,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }

  Widget _profilePage(HostelStore store) {
    final student = store.studentById(widget.user.id);
    return _page(
      title: _isAdmin ? 'Warden profile' : 'My profile',
      subtitle: 'Account and residence details',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    widget.user.fullName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user.fullName,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Role',
                  value: _isAdmin ? 'Admin / Warden' : 'Student',
                ),
                _DetailRow(label: 'Username', value: widget.user.username),
                _DetailRow(label: 'Phone', value: widget.user.phone),
                if (student != null) ...[
                  _DetailRow(label: 'Email', value: student.email),
                  _DetailRow(label: 'Course', value: student.branch),
                  _DetailRow(label: 'Academic year', value: student.year),
                  _DetailRow(
                    label: 'Room',
                    value: student.roomNumber ?? 'Not allocated',
                  ),
                ],
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark appearance'),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _morePage() {
    final sections = _isAdmin
        ? const [
            (
              'complaints',
              'Complaints',
              'Review and update student requests',
              Icons.support_agent_outlined,
            ),
            (
              'attendance',
              'Attendance',
              'Mark and review daily attendance',
              Icons.fact_check_outlined,
            ),
            (
              'visitors',
              'Visitors',
              'Maintain the entry and exit register',
              Icons.badge_outlined,
            ),
            (
              'notices',
              'Notices',
              'Publish hostel-wide announcements',
              Icons.campaign_outlined,
            ),
            (
              'mess',
              'Mess information',
              'Update and view daily meal menus',
              Icons.restaurant_outlined,
            ),
            (
              'reports',
              'Reports',
              'Review occupancy, fees and attendance',
              Icons.analytics_outlined,
            ),
            (
              'profile',
              'Profile & settings',
              'Account details and appearance',
              Icons.settings_outlined,
            ),
          ]
        : const [
            (
              'attendance',
              'Attendance',
              'Review your attendance record',
              Icons.fact_check_outlined,
            ),
            (
              'visitors',
              'Visitors',
              'View visitor records',
              Icons.badge_outlined,
            ),
            (
              'notices',
              'Notices',
              'Read hostel announcements',
              Icons.campaign_outlined,
            ),
            (
              'mess',
              'Mess information',
              'Today’s dining menu',
              Icons.restaurant_outlined,
            ),
            (
              'profile',
              'My profile',
              'Account and residence details',
              Icons.person_outline,
            ),
          ];
    return _page(
      title: 'More',
      subtitle: 'Hostel services and information',
      children: [
        for (final item in sections)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(item.$4),
              title: Text(item.$2),
              subtitle: Text(item.$3),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => widget.onNavigate(item.$1),
            ),
          ),
      ],
    );
  }

  Widget _page({
    required String title,
    required String subtitle,
    required List<Widget> children,
    (String, IconData, VoidCallback)? action,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SectionHeader(title: title, subtitle: subtitle),
            ),
            if (action != null)
              IconButton.filledTonal(
                tooltip: action.$1,
                onPressed: action.$3,
                icon: Icon(action.$2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _searchField(String hint) => TextField(
    controller: _searchController,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _searchController.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close_rounded),
            ),
    ),
  );

  Future<void> _addStudent() async {
    final result = await showDialog<StudentModel>(
      context: context,
      builder: (_) => const _StudentFormDialog(),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().addStudent(
      fullName: result.fullName,
      phone: result.phone,
      email: result.email,
      branch: result.branch,
      year: result.year,
    );
    _toast('Student added');
  }

  Future<void> _editStudent(StudentModel student) async {
    final result = await showDialog<StudentModel>(
      context: context,
      builder: (_) => _StudentFormDialog(student: student),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().updateStudent(result);
    _toast('Student details updated');
  }

  Future<void> _showStudentDetails(
    StudentModel student,
    HostelStore store,
  ) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(student.fullName),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Student ID', value: student.id),
            _DetailRow(label: 'Email', value: student.email),
            _DetailRow(label: 'Phone', value: student.phone),
            _DetailRow(label: 'Course', value: student.branch),
            _DetailRow(label: 'Year', value: student.year),
            _DetailRow(
              label: 'Room',
              value:
                  store.roomForStudent(student.id)?.roomNumber ?? 'Unassigned',
            ),
            _DetailRow(
              label: 'Address',
              value: student.address.isEmpty ? 'Not provided' : student.address,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _studentActions(StudentModel student, HostelStore store) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit student'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text('Delete student'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'edit') await _editStudent(student);
    if (action == 'delete' && mounted) {
      final confirmed = await ConfirmationDialog.show(
        context: context,
        title: 'Delete student?',
        message:
            'This removes ${student.fullName} and their local fee and attendance records.',
        confirmText: 'Delete',
        isDestructive: true,
      );
      if (confirmed && mounted) store.deleteStudent(student.id);
    }
  }

  Future<void> _addRoom() async {
    final result = await showDialog<RoomModel>(
      context: context,
      builder: (_) => const _RoomFormDialog(),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().addRoom(
      roomNumber: result.roomNumber,
      floor: result.floor,
      capacity: result.capacity,
    );
  }

  Future<void> _editRoom(RoomModel room) async {
    final result = await showDialog<RoomModel>(
      context: context,
      builder: (_) => _RoomFormDialog(room: room),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().updateRoom(result);
  }

  Future<void> _deleteRoom(RoomModel room, HostelStore store) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete room ${room.roomNumber}?',
      message: room.occupied > 0
          ? 'Deallocate all residents before deleting this room.'
          : 'This room will be removed from the local inventory.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      if (room.occupied == 0) {
        store.deleteRoom(room.id);
      } else {
        _toast('Room must be empty before it can be deleted');
      }
    }
  }

  Future<void> _allocateStudent(RoomModel room, HostelStore store) async {
    final availableStudents = store.students
        .where((student) => !room.studentIds.contains(student.id))
        .toList();
    if (availableStudents.isEmpty) {
      _toast('All students already have a room');
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => _ChoiceDialog<String>(
        title: 'Allocate to room ${room.roomNumber}',
        choices: availableStudents
            .map(
              (student) =>
                  (student.id, '${student.fullName} · ${student.year}'),
            )
            .toList(),
      ),
    );
    if (selected == null || !mounted) return;
    final success = store.allocateStudent(room.id, selected);
    _toast(
      success ? 'Room allocation updated' : 'Unable to allocate this student',
    );
  }

  Future<void> _showRoomDetails(RoomModel room) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Room ${room.roomNumber}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Floor', value: '${room.floor}'),
          _DetailRow(
            label: 'Occupancy',
            value: '${room.occupied} / ${room.capacity}',
          ),
          _DetailRow(label: 'Available beds', value: '${room.availableBeds}'),
          const SizedBox(height: 10),
          Text('Residents', style: Theme.of(context).textTheme.titleSmall),
          for (var index = 0; index < room.studentIds.length; index++)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(room.studentNames[index]),
              trailing: _isAdmin
                  ? IconButton(
                      tooltip: 'Deallocate',
                      icon: const Icon(Icons.person_remove_outlined),
                      onPressed: () {
                        context.read<HostelStore>().deallocateStudent(
                          room.id,
                          room.studentIds[index],
                        );
                        Navigator.pop(context);
                      },
                    )
                  : null,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _recordPayment(FeeModel fee) async {
    final result = await showDialog<(num, String)>(
      context: context,
      builder: (_) => _PaymentFormDialog(maxAmount: fee.pendingAmount),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().recordFeePayment(fee.id, result.$1, result.$2);
    _toast('Payment recorded');
  }

  Future<void> _showPaymentHistory(
    String studentName,
    List<FeePaymentTransaction> transactions,
  ) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$studentName · payments'),
      content: SizedBox(
        width: 440,
        child: transactions.isEmpty
            ? const Text('No payments recorded yet.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final transaction in transactions)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(Formatters.currency(transaction.amount)),
                      subtitle: Text(
                        '${Formatters.date(transaction.date)} · ${transaction.paymentMode}',
                      ),
                      trailing: Text(transaction.receiptNumber ?? ''),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  Future<void> _addComplaint() async {
    final result = await showDialog<(String, String, String)>(
      context: context,
      builder: (_) => const _ComplaintFormDialog(),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().addComplaint(
      studentId: widget.user.id,
      title: result.$1,
      description: result.$2,
      category: result.$3,
    );
    _toast('Request submitted');
  }

  Future<void> _complaintActions(
    ComplaintModel complaint,
    HostelStore store,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(complaint.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(complaint.description),
            const SizedBox(height: 14),
            StatusBadge(label: _complaintLabel(complaint.status)),
            if (_isAdmin) ...[
              const SizedBox(height: 14),
              const Text('Update status'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  for (final status in ComplaintStatus.values)
                    ActionChip(
                      label: Text(_complaintLabel(status)),
                      onPressed: () {
                        store.updateComplaintStatus(complaint.id, status);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ],
            if (complaint.rectorResponse != null) ...[
              const SizedBox(height: 12),
              Text('Warden response: ${complaint.rectorResponse}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNotice() async {
    final result = await showDialog<(String, String, NoticePriority)>(
      context: context,
      builder: (_) => const _NoticeFormDialog(),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().addNotice(
      title: result.$1,
      description: result.$2,
      priority: result.$3,
    );
  }

  Future<void> _deleteNotice(String id, HostelStore store) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete notice?',
      message: 'This announcement will be removed from the notice board.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) store.deleteNotice(id);
  }

  Future<void> _addVisitor() async {
    final result = await showDialog<(String, String, String, String)>(
      context: context,
      builder: (_) =>
          _VisitorFormDialog(students: context.read<HostelStore>().students),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().addVisitor(
      visitorName: result.$1,
      studentId: result.$2,
      relation: result.$3,
      purpose: result.$4,
    );
  }

  Future<void> _editMenu() async {
    final result = await showDialog<(String, String, String)>(
      context: context,
      builder: (_) =>
          _MessFormDialog(menu: context.read<HostelStore>().todayMenu),
    );
    if (result == null || !mounted) return;
    context.read<HostelStore>().updateTodayMenu(
      breakfast: result.$1,
      lunch: result.$2,
      dinner: result.$3,
    );
  }

  Future<void> _copyReport(List<(String, String, IconData)> metrics) async {
    await Clipboard.setData(
      ClipboardData(
        text: metrics.map((item) => '${item.$1}: ${item.$2}').join('\n'),
      ),
    );
    if (mounted) _toast('Report summary copied');
  }

  Future<void> _showInfo(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  void _toast(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  String _feeLabel(FeeStatus status) => switch (status) {
    FeeStatus.paid => 'Paid',
    FeeStatus.partiallyPaid => 'Partially paid',
    FeeStatus.pending => 'Pending',
  };

  String _complaintLabel(ComplaintStatus status) => switch (status) {
    ComplaintStatus.pending => 'Pending',
    ComplaintStatus.inProgress => 'In progress',
    ComplaintStatus.resolved => 'Resolved',
  };

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _StudentFormDialog extends StatefulWidget {
  const _StudentFormDialog({this.student});

  final StudentModel? student;

  @override
  State<_StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<_StudentFormDialog> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.student?.fullName ?? '',
  );
  late final _phone = TextEditingController(text: widget.student?.phone ?? '');
  late final _email = TextEditingController(text: widget.student?.email ?? '');
  late final _branch = widget.student?.branch ?? AppConstants.branches.first;
  late final _year = widget.student?.year ?? AppConstants.academicYears.first;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.student == null ? 'Add student' : 'Edit student'),
    content: SizedBox(
      width: 460,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone number'),
                validator: (value) => value == null || value.trim().length < 10
                    ? 'Enter a valid phone number'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _branch,
                decoration: const InputDecoration(labelText: 'Course'),
                items: AppConstants.branches
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedBranch = value ?? _branch),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _year,
                decoration: const InputDecoration(labelText: 'Academic year'),
                items: AppConstants.academicYears
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedYear = value ?? _year),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );

  late String _selectedBranch = _branch;
  late String _selectedYear = _year;

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  void _save() {
    if (!_key.currentState!.validate()) return;
    final old = widget.student;
    Navigator.pop(
      context,
      StudentModel(
        id: old?.id ?? 'new_student',
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        parentPhone: old?.parentPhone ?? '',
        branch: _selectedBranch,
        year: _selectedYear,
        address: old?.address ?? '',
        roomNumber: old?.roomNumber,
        username: old?.username ?? _email.text.trim(),
        admissionStatus: old?.admissionStatus ?? AdmissionStatus.newAdmission,
        accountStatus: old?.accountStatus ?? AccountStatus.active,
        createdAt: old?.createdAt ?? DateTime.now(),
      ),
    );
  }
}

class _RoomFormDialog extends StatefulWidget {
  const _RoomFormDialog({this.room});

  final RoomModel? room;

  @override
  State<_RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<_RoomFormDialog> {
  final _key = GlobalKey<FormState>();
  late final _number = TextEditingController(
    text: widget.room?.roomNumber ?? '',
  );
  late final _floor = TextEditingController(text: '${widget.room?.floor ?? 1}');
  late int _capacity = widget.room?.capacity ?? 2;

  @override
  void dispose() {
    _number.dispose();
    _floor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.room == null ? 'Add room' : 'Edit room'),
    content: SizedBox(
      width: 380,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _number,
              enabled: widget.room == null,
              decoration: const InputDecoration(labelText: 'Room number'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a room number'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _floor,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Floor'),
              validator: (value) => int.tryParse(value ?? '') == null
                  ? 'Enter a valid floor'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _capacity,
              decoration: const InputDecoration(labelText: 'Bed capacity'),
              items: AppConstants.roomCapacities
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text('$value beds'),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _capacity = value ?? _capacity),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );

  void _save() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(
      context,
      RoomModel(
        id: widget.room?.id ?? 'new_room',
        roomNumber: _number.text.trim(),
        floor: int.parse(_floor.text),
        capacity: _capacity,
        occupied: widget.room?.occupied ?? 0,
        studentIds: widget.room?.studentIds ?? const [],
        studentNames: widget.room?.studentNames ?? const [],
      ),
    );
  }
}

class _PaymentFormDialog extends StatefulWidget {
  const _PaymentFormDialog({required this.maxAmount});

  final num maxAmount;

  @override
  State<_PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<_PaymentFormDialog> {
  final _key = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String _mode = AppConstants.paymentModes.first;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Record payment'),
    content: SizedBox(
      width: 360,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Outstanding: ${Formatters.currency(widget.maxAmount)}'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) {
                final amount = num.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                if (amount > widget.maxAmount) {
                  return 'Amount exceeds the outstanding balance';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _mode,
              decoration: const InputDecoration(labelText: 'Payment method'),
              items: AppConstants.paymentModes
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _mode = value ?? _mode),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Record')),
    ],
  );

  void _save() {
    if (_key.currentState!.validate()) {
      Navigator.pop(context, (num.parse(_amount.text), _mode));
    }
  }
}

class _ComplaintFormDialog extends StatefulWidget {
  const _ComplaintFormDialog();

  @override
  State<_ComplaintFormDialog> createState() => _ComplaintFormDialogState();
}

class _ComplaintFormDialogState extends State<_ComplaintFormDialog> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _category = AppConstants.complaintCategories.first;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Submit a request'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Subject'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: AppConstants.complaintCategories
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Details'),
              validator: _required,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_key.currentState!.validate()) {
            Navigator.pop(context, (
              _title.text.trim(),
              _description.text.trim(),
              _category,
            ));
          }
        },
        child: const Text('Submit'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}

class _NoticeFormDialog extends StatefulWidget {
  const _NoticeFormDialog();

  @override
  State<_NoticeFormDialog> createState() => _NoticeFormDialogState();
}

class _NoticeFormDialogState extends State<_NoticeFormDialog> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  NoticePriority _priority = NoticePriority.medium;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Post announcement'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Announcement'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<NoticePriority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: NoticePriority.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _priority = value ?? _priority),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_key.currentState!.validate()) {
            Navigator.pop(context, (
              _title.text.trim(),
              _description.text.trim(),
              _priority,
            ));
          }
        },
        child: const Text('Post'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}

class _VisitorFormDialog extends StatefulWidget {
  const _VisitorFormDialog({required this.students});

  final List<StudentModel> students;

  @override
  State<_VisitorFormDialog> createState() => _VisitorFormDialogState();
}

class _VisitorFormDialogState extends State<_VisitorFormDialog> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _purpose = TextEditingController();
  late String _student = widget.students.first.id;
  String _relation = 'Parent';

  @override
  void dispose() {
    _name.dispose();
    _purpose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Record visitor'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Visitor name'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _student,
              decoration: const InputDecoration(labelText: 'Visiting student'),
              items: widget.students
                  .map(
                    (value) => DropdownMenuItem(
                      value: value.id,
                      child: Text(value.fullName),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _student = value ?? _student),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _relation,
              decoration: const InputDecoration(labelText: 'Relationship'),
              items: ['Parent', 'Sibling', 'Relative', 'Friend', 'Other']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _relation = value ?? _relation),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _purpose,
              decoration: const InputDecoration(labelText: 'Purpose'),
              validator: _required,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_key.currentState!.validate()) {
            Navigator.pop(context, (
              _name.text.trim(),
              _student,
              _relation,
              _purpose.text.trim(),
            ));
          }
        },
        child: const Text('Save entry'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}

class _MessFormDialog extends StatefulWidget {
  const _MessFormDialog({required this.menu});

  final MessMenuModel menu;

  @override
  State<_MessFormDialog> createState() => _MessFormDialogState();
}

class _MessFormDialogState extends State<_MessFormDialog> {
  final _key = GlobalKey<FormState>();
  late final _breakfast = TextEditingController(text: widget.menu.breakfast);
  late final _lunch = TextEditingController(text: widget.menu.lunch);
  late final _dinner = TextEditingController(text: widget.menu.dinner);

  @override
  void dispose() {
    _breakfast.dispose();
    _lunch.dispose();
    _dinner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit today’s menu'),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _breakfast,
              decoration: const InputDecoration(labelText: 'Breakfast'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lunch,
              decoration: const InputDecoration(labelText: 'Lunch'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dinner,
              decoration: const InputDecoration(labelText: 'Dinner'),
              validator: _required,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_key.currentState!.validate()) {
            Navigator.pop(context, (
              _breakfast.text.trim(),
              _lunch.text.trim(),
              _dinner.text.trim(),
            ));
          }
        },
        child: const Text('Save menu'),
      ),
    ],
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}

class _ChoiceDialog<T> extends StatelessWidget {
  const _ChoiceDialog({required this.title, required this.choices});

  final String title;
  final List<(T, String)> choices;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title),
    content: SizedBox(
      width: 420,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: choices.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(choices[index].$2),
          onTap: () => Navigator.pop(context, choices[index].$1),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ],
  );
}

class _AttendanceStudentSummary extends StatelessWidget {
  const _AttendanceStudentSummary({
    required this.store,
    required this.studentId,
  });

  final HostelStore store;
  final String studentId;

  @override
  Widget build(BuildContext context) {
    final records = store.attendance
        .where((item) => item.studentId == studentId)
        .toList();
    final present = records
        .where((item) => item.status == AttendanceStatus.present)
        .length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            Text(
              '$present of ${records.length} recorded days present',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: records.isEmpty ? 0 : present / records.length,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance is marked daily by your warden.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
