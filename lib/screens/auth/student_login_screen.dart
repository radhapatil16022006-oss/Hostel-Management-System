import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../student/student_dashboard_screen.dart';
import 'student_register_screen.dart';

/// Student authentication screen with Firebase Auth.
class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'student@hostel.com');
  final _passwordController = TextEditingController(text: 'student123');

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.login(
        emailOrUsername: _usernameController.text,
        password: _passwordController.text,
        expectedRole: UserRole.student,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user.fullName}!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fillDemoCredentials() {
    _usernameController.text = 'student@hostel.com';
    _passwordController.text = 'student123';
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Login'),
      ),
      body: ResponsiveContentContainer(
        maxWidth: 520,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spaceMd),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 48,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                Text(
                  'Student Resident Portal',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Sign in to check room status, fees, and submit complaints',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spaceXl),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceMd),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.errorDark, size: 20),
                        const SizedBox(width: AppDimensions.spaceSm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.errorDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                ],

                // Input fields
                AppTextField(
                  label: 'Student Email / Username',
                  hintText: 'e.g. student@hostel.com',
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (val) => Validators.required(val, 'Email / Username'),
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                AppTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (val) => Validators.password(val, 6),
                ),
                const SizedBox(height: AppDimensions.spaceSm),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _fillDemoCredentials,
                    child: const Text('Use Demo Credentials (student123)'),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                AppButton(
                  label: 'Sign In as Student',
                  variant: AppButtonVariant.secondary,
                  isLoading: _isLoading,
                  icon: Icons.login_rounded,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppDimensions.spaceLg),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New hostel resident? ',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StudentRegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register Account',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
