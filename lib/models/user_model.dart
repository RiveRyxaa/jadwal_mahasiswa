import 'dart:convert';

class UserModel {
  final String id;
  final String nama;
  final String email;
  final String password;
  final String universitas;
  final String jurusan;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    this.universitas = '',
    this.jurusan = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'password': password,
      'universitas': universitas,
      'jurusan': jurusan,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      universitas: json['universitas'] ?? '',
      jurusan: json['jurusan'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  UserModel copyWith({
    String? nama,
    String? email,
    String? password,
    String? universitas,
    String? jurusan,
  }) {
    return UserModel(
      id: id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      password: password ?? this.password,
      universitas: universitas ?? this.universitas,
      jurusan: jurusan ?? this.jurusan,
      createdAt: createdAt,
    );
  }
}
