import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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

  /// Register a new user
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();

      // Check if email already exists
      final usersJson = prefs.getString('users_list') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      final emailExists = users.any((u) => u['email'] == email);
      if (emailExists) {
        _error = 'Email sudah terdaftar';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      final newUser = UserModel(
        id: _uuid.v4(),
        nama: nama,
        email: email,
        password: password,
        universitas: universitas,
        jurusan: jurusan,
      );

      // Save to users list
      users.add(newUser.toJson());
      await prefs.setString('users_list', jsonEncode(users));

      // Set as current user
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
      await Future.delayed(const Duration(milliseconds: 500));

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

      // Update in users list
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
