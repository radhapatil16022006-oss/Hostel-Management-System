import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
import '../core/services/firebase_initializer.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';

/// Authentication interface and implementation with Firebase Auth and Firestore support.
abstract class AuthService {
  UserModel? get currentUser;
  Stream<UserModel?> get authStateChanges;

  Future<UserModel> login({
    required String emailOrUsername,
    required String password,
    required UserRole expectedRole,
  });

  Future<StudentModel> registerStudent({
    required String fullName,
    required DateTime dob,
    required String phone,
    required String email,
    required String parentPhone,
    required String branch,
    required String year,
    required String address,
    required String password,
    String? roomNumber,
  });

  Future<void> signOut();
}

class AppAuthService implements AuthService {
  final FirebaseAuth? _firebaseAuth = FirebaseInitializer.isInitialized
      ? FirebaseAuth.instance
      : null;
  final FirebaseFirestore? _firestore = FirebaseInitializer.isInitialized
      ? FirebaseFirestore.instance
      : null;

  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  UserModel? _cachedUser;

  // In-memory persistent demo user accounts for fallback / fast offline testing
  final List<UserModel> _mockUsers = [
    UserModel(
      id: 'warden_01',
      username: 'warden@hostel.com',
      fullName: 'Dr. Sunita Sharma (Warden)',
      phone: '9876543210',
      dob: DateTime(1982, 5, 14),
      role: UserRole.rector,
      accountStatus: AccountStatus.active,
      createdAt: DateTime(2025, 1, 1),
    ),
    UserModel(
      id: 'student_01',
      username: 'student@hostel.com',
      fullName: 'Rahul Deshmukh',
      phone: '9123456780',
      dob: DateTime(2004, 3, 22),
      role: UserRole.student,
      accountStatus: AccountStatus.active,
      createdAt: DateTime(2025, 2, 10),
    ),
  ];

  @override
  UserModel? get currentUser => _cachedUser;

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel> login({
    required String emailOrUsername,
    required String password,
    required UserRole expectedRole,
  }) async {
    final cleanInput = emailOrUsername.trim().toLowerCase();

    // 1. Try real Firebase Auth if initialized
    if (FirebaseInitializer.isInitialized &&
        _firebaseAuth != null &&
        _firestore != null) {
      try {
        final email = cleanInput.contains('@')
            ? cleanInput
            : '$cleanInput@hostel.com';
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = userCredential.user?.uid;
        if (uid != null) {
          final doc = await _firestore.collection('users').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            final user = UserModel.fromMap(doc.data()!, uid);
            if (user.role != expectedRole) {
              await _firebaseAuth.signOut();
              throw 'Access Denied: This account is not registered as a ${expectedRole == UserRole.rector ? "Warden" : "Student"}.';
            }
            _cachedUser = user;
            _authStateController.add(user);
            return user;
          }
        }
      } catch (e) {
        // If Firebase threw an auth error, but it's a demo account or fallback is needed
        if (!cleanInput.contains('warden@hostel.com') &&
            !cleanInput.contains('student@hostel.com')) {
          rethrow;
        }
      }
    }

    // 2. Fallback / Mock In-Memory Store
    await Future.delayed(const Duration(milliseconds: 400));
    const demoStudents = <String, String>{
      'student_001': 'Rahul Deshmukh',
      'student_002': 'Aditi Kulkarni',
      'student_003': 'Neha Patil',
      'student_004': 'Arjun Mehta',
      'student_005': 'Sara Khan',
      'student_006': 'Ishaan Joshi',
      'student_007': 'Mira Shah',
      'student_008': 'Dev Nair',
      'student_009': 'Priya Iyer',
    };
    final demoStudentId = cleanInput.split('@').first;
    final demoStudentName = demoStudents[demoStudentId];
    final match = _mockUsers.firstWhere(
      (u) =>
          u.username.toLowerCase() == cleanInput ||
          u.username.split('@').first.toLowerCase() == cleanInput,
      orElse: () {
        // Default dynamic creation for any typed credentials during demo testing
        return UserModel(
          id: demoStudentName == null
              ? '${expectedRole.name}_${DateTime.now().millisecondsSinceEpoch}'
              : demoStudentId,
          username: cleanInput,
          fullName: expectedRole == UserRole.rector
              ? 'Warden Administrator'
              : demoStudentName ?? 'Student Resident',
          phone: '9876543210',
          dob: DateTime(2003, 1, 1),
          role: expectedRole,
          accountStatus: AccountStatus.active,
          createdAt: DateTime.now(),
        );
      },
    );

    if (match.role != expectedRole) {
      throw 'Access Denied: You do not have permissions for the ${expectedRole == UserRole.rector ? "Warden" : "Student"} portal.';
    }

    _cachedUser = match;
    _authStateController.add(match);
    return match;
  }

  @override
  Future<StudentModel> registerStudent({
    required String fullName,
    required DateTime dob,
    required String phone,
    required String email,
    required String parentPhone,
    required String branch,
    required String year,
    required String address,
    required String password,
    String? roomNumber,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    String newId = 'student_${DateTime.now().millisecondsSinceEpoch}';

    // 1. If Firebase Auth is live, create Firebase Auth user & write to Firestore
    if (FirebaseInitializer.isInitialized &&
        _firebaseAuth != null &&
        _firestore != null) {
      try {
        final cred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        if (cred.user != null) {
          newId = cred.user!.uid;
        }
      } catch (_) {
        // Continue with local ID if offline/demo
      }
    }

    final student = StudentModel(
      id: newId,
      fullName: fullName,
      dob: dob,
      phone: phone,
      email: cleanEmail,
      parentPhone: parentPhone,
      branch: branch,
      year: year,
      address: address,
      roomNumber: roomNumber ?? '101',
      username: cleanEmail,
      admissionStatus: AdmissionStatus.newAdmission,
      accountStatus: AccountStatus.active,
      createdAt: DateTime.now(),
    );

    final user = UserModel(
      id: newId,
      username: cleanEmail,
      fullName: fullName,
      phone: phone,
      dob: dob,
      role: UserRole.student,
      accountStatus: AccountStatus.active,
      createdAt: DateTime.now(),
    );

    // Save in Firestore if live
    if (FirebaseInitializer.isInitialized && _firestore != null) {
      try {
        await _firestore.collection('users').doc(newId).set(user.toMap());
        await _firestore.collection('students').doc(newId).set(student.toMap());
      } catch (_) {}
    }

    _mockUsers.add(user);
    _cachedUser = user;
    _authStateController.add(user);
    return student;
  }

  @override
  Future<void> signOut() async {
    if (FirebaseInitializer.isInitialized && _firebaseAuth != null) {
      try {
        await _firebaseAuth.signOut();
      } catch (_) {}
    }
    _cachedUser = null;
    _authStateController.add(null);
  }
}
