import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/theme_provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'management_screen.dart';
import 'overview_screen.dart';

class HostelShell extends StatefulWidget {
  const HostelShell({super.key, required this.user});

  final UserModel user;

  @override
  State<HostelShell> createState() => _HostelShellState();
}

class _HostelShellState extends State<HostelShell> {
  String _section = 'overview';

  bool get _isAdmin => widget.user.role == UserRole.rector;

  List<_NavItem> get _items => _isAdmin
      ? const [
          _NavItem('overview', 'Overview', Icons.grid_view_rounded),
          _NavItem('students', 'Students', Icons.groups_2_outlined),
          _NavItem('rooms', 'Rooms', Icons.meeting_room_outlined),
          _NavItem('fees', 'Fees', Icons.receipt_long_outlined),
          _NavItem('more', 'More', Icons.more_horiz_rounded),
        ]
      : const [
          _NavItem('overview', 'Home', Icons.grid_view_rounded),
          _NavItem('room', 'My room', Icons.meeting_room_outlined),
          _NavItem('fees', 'Fees', Icons.receipt_long_outlined),
          _NavItem('complaints', 'Requests', Icons.support_agent_outlined),
          _NavItem('more', 'More', Icons.more_horiz_rounded),
        ];

  String get _title {
    if (_section == 'overview') return 'Overview';
    if (_section == 'room') return 'My room';
    for (final item in _items) {
      if (item.id == _section) return item.label;
    }
    return switch (_section) {
      'complaints' => _isAdmin ? 'Complaints' : 'My requests',
      'notices' => 'Notices & updates',
      'attendance' => 'Attendance',
      'visitors' => 'Visitor register',
      'mess' => 'Mess information',
      'reports' => 'Reports',
      'profile' => 'My profile',
      _ => 'Hostel management',
    };
  }

  void _navigate(String section) => setState(() => _section = section);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final selectedIndex = _items.indexWhere((item) => item.id == _section);
    final index = selectedIndex < 0 ? _items.length - 1 : selectedIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account options',
            onSelected: (value) {
              if (value == 'profile') _navigate('profile');
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile'),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign out'),
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 17,
                child: Text(
                  widget.user.fullName.isEmpty
                      ? '?'
                      : widget.user.fullName[0].toUpperCase(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1180,
              selectedIndex: index,
              onDestinationSelected: (value) => _navigate(_items[value].id),
              leading: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 20),
                child: Column(
                  children: [
                    const Icon(Icons.apartment_rounded, size: 28),
                    if (MediaQuery.sizeOf(context).width >= 1180) ...[
                      const SizedBox(height: 8),
                      Text(
                        _isAdmin ? 'WARDEN' : 'RESIDENT',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
              destinations: [
                for (final item in _items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon),
                    label: Text(item.label),
                  ),
              ],
            ),
          if (wide) const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: _section == 'overview'
                    ? OverviewScreen(user: widget.user, onNavigate: _navigate)
                    : ManagementScreen(
                        user: widget.user,
                        section: _section,
                        onNavigate: _navigate,
                      ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => _navigate(_items[value].id),
              destinations: [
                for (final item in _items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthService>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

class _NavItem {
  const _NavItem(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;
}
