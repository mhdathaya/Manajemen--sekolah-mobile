import '../models/nilai_model.dart';
import '../services/api_service.dart';

/// Repository untuk data nilai akademik siswa
/// Endpoint: GET /api/nilai?siswa_id={id}&per_page=100
/// Backend mengembalikan paginated JSON:
///   { success, data: { data: [...records], total, per_page, ... } }
/// Repository mengelompokkan per mata pelajaran via NilaiModel.groupByMapel().
class NilaiRepository {
  final ApiService _apiService;

  NilaiRepository(this._apiService);

  /// Ambil semua nilai siswa — backend auto-filter ke siswa yang login.
  /// [siswaId] tetap dikirim sebagai query param untuk kompatibilitas
  /// (backend akan mengabaikannya jika user adalah siswa, karena sudah auto-filter).
  Future<List<NilaiModel>> getNilaiSiswa(String siswaId) async {
    try {
      final response = await _apiService.get(
        '/nilai',
        queryParameters: {
          'siswa_id': siswaId,
          'per_page': 100,
        },
      );

      final records = _parseList(response.data);
      // Kelompokkan per mapel agar cocok dengan tampilan tabel UI
      return NilaiModel.groupByMapel(records);
    } catch (e) {
      throw ApiService.parseError(e);
    }
  }

  /// Ambil nilai berdasarkan semester dan tahun ajaran
  Future<List<NilaiModel>> getNilaiBySemester(
    String siswaId,
    String semester,
    String tahunAjaran,
  ) async {
    try {
      final response = await _apiService.get(
        '/nilai',
        queryParameters: {
          'siswa_id': siswaId,
          'semester': semester,
          'tahun_ajaran': tahunAjaran,
          'per_page': 100,
        },
      );
      final records = _parseList(response.data);
      return NilaiModel.groupByMapel(records);
    } catch (e) {
      throw ApiService.parseError(e);
    }
  }

  /// Parse response paginated dari backend.
  /// Struktur: { success, data: { data: [...], total, ... } }
  List<NilaiModel> _parseList(dynamic responseData) {
    if (responseData == null) return [];

    final body = responseData as Map<String, dynamic>;
    if (body['success'] != true) return [];

    final outer = body['data'];
    if (outer == null) return [];

    // Paginated Laravel: outer adalah object { data: [...], total, ... }
    // Flat list: outer langsung berupa List
    final List rawList;
    if (outer is List) {
      rawList = outer;
    } else if (outer is Map && outer['data'] is List) {
      rawList = outer['data'] as List;
    } else {
      return [];
    }

    return rawList
        .map((e) => NilaiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Hitung rata-rata nilai akhir dari list yang sudah diaggregasi
  double hitungRataRata(List<NilaiModel> list) {
    if (list.isEmpty) return 0;
    final total = list.fold(0.0, (sum, n) => sum + n.nilaiAkhir);
    return total / list.length;
  }
}
