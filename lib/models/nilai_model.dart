/// Model data Nilai Akademik Siswa
///
/// Penyesuaian dengan backend GET /api/nilai:
/// Backend menyimpan nilai per-record dengan field:
///   - jenis  : 'UH' | 'UTS' | 'UAS' | 'Tugas'
///   - nilai  : double (single score)
///   - kkm    : double
///   - grade  : string (computed: A/B/C/D/E)
///   - lulus  : bool  (computed: nilai >= kkm)
///
/// Flutter UI menampilkan per-mapel dengan kolom Tugas, UTS, UAS, Akhir.
/// Solusi: backend dikirim sebagai list record, lalu dikelompokkan per mapel
/// menggunakan [NilaiModel.groupByMapel].
class NilaiModel {
  final String id;
  final String siswaId;
  final String mataPelajaran;
  // Nilai per jenis (single record dari backend)
  final double nilai;
  final String jenis; // UH | UTS | UAS | Tugas
  final double kkm;
  final String? grade;
  final bool? lulus;
  final String? semester;
  final String? tahunAjaran;
  final String? namaGuru;
  final String? tanggal;
  final String? catatan;

  // Field UI aggregated (diisi dari groupByMapel, bukan dari JSON langsung)
  final double nilaiTugas;
  final double nilaiUts;
  final double nilaiUas;
  final double nilaiAkhir;

  const NilaiModel({
    required this.id,
    required this.siswaId,
    required this.mataPelajaran,
    required this.nilai,
    this.jenis = '',
    this.kkm = 75,
    this.grade,
    this.lulus,
    this.semester,
    this.tahunAjaran,
    this.namaGuru,
    this.tanggal,
    this.catatan,
    this.nilaiTugas = 0,
    this.nilaiUts = 0,
    this.nilaiUas = 0,
    this.nilaiAkhir = 0,
  });

  /// Parse single record dari backend
  factory NilaiModel.fromJson(Map<String, dynamic> json) {
    // Nama guru dari relasi nested
    final guruNested = json['guru'];
    final String? namaGuru = guruNested is Map
        ? guruNested['nama']?.toString()
        : json['nama_guru']?.toString();

    final double nilaiVal = (json['nilai'] ?? 0).toDouble();

    return NilaiModel(
      id: json['id']?.toString() ?? '',
      siswaId: json['siswa_id']?.toString() ?? '',
      mataPelajaran: json['mata_pelajaran'] ?? '',
      nilai: nilaiVal,
      jenis: json['jenis'] ?? '',
      kkm: (json['kkm'] ?? 75).toDouble(),
      grade: json['grade']?.toString(),
      lulus: json['lulus'] is bool ? json['lulus'] : null,
      semester: json['semester'],
      tahunAjaran: json['tahun_ajaran'],
      namaGuru: namaGuru,
      tanggal: json['tanggal']?.toString(),
      catatan: json['catatan'],
      // Saat parse single record, nilaiAkhir = nilai itu sendiri
      nilaiAkhir: nilaiVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siswa_id': siswaId,
      'mata_pelajaran': mataPelajaran,
      'nilai': nilai,
      'jenis': jenis,
      'kkm': kkm,
      'semester': semester,
      'tahun_ajaran': tahunAjaran,
      'nama_guru': namaGuru,
      'tanggal': tanggal,
      'catatan': catatan,
    };
  }

  /// Kelompokkan list record backend per mata pelajaran.
  /// Hasilnya adalah list NilaiModel per mapel dengan field
  /// nilaiTugas/nilaiUts/nilaiUas/nilaiAkhir sudah terisi.
  /// Ini yang dikonsumsi oleh UI tabel nilai.
  static List<NilaiModel> groupByMapel(List<NilaiModel> records) {
    final Map<String, List<NilaiModel>> grouped = {};
    for (final r in records) {
      grouped.putIfAbsent(r.mataPelajaran, () => []).add(r);
    }

    return grouped.entries.map((entry) {
      final mapel = entry.key;
      final list = entry.value;

      // Ambil nilai per jenis — rata-rata jika ada lebih dari satu record
      double _avg(String jenis) {
        final filtered = list.where(
          (r) => r.jenis.toUpperCase() == jenis.toUpperCase(),
        ).toList();
        if (filtered.isEmpty) return 0;
        return filtered.fold(0.0, (s, r) => s + r.nilai) / filtered.length;
      }

      final tugas = _avg('Tugas');
      final uts = _avg('UTS');
      final uas = _avg('UAS');
      // Nilai akhir: Tugas 30%, UTS 30%, UAS 40%
      final akhir = (tugas * 0.3) + (uts * 0.3) + (uas * 0.4);

      // Gunakan record pertama sebagai basis (id, guru, semester, dll)
      final base = list.first;

      return NilaiModel(
        id: base.id,
        siswaId: base.siswaId,
        mataPelajaran: mapel,
        nilai: akhir,
        jenis: 'Aggregated',
        kkm: base.kkm,
        semester: base.semester,
        tahunAjaran: base.tahunAjaran,
        namaGuru: base.namaGuru,
        nilaiTugas: tugas,
        nilaiUts: uts,
        nilaiUas: uas,
        nilaiAkhir: akhir,
      );
    }).toList();
  }

  /// Hitung nilai akhir: Tugas 30%, UTS 30%, UAS 40%
  static double hitungNilaiAkhir(double tugas, double uts, double uas) {
    return (tugas * 0.3) + (uts * 0.3) + (uas * 0.4);
  }

  /// Data dummy untuk fallback / preview UI
  static List<NilaiModel> dummy() {
    return [
      const NilaiModel(
        id: 'N001', siswaId: 'S001', mataPelajaran: 'Matematika',
        nilai: 82.0, jenis: 'Aggregated',
        nilaiTugas: 85, nilaiUts: 78, nilaiUas: 82, nilaiAkhir: 82.0,
        semester: 'Ganjil', tahunAjaran: '2024/2025',
        namaGuru: 'Budi Santoso, S.Pd.',
      ),
      const NilaiModel(
        id: 'N002', siswaId: 'S001', mataPelajaran: 'Bahasa Indonesia',
        nilai: 87.4, jenis: 'Aggregated',
        nilaiTugas: 90, nilaiUts: 88, nilaiUas: 85, nilaiAkhir: 87.4,
        semester: 'Ganjil', tahunAjaran: '2024/2025',
        namaGuru: 'Siti Rahayu, S.Pd.',
      ),
      const NilaiModel(
        id: 'N003', siswaId: 'S001', mataPelajaran: 'Fisika',
        nilai: 69.1, jenis: 'Aggregated',
        nilaiTugas: 72, nilaiUts: 65, nilaiUas: 70, nilaiAkhir: 69.1,
        semester: 'Ganjil', tahunAjaran: '2024/2025',
        namaGuru: 'Hendra Wijaya, M.Pd.',
      ),
      const NilaiModel(
        id: 'N004', siswaId: 'S001', mataPelajaran: 'Kimia',
        nilai: 70.7, jenis: 'Aggregated',
        nilaiTugas: 75, nilaiUts: 70, nilaiUas: 68, nilaiAkhir: 70.7,
        semester: 'Ganjil', tahunAjaran: '2024/2025',
        namaGuru: 'Dewi Lestari, S.Pd.',
      ),
      const NilaiModel(
        id: 'N005', siswaId: 'S001', mataPelajaran: 'Biologi',
        nilai: 85.6, jenis: 'Aggregated',
        nilaiTugas: 88, nilaiUts: 82, nilaiUas: 86, nilaiAkhir: 85.6,
        semester: 'Ganjil', tahunAjaran: '2024/2025',
        namaGuru: 'Rina Kartika, S.Pd.',
      ),
      const NilaiModel(
        id: 'N006', siswaId: 'S001', mataPelajaran: 'Bahasa Inggris',
        nilai: 77.7, jenis: 'Aggregated',
        nilaiTugas: 80, nilaiUts: 75, nilaiUas: 78, nilaiAkhir: 77.7,
        semester: 'Ganjil', tahunAjaran: '2024/2025',
        namaGuru: 'Michael Tan, S.Pd.',
      ),
      const NilaiModel(
        id: 'N007', siswaId: 'S001', mataPelajaran: 'Sejarah',
        nilai: 57.7, jenis: 'Aggregated',
        nilaiTugas: 60, nilaiUts: 55, nilaiUas: 58, nilaiAkhir: 57.7,
        semester: 'Ganjil', tahunAjaran: '2024/2025',
        namaGuru: 'Ahmad Fauzi, S.Pd.',
      ),
      const NilaiModel(
        id: 'N008', siswaId: 'S001', mataPelajaran: 'Pendidikan Jasmani',
        nilai: 89.8, jenis: 'Aggregated',
        nilaiTugas: 92, nilaiUts: 90, nilaiUas: 88, nilaiAkhir: 89.8,
        semester: 'Ganjil', tahunAjaran: '2024/2025',
        namaGuru: 'Joko Susanto, S.Pd.',
      ),
    ];
  }

  @override
  String toString() =>
      'NilaiModel(id: $id, mapel: $mataPelajaran, akhir: $nilaiAkhir)';
}
