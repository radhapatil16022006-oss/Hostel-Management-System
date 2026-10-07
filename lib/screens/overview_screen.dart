import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/student_model.dart';
import '../models/user_model.dart';
import '../services/hostel_store.dart';
import '../widgets/complaint_card.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/notice_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  final UserModel user;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HostelStore>();
    final isAdmin = user.role == UserRole.rector;
    final student = store.studentById(user.id);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final columns = screenWidth >= 1200
        ? 3
        : screenWidth >= 600
        ? 2
        : 2;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        _WelcomeStrip(user: user, isAdmin: isAdmin),
        const SizedBox(height: 22),
        if (isAdmin) ...[
          _MetricGrid(
            columns: columns,
            items: [
              _Metric(
                'Total students',
                '${store.students.length}',
                'Active residents',
                Icons.groups_2_outlined,
                const Color(0xFF276B63),
                () => onNavigate('students'),
              ),
              _Metric(
                'Total rooms',
                '${store.rooms.length}',
                '${store.occupiedBeds} beds occupied',
                Icons.meeting_room_outlined,
                const Color(0xFF4778A8),
                () => onNavigate('rooms'),
              ),
              _Metric(
                'Occupied rooms',
                '${store.rooms.where((room) => room.occupied > 0).length}',
                '${store.availableBeds} beds available',
                Icons.bed_outlined,
                const Color(0xFF967035),
                () => onNavigate('rooms'),
              ),
              _Metric(
                'Available rooms',
                '${store.availableRooms}',
                'With an open bed',
                Icons.door_front_door_outlined,
                const Color(0xFF43866E),
                () => onNavigate('rooms'),
              ),
              _Metric(
                'Pending fees',
                Formatters.currency(store.pendingFees),
                '${store.fees.where((fee) => fee.pendingAmount > 0).length} accounts due',
                Icons.currency_rupee_rounded,
                const Color(0xFFAD6947),
                () => onNavigate('fees'),
              ),
              _Metric(
                'Active complaints',
                '${store.activeComplaints}',
                '${store.pendingComplaintCount} need review',
                Icons.support_agent_outlined,
                const Color(0xFF9B5362),
                () => onNavigate('complaints'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeading(
            title: 'At a glance',
            action: 'Reports',
            onPressed: () => onNavigate('reports'),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 760;
              final occupancy = _OccupancySummary(store: store);
              final attendance = _AttendanceSummary(store: store);
              if (!wide) {
                return Column(
                  children: [occupancy, const SizedBox(height: 12), attendance],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: occupancy),
                  const SizedBox(width: 14),
                  Expanded(child: attendance),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          _SectionHeading(
            title: 'Needs attention',
            action: 'All complaints',
            onPressed: () => onNavigate('complaints'),
          ),
          const SizedBox(height: 10),
          if (store.complaints.isEmpty)
            const _InlineEmpty(
              icon: Icons.check_circle_outline,
              text: 'No active complaints',
            )
          else
            ...store.complaints
                .take(2)
                .map(
                  (complaint) => ComplaintCard(
                    title: complaint.title,
                    category: complaint.category,
                    description: complaint.description,
                    status: _complaintLabel(complaint.status),
                    date: complaint.createdAt,
                    studentName: complaint.studentName,
                    roomNumber: complaint.roomNumber,
                    onTap: () => onNavigate('complaints'),
                  ),
                ),
          const SizedBox(height: 12),
          _SectionHeading(
            title: 'Recent notices',
            action: 'Notice board',
            onPressed: () => onNavigate('notices'),
          ),
          const SizedBox(height: 10),
          ...store.notices
              .take(2)
              .map(
                (notice) => NoticeCard(
                  title: notice.title,
                  description: notice.description,
                  date: notice.date,
                  priority: notice.priority,
                  onTap: () => onNavigate('notices'),
                ),
              ),
        ] else ...[
          _StudentOverview(
            user: user,
            student: student,
            onNavigate: onNavigate,
          ),
        ],
      ],
    );
  }

  String _complaintLabel(ComplaintStatus status) => switch (status) {
    ComplaintStatus.pending => 'Pending',
    ComplaintStatus.inProgress => 'In progress',
    ComplaintStatus.resolved => 'Resolved',
  };
}

class _StudentOverview extends StatelessWidget {
  const _StudentOverview({
    required this.user,
    required this.student,
    required this.onNavigate,
  });

  final UserModel user;
  final StudentModel? student;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HostelStore>();
    final fee = store.feeForStudent(user.id);
    final room = store.roomForStudent(user.id);
    final attendance = store.attendance
        .where((item) => item.studentId == user.id)
        .toList();
    final present = attendance
        .where((item) => item.status == AttendanceStatus.present)
        .length;
    final myComplaints = store.complaints
        .where((item) => item.studentId == user.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth > 620;
            final items = [
              _Metric(
                'My room',
                room?.roomNumber ?? 'Unassigned',
                room == null
                    ? 'Contact the warden'
                    : '${room.availableBeds} open beds',
                Icons.meeting_room_outlined,
                const Color(0xFF4778A8),
                () => onNavigate('room'),
              ),
              _Metric(
                'Fee balance',
                Formatters.currency(fee?.pendingAmount ?? 0),
                fee?.status.name ?? 'No account found',
                Icons.receipt_long_outlined,
                const Color(0xFFAD6947),
                () => onNavigate('fees'),
              ),
              _Metric(
                'Attendance',
                '$present / ${attendance.length}',
                'Recorded today',
                Icons.fact_check_outlined,
                const Color(0xFF276B63),
                () => onNavigate('attendance'),
              ),
              _Metric(
                'My requests',
                '${myComplaints.where((item) => item.status != ComplaintStatus.resolved).length}',
                '${myComplaints.length} submitted',
                Icons.support_agent_outlined,
                const Color(0xFF9B5362),
                () => onNavigate('complaints'),
              ),
            ];
            return _MetricGrid(columns: twoColumns ? 2 : 1, items: items);
          },
        ),
        const SizedBox(height: 22),
        if (room != null) ...[
          const _SectionHeading(title: 'Room & roommates'),
          const SizedBox(height: 10),
          DashboardCard(
            title: 'Room ${room.roomNumber}',
            subtitle:
                'Floor ${room.floor} · ${room.occupied} of ${room.capacity} residents',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => onNavigate('room'),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < room.studentIds.length; index++)
                  Chip(
                    avatar: const Icon(Icons.person_outline_rounded, size: 17),
                    label: Text(room.studentNames[index]),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
        ],
        _SectionHeading(
          title: 'Notice board',
          action: 'View all',
          onPressed: () => onNavigate('notices'),
        ),
        const SizedBox(height: 10),
        for (final notice in store.notices.take(3))
          NoticeCard(
            title: notice.title,
            description: notice.description,
            date: notice.date,
            priority: notice.priority,
            onTap: () => onNavigate('notices'),
          ),
        const SizedBox(height: 8),
        _QuickActions(onNavigate: onNavigate),
      ],
    );
  }
}

class _WelcomeStrip extends StatelessWidget {
  const _WelcomeStrip({required this.user, required this.isAdmin});

  final UserModel user;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${user.fullName.split(' ').first}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAdmin
                    ? 'Here is what is happening at the hostel today.'
                    : 'Your residence at a glance.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (MediaQuery.sizeOf(context).width > 540)
          Icon(
            Icons.wb_sunny_outlined,
            size: 26,
            color: theme.colorScheme.tertiary,
          ),
      ],
    );
  }
}

class _Metric {
  const _Metric(
    this.title,
    this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
  );

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.columns, required this.items});

  final int columns;
  final List<_Metric> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 112,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return StatCard(
          title: item.title,
          value: item.value,
          subtitle: item.subtitle,
          icon: item.icon,
          color: item.color,
          onTap: item.onTap,
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action, this.onPressed});

  final String title;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onPressed, child: Text(action!)),
      ],
    );
  }
}

class _OccupancySummary extends StatelessWidget {
  const _OccupancySummary({required this.store});

  final HostelStore store;

  @override
  Widget build(BuildContext context) {
    final capacity = store.rooms.fold<int>(
      0,
      (sum, room) => sum + room.capacity,
    );
    final ratio = capacity == 0 ? 0.0 : store.occupiedBeds / capacity;
    return DashboardCard(
      title: 'Bed occupancy',
      subtitle: '${store.occupiedBeds} occupied of $capacity beds',
      trailing: StatusBadge(
        label: '${(ratio * 100).round()}%',
        type: BadgeType.info,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: ratio, minHeight: 10),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LegendDot(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'Occupied ${store.occupiedBeds}',
                ),
              ),
              Expanded(
                child: _LegendDot(
                  color: Theme.of(context).colorScheme.tertiary,
                  label: 'Available ${store.availableBeds}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({required this.store});

  final HostelStore store;

  @override
  Widget build(BuildContext context) {
    final records = store.attendance
        .where((record) => _sameDay(record.date, DateTime.now()))
        .toList();
    final present = records
        .where((record) => record.status == AttendanceStatus.present)
        .length;
    final ratio = records.isEmpty ? 0.0 : present / records.length;
    return DashboardCard(
      title: 'Today’s attendance',
      subtitle: '$present present · ${records.length - present} absent',
      trailing: const Icon(Icons.fact_check_outlined),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(ratio * 100).round()}% of residents checked in',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(
          avatar: const Icon(Icons.fact_check_outlined, size: 18),
          label: const Text('Attendance'),
          onPressed: () => onNavigate('attendance'),
        ),
        ActionChip(
          avatar: const Icon(Icons.restaurant_outlined, size: 18),
          label: const Text('Today’s menu'),
          onPressed: () => onNavigate('mess'),
        ),
        ActionChip(
          avatar: const Icon(Icons.notifications_none_rounded, size: 18),
          label: const Text('Updates'),
          onPressed: () => onNavigate('notices'),
        ),
      ],
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
