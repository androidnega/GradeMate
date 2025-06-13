import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AppState extends ChangeNotifier {
  bool _isGuest = true;
  User? _user;
  bool _isInitialized = false;

  AppState() {
    _initializeApp();
  }

  bool get isGuest => _isGuest;
  User? get user => _user;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;

  Future<void> _initializeApp() async {
    await LocalStorageService.initialize();
    _user = AuthService.currentUser;
    _isGuest = _user == null;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final credential = await AuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    _user = credential?.user;
    _isGuest = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final credential = await AuthService.signInWithGoogle();
    _user = credential?.user;
    _isGuest = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      // Sign out from Firebase Auth
      await AuthService.signOut();

      // Clear local storage
      await LocalStorageService.clear();

      // Reset state
      _user = null;
      _isGuest = true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    }
  }

  Future<void> switchToGuestMode() async {
    await signOut();
    _isGuest = true;
    notifyListeners();
  }

  Future<void> upgradeGuestToUser() async {
    if (!isAuthenticated) return;

    try {
      // Get local data
      final localSemesters = await LocalStorageService.getSemesters();

      // Upload to cloud
      if (localSemesters.isNotEmpty && _user != null) {
        // Create user profile
        await FirestoreService.createUser(
          UserModel(
            id: _user!.uid,
            email: _user!.email ?? '',
            name: _user!.displayName ?? 'User',
          ),
        );

        // Migrate local data
        await Future.wait(
          localSemesters.map((semester) async {
            await FirestoreService.createUser(
              UserModel(
                id: _user!.uid,
                email: _user!.email ?? '',
                name: _user!.displayName ?? 'User',
              ),
            );
          }),
        );
      }

      // Clear local storage after successful migration
      await LocalStorageService.clear();

      _isGuest = false;
      notifyListeners();
    } catch (e) {
      // If migration fails, keep guest mode active
      rethrow;
    }
  }
}
