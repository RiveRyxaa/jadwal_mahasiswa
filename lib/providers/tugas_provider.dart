import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/tugas_model.dart';

class TugasProvider extends ChangeNotifier {
  List<TugasModel> _tugasList = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<TugasModel> get tugasList => _tugasList;
  bool get isLoading => _isLoading;

  /// Load tugas from SharedPreferences
  Future<void> loadTugas(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final tugasJson = prefs.getString('tugas_$userId') ?? '[]';
      final List<dynamic> tugasData = jsonDecode(tugasJson);
      _tugasList = tugasData
          .map((t) => TugasModel.fromJson(t as Map<String, dynamic>))
          .toList();
      _sortTugas();
    } catch (e) {
      _tugasList = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Save tugas to SharedPreferences
  Future<void> _saveTugas(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final tugasJson = jsonEncode(_tugasList.map((t) => t.toJson()).toList());
    await prefs.setString('tugas_$userId', tugasJson);
  }

  /// Add new tugas
  Future<void> addTugas(String userId, TugasModel tugas) async {
    final newTugas = TugasModel(
      id: _uuid.v4(),
      userId: userId,
      judul: tugas.judul,
      deskripsi: tugas.deskripsi,
      deadline: tugas.deadline,
      prioritas: tugas.prioritas,
      status: tugas.status,
    );

    _tugasList.add(newTugas);
    _sortTugas();
    await _saveTugas(userId);
    notifyListeners();
  }

  /// Update existing tugas
  Future<void> updateTugas(String userId, TugasModel tugas) async {
    final index = _tugasList.indexWhere((t) => t.id == tugas.id);
    if (index != -1) {
      _tugasList[index] = tugas;
      _sortTugas();
      await _saveTugas(userId);
      notifyListeners();
    }
  }

  /// Delete tugas
  Future<void> deleteTugas(String userId, String tugasId) async {
    _tugasList.removeWhere((t) => t.id == tugasId);
    await _saveTugas(userId);
    notifyListeners();
  }

  /// Toggle tugas status
  Future<void> toggleStatus(String userId, String tugasId) async {
    final index = _tugasList.indexWhere((t) => t.id == tugasId);
    if (index != -1) {
      final tugas = _tugasList[index];
      _tugasList[index] = tugas.copyWith(
        status: tugas.status == StatusTugas.aktif
            ? StatusTugas.selesai
            : StatusTugas.aktif,
      );
      await _saveTugas(userId);
      notifyListeners();
    }
  }

  /// Get active tugas only
  List<TugasModel> get tugasAktif =>
      _tugasList.where((t) => t.status == StatusTugas.aktif).toList();

  /// Get completed tugas
  List<TugasModel> get tugasSelesai =>
      _tugasList.where((t) => t.status == StatusTugas.selesai).toList();

  /// Get tugas by priority
  List<TugasModel> getTugasByPrioritas(Prioritas prioritas) =>
      _tugasList.where((t) => t.prioritas == prioritas).toList();

  /// Get nearest deadline tugas (active only)
  List<TugasModel> get tugasDeadlineTerdekat {
    final active = tugasAktif;
    active.sort((a, b) => a.deadline.compareTo(b.deadline));
    return active.take(5).toList();
  }

  /// Get overdue tugas
  List<TugasModel> get tugasOverdue =>
      _tugasList.where((t) => t.isOverdue).toList();

  void _sortTugas() {
    _tugasList.sort((a, b) {
      // Active first, then by deadline
      if (a.status != b.status) {
        return a.status == StatusTugas.aktif ? -1 : 1;
      }
      return a.deadline.compareTo(b.deadline);
    });
  }
}
