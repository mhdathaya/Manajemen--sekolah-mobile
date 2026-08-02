/// Model data Siswa
/// Field disesuaikan dengan response backend:
///   GET /api/siswa/:id → data
///   Backend Siswa model: nis, nama, kelas_id, jenis_kelamin,
///                        tanggal_lahir, alamat, telepon_ortu, qr_token
class SiswaModel {
  final String id;
  final String nama;
  final String nis;
  final String email;
  final String kelas;       // nama kelas dari relasi kelas.nama_kelas
  final String? kelasId;    // kelas_id untuk request ke API
  final String? nomorTelepon;
  final String? fotoProfil;
  final String? alamat;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? namaOrangTua;
  final String? teleponOrangTua;
  // qr_token dari backend — digunakan untuk scan absensi oleh guru
  final String? qrToken;

  const SiswaModel({
    required this.id,
    required this.nama,
    required this.nis,
    required this.email,
    required this.kelas,
    this.kelasId,
    this.nomorTelepon,
    this.fotoProfil,
    this.alamat,
    this.tanggalLahir,
    this.jenisKelamin,
    this.namaOrangTua,
    this.teleponOrangTua,
    this.qrToken,
  });

  factory SiswaModel.fromJson(Map<String, dynamic> json) {
    // Nama kelas bisa dari relasi nested atau field langsung
    final kelasNested = json['kelas'];
    final String namaKelas;
    final String? kelasId;

    if (kelasNested is Map) {
      namaKelas = kelasNested['nama_kelas']?.toString() ?? '';
      kelasId = kelasNested['id']?.toString();
    } else {
      namaKelas = json['kelas']?.toString() ?? '';
      kelasId = json['kelas_id']?.toString();
    }

    return SiswaModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama'] ?? '',
      nis: json['nis'] ?? '',
      // email bisa tidak ada di object Siswa (ada di User parent)
      email: json['email'] ?? '',
      kelas: namaKelas,
      kelasId: kelasId,
      // Backend field: 'telepon_ortu' bukan 'telepon_orang_tua'
      nomorTelepon: json['telepon'] ?? json['nomor_telepon'],
      fotoProfil: json['foto_profil'],
      alamat: json['alamat'],
      tanggalLahir: json['tanggal_lahir']?.toString(),
      jenisKelamin: json['jenis_kelamin'],
      namaOrangTua: json['nama_orang_tua'],
      teleponOrangTua: json['telepon_ortu'] ?? json['telepon_orang_tua'],
      qrToken: json['qr_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nis': nis,
      'email': email,
      'kelas': kelas,
      'kelas_id': kelasId,
      'telepon': nomorTelepon,
      'foto_profil': fotoProfil,
      'alamat': alamat,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'nama_orang_tua': namaOrangTua,
      'telepon_ortu': teleponOrangTua,
      'qr_token': qrToken,
    };
  }

  /// QR Data untuk ditampilkan di halaman QR Code Siswa.
  /// Menggunakan qr_token (UUID) jika tersedia — ini yang dipindai guru
  /// dan dikirim ke POST /api/absensi/scan sebagai field 'qr_token'.
  /// Fallback ke format string lama jika qr_token belum ada.
  String toQrData() {
    if (qrToken != null && qrToken!.isNotEmpty) {
      return qrToken!;
    }
    // Fallback format (dev only)
    return 'EDUBLUE_STUDENT_${id}_${nis}_${nama}_${kelas}';
  }

  SiswaModel copyWith({
    String? id,
    String? nama,
    String? nis,
    String? email,
    String? kelas,
    String? kelasId,
    String? nomorTelepon,
    String? fotoProfil,
    String? alamat,
    String? tanggalLahir,
    String? jenisKelamin,
    String? namaOrangTua,
    String? teleponOrangTua,
    String? qrToken,
  }) {
    return SiswaModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nis: nis ?? this.nis,
      email: email ?? this.email,
      kelas: kelas ?? this.kelas,
      kelasId: kelasId ?? this.kelasId,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      alamat: alamat ?? this.alamat,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      namaOrangTua: namaOrangTua ?? this.namaOrangTua,
      teleponOrangTua: teleponOrangTua ?? this.teleponOrangTua,
      qrToken: qrToken ?? this.qrToken,
    );
  }

  /// Data dummy untuk fallback / preview UI
  static SiswaModel dummy() {
    return const SiswaModel(
      id: 'S001',
      nama: 'Ahmad Rizki Pratama',
      nis: '2024001',
      email: 'ahmad.rizki@edublue.school',
      kelas: 'X IPA 1',
      nomorTelepon: '082345678901',
      alamat: 'Jl. Pahlawan No. 5, Jakarta',
      jenisKelamin: 'Laki-laki',
      namaOrangTua: 'Bapak Agus Pratama',
      teleponOrangTua: '081234567899',
    );
  }

  @override
  String toString() =>
      'SiswaModel(id: $id, nama: $nama, nis: $nis, kelas: $kelas)';
}
