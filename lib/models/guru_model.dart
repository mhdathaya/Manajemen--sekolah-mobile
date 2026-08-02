/// Model data Guru
/// Disesuaikan dengan backend response:
///
/// GET /api/auth/me → data.guru:
///   { id, nama, nip, email, telepon, mata_pelajaran,
///     jenis_kelamin, status, user_id }
///
/// GET /api/guru/:id → data:
///   { id, nama, nip, email, telepon, mata_pelajaran,
///     jenis_kelamin, status, user_id }
///
/// Catatan field backend:
///   - 'telepon'        (bukan 'nomor_telepon')
///   - 'jenis_kelamin'  nilai: 'L' atau 'P'
///   - email ada di model Guru langsung (bukan hanya di User)
class GuruModel {
  final String id;
  final String nama;
  final String nip;
  final String email;
  final String? nomorTelepon; // backend: telepon
  final String? fotoProfil;
  final String? mataPelajaran;
  final String? jabatan;
  final String? alamat;
  final String? tanggalLahir;
  final String? jenisKelamin; // backend: 'L' atau 'P'
  final String? status;       // 'aktif' | 'nonaktif'
  final String? userId;       // foreign key ke users.id

  const GuruModel({
    required this.id,
    required this.nama,
    required this.nip,
    required this.email,
    this.nomorTelepon,
    this.fotoProfil,
    this.mataPelajaran,
    this.jabatan,
    this.alamat,
    this.tanggalLahir,
    this.jenisKelamin,
    this.status,
    this.userId,
  });

  factory GuruModel.fromJson(Map<String, dynamic> json) {
    return GuruModel(
      id: json['id']?.toString() ?? json['guru_id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nip: json['nip']?.toString() ?? '',
      // email bisa dari model Guru atau dari User level
      email: json['email']?.toString() ?? '',
      // Backend field: 'telepon'
      nomorTelepon: json['telepon']?.toString() ?? json['nomor_telepon']?.toString(),
      fotoProfil: json['foto_profil']?.toString(),
      mataPelajaran: json['mata_pelajaran']?.toString(),
      jabatan: json['jabatan']?.toString(),
      alamat: json['alamat']?.toString(),
      tanggalLahir: json['tanggal_lahir']?.toString(),
      jenisKelamin: json['jenis_kelamin']?.toString(),
      status: json['status']?.toString(),
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nip': nip,
      'email': email,
      'telepon': nomorTelepon,
      'foto_profil': fotoProfil,
      'mata_pelajaran': mataPelajaran,
      'jabatan': jabatan,
      'alamat': alamat,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'status': status,
      'user_id': userId,
    };
  }

  GuruModel copyWith({
    String? id,
    String? nama,
    String? nip,
    String? email,
    String? nomorTelepon,
    String? fotoProfil,
    String? mataPelajaran,
    String? jabatan,
    String? alamat,
    String? tanggalLahir,
    String? jenisKelamin,
    String? status,
    String? userId,
  }) {
    return GuruModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nip: nip ?? this.nip,
      email: email ?? this.email,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      mataPelajaran: mataPelajaran ?? this.mataPelajaran,
      jabatan: jabatan ?? this.jabatan,
      alamat: alamat ?? this.alamat,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }

  /// Dummy untuk fallback UI — sesuai data seeder
  static GuruModel dummy() {
    return const GuruModel(
      id: '1',
      nama: 'Budi Santoso, S.Pd',
      nip: '198501012010011001',
      email: 'budi@sekolah.sch.id',
      nomorTelepon: '081234567801',
      mataPelajaran: 'Matematika',
      jenisKelamin: 'L',
      status: 'aktif',
    );
  }

  @override
  String toString() => 'GuruModel(id: $id, nama: $nama, nip: $nip)';
}
