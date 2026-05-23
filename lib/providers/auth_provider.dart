import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  final _uuid = const Uuid();
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  // ─── Auto Login ───
  Future<bool> tryAutoLogin() async {
    // Check Firebase auth state first
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      await _loadOrCreateLocalProfile(fbUser);
      return true;
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('current_user');
    if (userData == null) return false;

    try {
      _currentUser = UserModel.fromJsonString(userData);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Register with Email + Password ───
  Future<bool> register({
    required String nama,
    required String email,
    required String password,
    String universitas = '',
    String jurusan = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Register in Firebase (single source of truth for auth)
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name in Firebase
      await credential.user?.updateDisplayName(nama);

      // Save profile data locally
      final newUser = UserModel(
        id: credential.user!.uid,
        nama: nama,
        email: email,
        password: '', // No longer store password locally
        universitas: universitas,
        jurusan: jurusan,
      );

      await _saveLocalProfile(newUser);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = _getFirebaseError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Login with Email + Password ───
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Authenticate via Firebase (password check happens here)
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load or create local profile
      await _loadOrCreateLocalProfile(credential.user!);

      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = _getFirebaseError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Login with Google ───
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      await _loadOrCreateLocalProfile(userCredential.user!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Google Sign-In gagal: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Logout ───
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }

  // ─── Update Profile ───
  Future<bool> updateProfile({
    String? nama,
    String? universitas,
    String? jurusan,
  }) async {
    if (_currentUser == null) return false;

    try {
      _currentUser = _currentUser!.copyWith(
        nama: nama,
        universitas: universitas,
        jurusan: jurusan,
      );

      // Update Firebase display name
      if (nama != null) {
        await _firebaseAuth.currentUser?.updateDisplayName(nama);
      }

      await _saveLocalProfile(_currentUser!);
      await _updateProfileInList(_currentUser!);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Change Password ───
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        _error = 'User tidak ditemukan';
        notifyListeners();
        return false;
      }

      // Re-authenticate with old password
      final credential = fb.EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password in Firebase
      await user.updatePassword(newPassword);

      _error = null;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _error = 'Password lama salah';
      } else {
        _error = _getFirebaseError(e.code);
      }
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan';
      notifyListeners();
      return false;
    }
  }

  // ─── Send Password Reset Email ───
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Helper: Load or create local profile from Firebase user ───
  Future<void> _loadOrCreateLocalProfile(fb.User fbUser) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users_list') ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);

    final existing = users.cast<Map<String, dynamic>>().firstWhere(
          (u) => u['email'] == fbUser.email,
          orElse: () => <String, dynamic>{},
        );

    if (existing.isNotEmpty) {
      _currentUser = UserModel.fromJson(existing);
    } else {
      final newUser = UserModel(
        id: fbUser.uid,
        nama: fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'User',
        email: fbUser.email ?? '',
        password: '',
        universitas: '',
        jurusan: '',
      );
      users.add(newUser.toJson());
      await prefs.setString('users_list', jsonEncode(users));
      _currentUser = newUser;
    }

    await prefs.setString('current_user', _currentUser!.toJsonString());
    notifyListeners();
  }

  // ─── Helper: Save profile locally ───
  Future<void> _saveLocalProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', user.toJsonString());

    final usersJson = prefs.getString('users_list') ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);
    final index = users.indexWhere((u) => u['email'] == user.email);
    if (index != -1) {
      users[index] = user.toJson();
    } else {
      users.add(user.toJson());
    }
    await prefs.setString('users_list', jsonEncode(users));
  }

  // ─── Helper: Update profile in users list ───
  Future<void> _updateProfileInList(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users_list') ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);
    final index = users.indexWhere((u) => u['id'] == user.id);
    if (index != -1) {
      users[index] = user.toJson();
      await prefs.setString('users_list', jsonEncode(users));
    }
    await prefs.setString('current_user', user.toJsonString());
  }

  // ─── Helper: Firebase error messages ───
  String _getFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      default:
        return 'Terjadi kesalahan ($code)';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
