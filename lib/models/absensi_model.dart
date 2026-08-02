import '../core/app_constants.dart';

/// Model data Absensi
/// Disesuaikan dengan response backend GET /api/absensi
/// Backend response memiliki relasi nested:
///   "siswa": { "id":1, "nama":"...", "nis":"...", ... }
///   "kelas": { "id":1, "nama_kelas":"X IPA 1" }
///
/// Status backend: lowercase 'hadir' | 'izin' | 'sakit' | 'alfa'
/// Status UI      : 'Hadir' | 'Izin' | 'Sakit' | 'Alpha'
class AbsensiModel {
  final String id;
  final String siswaId;
  final String namaSiswa;
  final String nisSiswa;
  final String kelasSiswa;
  final String? kelasId;
  final String mataPelajaran;
  final String tanggal;
  // Status dalam format UI (huruf kapital, 'alfa' → 'Alpha')
  final String status;
  final String? guruId;
  final String? namaGuru;
  final String? keterangan;
  final String? waktuAbsen; // jam_masuk dari backend
  final String? jadwalId;

  const AbsensiModel({
    required this.id,
    required this.siswaId,
    required this.namaSiswa,
    required this.nisSiswa,
    required this.kelasSiswa,
    this.kelasId,
    required this.mataPelajaran,
    required this.tanggal,
    required this.status,
    this.guruId,
    this.namaGuru,
    this.keterangan,
    this.waktuAbsen,
    this.jadwalId,
  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    // Parse nested siswa
    final siswaNested = json['siswa'];
    final String siswaId;
    final String namaSiswa;
    final String nisSiswa;

    if (siswaNested is Map) {
      siswaId = siswaNested['id']?.toString() ?? '';
      namaSiswa = siswaNested['nama']?.toString() ?? '';
      nisSiswa = siswaNested['nis']?.toString() ?? '';
    } else {
      siswaId = json['siswa_id']?.toString() ?? '';
      namaSiswa = json['nama_siswa']?.toString() ?? '';
      nisSiswa = json['nis_siswa']?.toString() ?? '';
    }

    // Parse nested kelas
    final kelasNested = json['kelas'];
    final String kelasSiswa;
    final String? kelasId;

    if (kelasNested is Map) {
      kelasSiswa = kelasNested['nama_kelas']?.toString() ?? '';
      kelasId = kelasNested['id']?.toString();
    } else {
      kelasSiswa = json['kelas_siswa']?.toString() ?? '';
      kelasId = json['kelas_id']?.toString();
    }

    // Normalize status: backend lowercase → UI display format
    final rawStatus = json['status']?.toString() ?? '';
    final displayStatus = _normalizeStatus(rawStatus);

    // tanggal bisa berupa "2025-07-28T00:00:00.000000Z" atau "2025-07-28"
    final rawTanggal = json['tanggal']?.toString() ?? '';
    final tanggal = rawTanggal.length > 10 ? rawTanggal.substring(0, 10) : rawTanggal;

    return AbsensiModel(
      id: json['id']?.toString() ?? '',
      siswaId: siswaId,
      namaSiswa: namaSiswa,
      nisSiswa: nisSiswa,
      kelasSiswa: kelasSiswa,
      kelasId: kelasId,
      mataPelajaran: json['mata_pelajaran']?.toString() ?? '',
      tanggal: tanggal,
      status: displayStatus,
      guruId: json['guru_id']?.toString(),
      namaGuru: json['nama_guru']?.toString(),
      keterangan: json['keterangan']?.toString(),
      // Backend field: jam_masuk
      waktuAbsen: json['jam_masuk']?.toString() ?? json['waktu_absen']?.toString(),
      jadwalId: json['jadwal_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siswa_id': siswaId,
      'nama_siswa': namaSiswa,
      'nis_siswa': nisSiswa,
      'kelas_siswa': kelasSiswa,
      'kelas_id': kelasId,
      'mata_pelajaran': mataPelajaran,
      'tanggal': tanggal,
      // Kirim ke API dalam lowercase
      'status': _denormalizeStatus(status),
      'guru_id': guruId,
      'nama_guru': namaGuru,
      'keterangan': keterangan,
      'jam_masuk': waktuAbsen,
      'jadwal_id': jadwalId,
    };
  }

  /// Backend lowercase → UI display (Kapital)
  static String _normalizeStatus(String raw) {
    return AppConstants.statusLabel[raw.toLowerCase()] ?? _capitalize(raw);
  }

  /// UI display → backend lowercase
  static String _denormalizeStatus(String display) {
    final map = {
      'Hadir': 'hadir',
      'Izin': 'izin',
      'Sakit': 'sakit',
      'Alpha': 'alfa',
      'Alfa': 'alfa',
    };
    return map[display] ?? display.toLowerCase();
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  AbsensiModel copyWith({
    String? id,
    String? siswaId,
    String? namaSiswa,
    String? nisSiswa,
    String? kelasSiswa,
    String? kelasId,
    String? mataPelajaran,
    String? tanggal,
    String? status,
    String? guruId,
    String? namaGuru,
    String? keterangan,
    String? waktuAbsen,
    String? jadwalId,
  }) {
    return AbsensiModel(
      id: id ?? this.id,
      siswaId: siswaId ?? this.siswaId,
      namaSiswa: namaSiswa ?? this.namaSiswa,
      nisSiswa: nisSiswa ?? this.nisSiswa,
      kelasSiswa: kelasSiswa ?? this.kelasSiswa,
      kelasId: kelasId ?? this.kelasId,
      mataPelajaran: mataPelajaran ?? this.mataPelajaran,
      tanggal: tanggal ?? this.tanggal,
      status: status ?? this.status,
      guruId: guruId ?? this.guruId,
      namaGuru: namaGuru ?? this.namaGuru,
      keterangan: keterangan ?? this.keterangan,
      waktuAbsen: waktuAbsen ?? this.waktuAbsen,
      jadwalId: jadwalId ?? this.jadwalId,
    );
  }

  /// Data dummy untuk Guru - Riwayat Absensi
  static List<AbsensiModel> dummyGuru() {
    return [
      const AbsensiModel(
        id: 'A001', siswaId: 'S001', namaSiswa: 'Ahmad Rizki Pratama',
        nisSiswa: '2024001', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Matematika', tanggal: '2025-07-28',
        status: 'Hadir', namaGuru: 'Budi Santoso, S.Pd.',
        waktuAbsen: '07:35',
      ),
      const AbsensiModel(
        id: 'A002', siswaId: 'S002', namaSiswa: 'Bening Putri Sari',
        nisSiswa: '2024002', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Matematika', tanggal: '2025-07-28',
        status: 'Hadir', namaGuru: 'Budi Santoso, S.Pd.',
        waktuAbsen: '07:33',
      ),
      const AbsensiModel(
        id: 'A003', siswaId: 'S003', namaSiswa: 'Candra Maulana',
        nisSiswa: '2024003', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Matematika', tanggal: '2025-07-28',
        status: 'Izin', namaGuru: 'Budi Santoso, S.Pd.',
        keterangan: 'Keperluan keluarga',
      ),
      const AbsensiModel(
        id: 'A004', siswaId: 'S004', namaSiswa: 'Dian Fitriana',
        nisSiswa: '2024004', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Matematika', tanggal: '2025-07-25',
        status: 'Sakit', namaGuru: 'Budi Santoso, S.Pd.',
        keterangan: 'Demam',
      ),
      const AbsensiModel(
        id: 'A005', siswaId: 'S005', namaSiswa: 'Eko Prasetyo',
        nisSiswa: '2024005', kelasSiswa: 'X IPA 2',
        mataPelajaran: 'Matematika', tanggal: '2025-07-25',
        status: 'Alpha', namaGuru: 'Budi Santoso, S.Pd.',
      ),
    ];
  }

  /// Data dummy untuk Siswa - Riwayat Absensi
  static List<AbsensiModel> dummySiswa() {
    return [
      const AbsensiModel(
        id: 'AS001', siswaId: 'S001', namaSiswa: 'Ahmad Rizki Pratama',
        nisSiswa: '2024001', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Matematika', tanggal: '2025-07-28',
        status: 'Hadir', namaGuru: 'Budi Santoso, S.Pd.',
        waktuAbsen: '07:35',
      ),
      const AbsensiModel(
        id: 'AS002', siswaId: 'S001', namaSiswa: 'Ahmad Rizki Pratama',
        nisSiswa: '2024001', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Fisika', tanggal: '2025-07-27',
        status: 'Sakit', namaGuru: 'Hendra Wijaya, M.Pd.',
        keterangan: 'Demam',
      ),
      const AbsensiModel(
        id: 'AS003', siswaId: 'S001', namaSiswa: 'Ahmad Rizki Pratama',
        nisSiswa: '2024001', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Kimia', tanggal: '2025-07-26',
        status: 'Hadir', namaGuru: 'Dewi Lestari, S.Pd.',
        waktuAbsen: '10:02',
      ),
      const AbsensiModel(
        id: 'AS004', siswaId: 'S001', namaSiswa: 'Ahmad Rizki Pratama',
        nisSiswa: '2024001', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Biologi', tanggal: '2025-07-25',
        status: 'Izin', namaGuru: 'Rina Kartika, S.Pd.',
        keterangan: 'Acara keluarga',
      ),
      const AbsensiModel(
        id: 'AS005', siswaId: 'S001', namaSiswa: 'Ahmad Rizki Pratama',
        nisSiswa: '2024001', kelasSiswa: 'X IPA 1',
        mataPelajaran: 'Bahasa Inggris', tanggal: '2025-07-24',
        status: 'Alpha', namaGuru: 'Michael Tan, S.Pd.',
      ),
    ];
  }

  @override
  String toString() =>
      'AbsensiModel(id: $id, siswa: $namaSiswa, status: $status, tanggal: $tanggal)';
}
