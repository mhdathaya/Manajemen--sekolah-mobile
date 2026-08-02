/// Model data Jadwal Pelajaran
/// Disesuaikan dengan response backend GET /api/jadwal
///
/// Backend Jadwal fields:
///   id, guru_id, kelas_id, mata_pelajaran, hari,
///   jam_mulai, jam_selesai, ruangan, semester, tahun_ajaran
///
/// Relasi nested:
///   guru  : { id, nama, nip, mata_pelajaran, ... }
///   kelas : { id, nama_kelas, tingkat, jurusan, ... }
class JadwalModel {
  final String id;
  final String mataPelajaran;
  final String kelas;       // dari kelas.nama_kelas
  final String? kelasId;
  final String hari;
  final String jamMulai;    // backend: jam_mulai
  final String jamSelesai;  // backend: jam_selesai
  final String ruangan;
  final String? namaGuru;   // dari guru.nama
  final String? guruId;
  final String? semester;
  final String? tahunAjaran;
  final int? urutan;

  const JadwalModel({
    required this.id,
    required this.mataPelajaran,
    required this.kelas,
    this.kelasId,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    this.namaGuru,
    this.guruId,
    this.semester,
    this.tahunAjaran,
    this.urutan,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    // Parse relasi nested guru
    final guruNested = json['guru'];
    final String? namaGuru;
    final String? guruId;
    if (guruNested is Map) {
      namaGuru = guruNested['nama']?.toString();
      guruId = guruNested['id']?.toString();
    } else {
      namaGuru = json['nama_guru']?.toString();
      guruId = json['guru_id']?.toString();
    }

    // Parse relasi nested kelas
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

    return JadwalModel(
      id: json['id']?.toString() ?? '',
      mataPelajaran: json['mata_pelajaran']?.toString() ?? '',
      kelas: namaKelas,
      kelasId: kelasId,
      hari: json['hari']?.toString() ?? '',
      // Backend field: jam_mulai / jam_selesai
      jamMulai: json['jam_mulai']?.toString() ?? '',
      jamSelesai: json['jam_selesai']?.toString() ?? '',
      ruangan: json['ruangan']?.toString() ?? '',
      namaGuru: namaGuru,
      guruId: guruId,
      semester: json['semester']?.toString(),
      tahunAjaran: json['tahun_ajaran']?.toString(),
      urutan: json['urutan'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mata_pelajaran': mataPelajaran,
      'kelas': kelas,
      'kelas_id': kelasId,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'ruangan': ruangan,
      'nama_guru': namaGuru,
      'guru_id': guruId,
      'semester': semester,
      'tahun_ajaran': tahunAjaran,
      'urutan': urutan,
    };
  }

  /// Format jam pelajaran: "07:00 - 08:30"
  String get jamPelajaran => '$jamMulai - $jamSelesai';

  static List<JadwalModel> dummyGuru() {
    return [
      const JadwalModel(
        id: 'J001', mataPelajaran: 'Matematika', kelas: 'X IPA 1',
        hari: 'Senin', jamMulai: '07:00', jamSelesai: '08:30',
        ruangan: 'R-101', namaGuru: 'Budi Santoso, S.Pd',
      ),
      const JadwalModel(
        id: 'J002', mataPelajaran: 'Matematika', kelas: 'X IPA 2',
        hari: 'Senin', jamMulai: '08:30', jamSelesai: '10:00',
        ruangan: 'R-102', namaGuru: 'Budi Santoso, S.Pd',
      ),
      const JadwalModel(
        id: 'J003', mataPelajaran: 'Matematika', kelas: 'XI IPA 1',
        hari: 'Selasa', jamMulai: '07:00', jamSelesai: '08:30',
        ruangan: 'R-201', namaGuru: 'Budi Santoso, S.Pd',
      ),
    ];
  }

  static List<JadwalModel> dummySiswa() {
    return [
      const JadwalModel(
        id: 'JS001', mataPelajaran: 'Matematika', kelas: 'X IPA 1',
        hari: 'Senin', jamMulai: '07:00', jamSelesai: '08:30',
        ruangan: 'R-101', namaGuru: 'Budi Santoso, S.Pd',
      ),
      const JadwalModel(
        id: 'JS002', mataPelajaran: 'Bahasa Indonesia', kelas: 'X IPA 1',
        hari: 'Selasa', jamMulai: '10:15', jamSelesai: '11:45',
        ruangan: 'R-101', namaGuru: 'Sinta Dewi, S.Pd',
      ),
      const JadwalModel(
        id: 'JS003', mataPelajaran: 'Fisika', kelas: 'XI IPA 1',
        hari: 'Rabu', jamMulai: '10:15', jamSelesai: '11:45',
        ruangan: 'Lab-Fisika', namaGuru: 'Ahmad Fauzi, S.T',
      ),
    ];
  }

  @override
  String toString() =>
      'JadwalModel(id: $id, mapel: $mataPelajaran, kelas: $kelas, hari: $hari)';
}
