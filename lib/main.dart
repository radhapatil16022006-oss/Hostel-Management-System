import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'routes/app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/showcase/design_system_screen.dart';
import 'services/auth_service.dart';
import 'services/hostel_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HostelManagementApp());
}

/// Root widget of Hostel Management System.
class HostelManagementApp extends StatelessWidget {
  const HostelManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<HostelStore>(create: (_) => HostelStore()),
        Provider<AuthService>(create: (_) => AppAuthService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const LoginScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.showcase) {
                return AppRoutes.buildRoute(
                  page: const DesignSystemScreen(),
                  settings: settings,
                );
              }

              return null;
            },
          );
        },
      ),
    );
  }
}
