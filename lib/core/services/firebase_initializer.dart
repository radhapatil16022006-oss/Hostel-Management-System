import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Centralized manager for Firebase Initialization and status tracking.
class FirebaseInitializer {
  FirebaseInitializer._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static String? _initError;
  static String? get initError => _initError;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      if (kDebugMode) {
        print('Firebase successfully initialized for current platform.');
      }
    } catch (e) {
      _isInitialized = false;
      _initError = e.toString();
      if (kDebugMode) {
        print('Firebase initialization notice: $e (Falling back to robust local persistent store)');
      }
    }
  }
}
