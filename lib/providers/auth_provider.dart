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

  /// Try to auto-login from SharedPreferences
  Future<bool> tryAutoLogin() async {
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

  /// Login with Google + Firebase
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

      // Get Google auth details
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      await _firebaseAuth.signInWithCredential(credential);

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users_list') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      // Check if user already exists locally
      final existingUser = users.cast<Map<String, dynamic>>().firstWhere(
            (u) => u['email'] == googleUser.email,
            orElse: () => <String, dynamic>{},
          );

      if (existingUser.isNotEmpty) {
        _currentUser = UserModel.fromJson(existingUser);
      } else {
        final newUser = UserModel(
          id: _uuid.v4(),
          nama: googleUser.displayName ?? googleUser.email.split('@')[0],
          email: googleUser.email,
          password: 'google_auth',
          universitas: '',
          jurusan: '',
        );
        users.add(newUser.toJson());
        await prefs.setString('users_list', jsonEncode(users));
        _currentUser = newUser;
      }

      await prefs.setString('current_user', _currentUser!.toJsonString());
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

  /// Register a new user (also registers in Firebase)
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
      await Future.delayed(const Duration(milliseconds: 300));

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users_list') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      final emailExists = users.any((u) => u['email'] == email);
      if (emailExists) {
        _error = 'Email sudah terdaftar';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Register in Firebase Auth
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // If already in Firebase, try to sign in
          await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        } else {
          _error = _getFirebaseError(e.code);
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final newUser = UserModel(
        id: _uuid.v4(),
        nama: nama,
        email: email,
        password: password,
        universitas: universitas,
        jurusan: jurusan,
      );

      users.add(newUser.toJson());
      await prefs.setString('users_list', jsonEncode(users));
      _currentUser = newUser;
      await prefs.setString('current_user', newUser.toJsonString());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users_list') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      final userJson = users.cast<Map<String, dynamic>>().firstWhere(
            (u) => u['email'] == email && u['password'] == password,
            orElse: () => <String, dynamic>{},
          );

      if (userJson.isEmpty) {
        _error = 'Email atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Also sign in to Firebase
      try {
        await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      } catch (_) {
        // Firebase sign-in is optional, local login still works
      }

      _currentUser = UserModel.fromJson(userJson);
      await prefs.setString('current_user', _currentUser!.toJsonString());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
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

  /// Update user profile
  Future<bool> updateProfile({
    String? nama,
    String? universitas,
    String? jurusan,
  }) async {
    if (_currentUser == null) return false;

    try {
      final prefs = await SharedPreferences.getInstance();

      _currentUser = _currentUser!.copyWith(
        nama: nama,
        universitas: universitas,
        jurusan: jurusan,
      );

      final usersJson = prefs.getString('users_list') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);
      final index = users.indexWhere((u) => u['id'] == _currentUser!.id);
      if (index != -1) {
        users[index] = _currentUser!.toJson();
        await prefs.setString('users_list', jsonEncode(users));
      }

      await prefs.setString('current_user', _currentUser!.toJsonString());
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) return false;

    if (_currentUser!.password != oldPassword) {
      _error = 'Password lama salah';
      notifyListeners();
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUser = _currentUser!.copyWith(password: newPassword);

      // Update Firebase password
      try {
        await _firebaseAuth.currentUser?.updatePassword(newPassword);
      } catch (_) {}

      final usersJson = prefs.getString('users_list') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);
      final index = users.indexWhere((u) => u['id'] == _currentUser!.id);
      if (index != -1) {
        users[index] = _currentUser!.toJson();
        await prefs.setString('users_list', jsonEncode(users));
      }

      await prefs.setString('current_user', _currentUser!.toJsonString());
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Terjadi kesalahan';
      notifyListeners();
      return false;
    }
  }

  /// Check if email is registered
  Future<bool> isEmailRegistered(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users_list') ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);
    return users.any((u) => u['email'] == email);
  }

  /// Reset password by email (after Google verification)
  Future<bool> resetPasswordByEmail({
    required String email,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users_list') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);
      final index = users.indexWhere((u) => u['email'] == email);

      if (index == -1) return false;

      users[index]['password'] = newPassword;
      await prefs.setString('users_list', jsonEncode(users));

      if (_currentUser?.email == email) {
        _currentUser = _currentUser!.copyWith(password: newPassword);
        await prefs.setString('current_user', _currentUser!.toJsonString());
        notifyListeners();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  String _getFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'invalid-email':
        return 'Format email tidak valid';
      default:
        return 'Terjadi kesalahan ($code)';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
