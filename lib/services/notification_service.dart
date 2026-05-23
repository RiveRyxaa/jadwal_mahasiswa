import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/jadwal_model.dart';
import '../models/tugas_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Request permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permissions for Android 12+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// Schedule notification for jadwal (15 minutes before + at class time)
  Future<void> scheduleJadwalNotifications(List<JadwalModel> jadwalList) async {
    // Cancel all existing jadwal notifications (IDs 1000-1999)
    for (int i = 1000; i < 1000 + 400; i++) {
      await _notifications.cancel(i);
    }

    int notifId = 1000;
    final now = DateTime.now();

    for (final jadwal in jadwalList) {
      // Get next occurrence of this jadwal
      final nextDate = _getNextOccurrence(jadwal.hari, jadwal.jamMulai);
      if (nextDate == null) continue;

      // Notification 1: 15 minutes before
      final notifTime = nextDate.subtract(const Duration(minutes: 15));
      if (notifTime.isAfter(now)) {
        await _scheduleNotification(
          id: notifId,
          title: '📚 Kelas Dimulai 15 Menit Lagi!',
          body: '${jadwal.namaMatkul} • ${jadwal.jamMulai} - ${jadwal.jamSelesai}\n📍 ${jadwal.ruangan.isNotEmpty ? jadwal.ruangan : "Ruangan belum diatur"}',
          scheduledTime: notifTime,
          channelId: 'jadwal_reminder',
          channelName: 'Pengingat Jadwal',
          channelDesc: 'Notifikasi pengingat jadwal kuliah',
          payload: 'jadwal_${jadwal.id}',
        );
      }
      notifId++;

      // Notification 2: At exact class time
      if (nextDate.isAfter(now)) {
        await _scheduleNotification(
          id: notifId,
          title: '🔔 Waktunya Masuk Kelas!',
          body: '${jadwal.namaMatkul} dimulai sekarang!\n⏰ ${jadwal.jamMulai} - ${jadwal.jamSelesai}${jadwal.ruangan.isNotEmpty ? "\n📍 ${jadwal.ruangan}" : ""}',
          scheduledTime: nextDate,
          channelId: 'jadwal_reminder',
          channelName: 'Pengingat Jadwal',
          channelDesc: 'Notifikasi pengingat jadwal kuliah',
          payload: 'jadwal_${jadwal.id}',
        );
      }
      notifId++;
    }
  }

  /// Schedule notifications for tugas deadlines
  Future<void> scheduleTugasNotifications(List<TugasModel> tugasList) async {
    // Cancel all existing tugas notifications (IDs 2000-2999)
    for (int i = 2000; i < 2000 + 200; i++) {
      await _notifications.cancel(i);
    }

    int notifId = 2000;
    final now = DateTime.now();

    for (final tugas in tugasList) {
      if (tugas.status == StatusTugas.selesai) continue;

      // Notification 1: 1 day before deadline
      final oneDayBefore = tugas.deadline.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        await _scheduleNotification(
          id: notifId,
          title: '⏰ Deadline Besok!',
          body: '${tugas.judul}\nDeadline: ${_formatDateTime(tugas.deadline)}',
          scheduledTime: oneDayBefore,
          channelId: 'tugas_reminder',
          channelName: 'Pengingat Tugas',
          channelDesc: 'Notifikasi pengingat deadline tugas',
          payload: 'tugas_${tugas.id}',
        );
      }
      notifId++;

      // Notification 2: 1 hour before deadline
      final oneHourBefore = tugas.deadline.subtract(const Duration(hours: 1));
      if (oneHourBefore.isAfter(now)) {
        await _scheduleNotification(
          id: notifId,
          title: '🚨 Deadline 1 Jam Lagi!',
          body: '${tugas.judul}\nSegera selesaikan tugasmu!',
          scheduledTime: oneHourBefore,
          channelId: 'tugas_reminder',
          channelName: 'Pengingat Tugas',
          channelDesc: 'Notifikasi pengingat deadline tugas',
          payload: 'tugas_${tugas.id}',
        );
      }
      notifId++;

      // Notification 3: 3 hours before deadline (for high priority)
      if (tugas.prioritas == Prioritas.tinggi) {
        final threeHoursBefore = tugas.deadline.subtract(const Duration(hours: 3));
        if (threeHoursBefore.isAfter(now)) {
          await _scheduleNotification(
            id: notifId,
            title: '🔴 Tugas Prioritas Tinggi!',
            body: '${tugas.judul}\nDeadline dalam 3 jam! (${_formatDateTime(tugas.deadline)})',
            scheduledTime: threeHoursBefore,
            channelId: 'tugas_reminder',
            channelName: 'Pengingat Tugas',
            channelDesc: 'Notifikasi pengingat deadline tugas',
            payload: 'tugas_${tugas.id}',
          );
        }
      }
      notifId++;
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    required String channelName,
    required String channelDesc,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1B365D),
      styleInformation: BigTextStyleInformation(body),
      category: AndroidNotificationCategory.reminder,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: channelId == 'jadwal_reminder'
          ? DateTimeComponents.dayOfWeekAndTime
          : null,
      payload: payload,
    );
  }

  /// Get the next date for a specific day and time
  DateTime? _getNextOccurrence(String hari, String jamMulai) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final dayIndex = days.indexOf(hari);
    if (dayIndex == -1) return null;

    final parts = jamMulai.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final now = DateTime.now();
    // DateTime.weekday: Monday = 1
    final targetWeekday = dayIndex + 1;
    int daysUntil = targetWeekday - now.weekday;
    if (daysUntil < 0) daysUntil += 7;

    var nextDate = DateTime(
      now.year, now.month, now.day + daysUntil,
      hour, minute,
    );

    // If it's today but time has passed, schedule for next week
    if (daysUntil == 0 && nextDate.isBefore(now)) {
      nextDate = nextDate.add(const Duration(days: 7));
    }

    return nextDate;
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
