/// Model dasar pengguna aplikasi EduBlue
class UserModel {
  final String id;
  final String nama;
  final String email;
  final String role; // 'guru' | 'siswa'
  final String? fotoProfil;
  final String? nomorTelepon;
  final String? token;

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.fotoProfil,
    this.nomorTelepon,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      fotoProfil: json['foto_profil'],
      nomorTelepon: json['nomor_telepon'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'foto_profil': fotoProfil,
      'nomor_telepon': nomorTelepon,
      'token': token,
    };
  }

  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? role,
    String? fotoProfil,
    String? nomorTelepon,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      token: token ?? this.token,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, nama: $nama, email: $email, role: $role)';
}
