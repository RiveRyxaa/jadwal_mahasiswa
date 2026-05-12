import 'dart:convert';

class JadwalModel {
  final String id;
  final String userId;
  final String namaMatkul;
  final String namaDosen;
  final String hari; // Senin, Selasa, Rabu, Kamis, Jumat, Sabtu
  final String jamMulai; // "08:00"
  final String jamSelesai; // "09:40"
  final String ruangan;
  final String catatan;

  JadwalModel({
    required this.id,
    required this.userId,
    required this.namaMatkul,
    this.namaDosen = '',
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    this.ruangan = '',
    this.catatan = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'namaMatkul': namaMatkul,
      'namaDosen': namaDosen,
      'hari': hari,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'ruangan': ruangan,
      'catatan': catatan,
    };
  }

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      namaMatkul: json['namaMatkul'] ?? '',
      namaDosen: json['namaDosen'] ?? '',
      hari: json['hari'] ?? '',
      jamMulai: json['jamMulai'] ?? '',
      jamSelesai: json['jamSelesai'] ?? '',
      ruangan: json['ruangan'] ?? '',
      catatan: json['catatan'] ?? '',
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory JadwalModel.fromJsonString(String jsonString) {
    return JadwalModel.fromJson(jsonDecode(jsonString));
  }

  JadwalModel copyWith({
    String? namaMatkul,
    String? namaDosen,
    String? hari,
    String? jamMulai,
    String? jamSelesai,
    String? ruangan,
    String? catatan,
  }) {
    return JadwalModel(
      id: id,
      userId: userId,
      namaMatkul: namaMatkul ?? this.namaMatkul,
      namaDosen: namaDosen ?? this.namaDosen,
      hari: hari ?? this.hari,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
      ruangan: ruangan ?? this.ruangan,
      catatan: catatan ?? this.catatan,
    );
  }

  /// Get day index (0 = Senin, 5 = Sabtu) for sorting
  int get hariIndex {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return days.indexOf(hari);
  }

  /// Parse jamMulai to TimeOfDay
  DateTime get startTime {
    final parts = jamMulai.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Parse jamSelesai to TimeOfDay
  DateTime get endTime {
    final parts = jamSelesai.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }

  static const List<String> hariList = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];
}
