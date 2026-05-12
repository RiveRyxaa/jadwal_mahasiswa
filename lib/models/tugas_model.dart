import 'dart:convert';

enum Prioritas { tinggi, sedang, rendah }

enum StatusTugas { aktif, selesai }

class TugasModel {
  final String id;
  final String userId;
  final String judul;
  final String deskripsi;
  final DateTime deadline;
  final Prioritas prioritas;
  final StatusTugas status;

  TugasModel({
    required this.id,
    required this.userId,
    required this.judul,
    this.deskripsi = '',
    required this.deadline,
    this.prioritas = Prioritas.sedang,
    this.status = StatusTugas.aktif,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'judul': judul,
      'deskripsi': deskripsi,
      'deadline': deadline.toIso8601String(),
      'prioritas': prioritas.name,
      'status': status.name,
    };
  }

  factory TugasModel.fromJson(Map<String, dynamic> json) {
    return TugasModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : DateTime.now(),
      prioritas: Prioritas.values.firstWhere(
        (e) => e.name == json['prioritas'],
        orElse: () => Prioritas.sedang,
      ),
      status: StatusTugas.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StatusTugas.aktif,
      ),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory TugasModel.fromJsonString(String jsonString) {
    return TugasModel.fromJson(jsonDecode(jsonString));
  }

  TugasModel copyWith({
    String? judul,
    String? deskripsi,
    DateTime? deadline,
    Prioritas? prioritas,
    StatusTugas? status,
  }) {
    return TugasModel(
      id: id,
      userId: userId,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      deadline: deadline ?? this.deadline,
      prioritas: prioritas ?? this.prioritas,
      status: status ?? this.status,
    );
  }

  bool get isOverdue =>
      status == StatusTugas.aktif && deadline.isBefore(DateTime.now());

  String get prioritasLabel {
    switch (prioritas) {
      case Prioritas.tinggi:
        return 'Tinggi';
      case Prioritas.sedang:
        return 'Sedang';
      case Prioritas.rendah:
        return 'Rendah';
    }
  }

  String get statusLabel {
    switch (status) {
      case StatusTugas.aktif:
        return 'Aktif';
      case StatusTugas.selesai:
        return 'Selesai';
    }
  }
}
