import 'package:flutter/material.dart';

/// Centralized route constants and page route generator.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String showcase = '/showcase';

  // Rector Routes
  static const String rectorLogin = '/rector/login';
  static const String rectorRegister = '/rector/register';
  static const String rectorForgotPassword = '/rector/forgot-password';
  static const String rectorDashboard = '/rector/dashboard';
  static const String rectorStudents = '/rector/students';
  static const String rectorAttendance = '/rector/attendance';
  static const String rectorRooms = '/rector/rooms';
  static const String rectorFees = '/rector/fees';
  static const String rectorMess = '/rector/mess';
  static const String rectorComplaints = '/rector/complaints';
  static const String rectorVisitors = '/rector/visitors';
  static const String rectorLeave = '/rector/leave';
  static const String rectorNotices = '/rector/notices';
  static const String rectorProfile = '/rector/profile';
  static const String rectorSettings = '/rector/settings';
  static const String rectorStudentAccounts = '/rector/student-accounts';

  // Student Routes
  static const String studentLogin = '/student/login';
  static const String studentRegister = '/student/register';
  static const String studentForgotPassword = '/student/forgot-password';
  static const String studentDashboard = '/student/dashboard';
  static const String studentProfile = '/student/profile';
  static const String studentAttendance = '/student/attendance';
  static const String studentRoom = '/student/room';
  static const String studentFees = '/student/fees';
  static const String studentMess = '/student/mess';
  static const String studentComplaints = '/student/complaints';
  static const String studentLeave = '/student/leave';
  static const String studentNotices = '/student/notices';

  /// Generates animated page transitions with subtle slide and fade.
  static Route<dynamic> buildRoute({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.04, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeTween =
            Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
