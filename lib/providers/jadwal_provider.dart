import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/jadwal_model.dart';

class JadwalProvider extends ChangeNotifier {
  List<JadwalModel> _jadwalList = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<JadwalModel> get jadwalList => _jadwalList;
  bool get isLoading => _isLoading;

  /// Load jadwal from SharedPreferences
  Future<void> loadJadwal(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jadwalJson = prefs.getString('jadwal_$userId') ?? '[]';
      final List<dynamic> jadwalData = jsonDecode(jadwalJson);
      _jadwalList = jadwalData
          .map((j) => JadwalModel.fromJson(j as Map<String, dynamic>))
          .toList();
      _sortJadwal();
    } catch (e) {
      _jadwalList = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Save jadwal to SharedPreferences
  Future<void> _saveJadwal(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jadwalJson = jsonEncode(_jadwalList.map((j) => j.toJson()).toList());
    await prefs.setString('jadwal_$userId', jadwalJson);
  }

  /// Add new jadwal
  Future<void> addJadwal(String userId, JadwalModel jadwal) async {
    final newJadwal = JadwalModel(
      id: _uuid.v4(),
      userId: userId,
      namaMatkul: jadwal.namaMatkul,
      namaDosen: jadwal.namaDosen,
      hari: jadwal.hari,
      jamMulai: jadwal.jamMulai,
      jamSelesai: jadwal.jamSelesai,
      ruangan: jadwal.ruangan,
      catatan: jadwal.catatan,
    );

    _jadwalList.add(newJadwal);
    _sortJadwal();
    await _saveJadwal(userId);
    notifyListeners();
  }

  /// Update existing jadwal
  Future<void> updateJadwal(String userId, JadwalModel jadwal) async {
    final index = _jadwalList.indexWhere((j) => j.id == jadwal.id);
    if (index != -1) {
      _jadwalList[index] = jadwal;
      _sortJadwal();
      await _saveJadwal(userId);
      notifyListeners();
    }
  }

  /// Delete jadwal
  Future<void> deleteJadwal(String userId, String jadwalId) async {
    _jadwalList.removeWhere((j) => j.id == jadwalId);
    await _saveJadwal(userId);
    notifyListeners();
  }

  /// Get jadwal for a specific day
  List<JadwalModel> getJadwalByHari(String hari) {
    return _jadwalList.where((j) => j.hari == hari).toList();
  }

  /// Get today's jadwal
  List<JadwalModel> get jadwalHariIni {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    final today = days[now.weekday - 1];
    return getJadwalByHari(today);
  }

  /// Get next upcoming class
  JadwalModel? get kelasBerikutnya {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final todayIndex = now.weekday - 1; // 0 = Monday
    final currentTime = now.hour * 60 + now.minute;

    // First check today's remaining classes
    final todayJadwal = getJadwalByHari(days[todayIndex]);
    for (final jadwal in todayJadwal) {
      final parts = jadwal.jamMulai.split(':');
      final startMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (startMinutes > currentTime) {
        return jadwal;
      }
    }

    // Check next days
    for (int i = 1; i <= 7; i++) {
      final dayIndex = (todayIndex + i) % 7;
      final dayJadwal = getJadwalByHari(days[dayIndex]);
      if (dayJadwal.isNotEmpty) {
        return dayJadwal.first;
      }
    }

    return null;
  }

  /// Get time until next class
  Duration? get waktuMenujuKelasBerikutnya {
    final next = kelasBerikutnya;
    if (next == null) return null;

    final now = DateTime.now();
    final todayIndex = now.weekday - 1;
    final nextDayIndex = next.hariIndex;

    int daysUntil = nextDayIndex - todayIndex;
    if (daysUntil < 0) daysUntil += 7;

    final parts = next.jamMulai.split(':');
    final nextTime = DateTime(
      now.year, now.month, now.day + daysUntil,
      int.parse(parts[0]), int.parse(parts[1]),
    );

    if (daysUntil == 0 && nextTime.isBefore(now)) {
      // Next week same day
      return nextTime.add(const Duration(days: 7)).difference(now);
    }

    return nextTime.difference(now);
  }

  void _sortJadwal() {
    _jadwalList.sort((a, b) {
      final dayCompare = a.hariIndex.compareTo(b.hariIndex);
      if (dayCompare != 0) return dayCompare;
      return a.jamMulai.compareTo(b.jamMulai);
    });
  }
}
