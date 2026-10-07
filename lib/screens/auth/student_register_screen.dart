import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_text_field.dart';
import '../student/student_dashboard_screen.dart';

/// Student Registration Screen for Hostel Residents.
class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Shreya Kulkarni');
  final _phoneController = TextEditingController(text: '9822334455');
  final _emailController = TextEditingController(text: 'shreya.kulkarni@hostel.com');
  final _parentPhoneController = TextEditingController(text: '9811223344');
  final _addressController = TextEditingController(text: 'Shivajinagar, Pune');
  final _passwordController = TextEditingController(text: 'password123');
  final _confirmPasswordController = TextEditingController(text: 'password123');

  DateTime _selectedDob = DateTime(2004, 6, 15);
  String _selectedBranch = AppConstants.branches.first;
  String _selectedYear = AppConstants.academicYears[1]; // Second Year (SE)
  String _selectedRoom = '103';

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);

      final student = await authService.registerStudent(
        fullName: _nameController.text.trim(),
        dob: _selectedDob,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        branch: _selectedBranch,
        year: _selectedYear,
        address: _addressController.text.trim(),
        password: _passwordController.text,
        roomNumber: _selectedRoom,
      );

      // Add to Firestore database
      await firestoreService.addStudent(student);

      // Attempt room allocation
      try {
        await firestoreService.allocateStudentToRoom(
          roomId: 'room_$_selectedRoom',
          studentId: student.id,
          studentName: student.fullName,
        );
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful! Welcome, ${student.fullName}.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
          (route) => false,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Admission Registration'),
      ),
      body: ResponsiveContentContainer(
        maxWidth: 680,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hostel Resident Registration',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please enter valid personal, academic, and parent details',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceMd),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.errorDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                ],

                // Full Name
                AppTextField(
                  label: 'Full Name',
                  hintText: 'Enter student full name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => Validators.required(v, 'Full Name'),
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                // DOB Picker Tile
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    InkWell(
                      onTap: _pickDateOfBirth,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceMd,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                              : AppColors.lightSurfaceVariant.withValues(alpha: 0.6),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatters.date(_selectedDob),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                // Phone & Email
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Phone Number',
                        hintText: '10-digit number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: Validators.phone,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMd),
                    Expanded(
                      child: AppTextField(
                        label: 'Parent Phone',
                        hintText: 'Parent 10-digit number',
                        controller: _parentPhoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.contact_phone_outlined,
                        validator: Validators.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                AppTextField(
                  label: 'Email Address',
                  hintText: 'student@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                // Academic Branch & Year
                AppDropdown<String>(
                  label: 'Branch / Engineering Stream',
                  value: _selectedBranch,
                  prefixIcon: Icons.school_outlined,
                  items: AppConstants.branches
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBranch = v!),
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'Academic Year',
                        value: _selectedYear,
                        prefixIcon: Icons.timeline_rounded,
                        items: AppConstants.academicYears
                            .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedYear = v!),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMd),
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'Room Preference',
                        value: _selectedRoom,
                        prefixIcon: Icons.meeting_room_outlined,
                        items: ['101', '102', '103', '201']
                            .map((r) => DropdownMenuItem(
                                value: r, child: Text('Room $r')))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedRoom = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                // Permanent Address
                AppTextField(
                  label: 'Permanent Address / City',
                  hintText: 'e.g. Pune, Maharashtra',
                  controller: _addressController,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => Validators.required(v, 'Address'),
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                // Password & Confirm Password
                AppTextField(
                  label: 'Password',
                  hintText: 'Min 6 characters',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) => Validators.password(v, 6),
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                AppTextField(
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_reset_rounded,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: AppDimensions.spaceXl),

                AppButton(
                  label: 'Complete Admission Registration',
                  variant: AppButtonVariant.secondary,
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppDimensions.spaceLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
