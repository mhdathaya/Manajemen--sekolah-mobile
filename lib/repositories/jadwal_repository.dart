import '../models/jadwal_model.dart';
import '../services/api_service.dart';

/// Repository untuk data jadwal pelajaran
/// Endpoint: GET /api/jadwal
/// Backend auto-filter berdasarkan role user (guru → jadwal sendiri)
class JadwalRepository {
  final ApiService _apiService;

  JadwalRepository(this._apiService);

  /// Ambil jadwal mengajar guru.
  /// Backend sudah auto-filter ke guru yang login (tidak perlu kirim guru_id).
  /// guruId diterima untuk kompatibilitas provider yang sudah ada.
  Future<List<JadwalModel>> getJadwalGuru(String guruId) async {
    try {
      final response = await _apiService.get('/jadwal');
      return _parseList(response.data);
    } catch (e) {
      throw ApiService.parseError(e);
    }
  }

  /// Ambil jadwal pelajaran siswa berdasarkan kelas siswa.
  /// Kirim kelas_id sebagai query param.
  /// siswaId diterima untuk kompatibilitas provider yang sudah ada.
  Future<List<JadwalModel>> getJadwalSiswa(String siswaId) async {
    try {
      // Endpoint sama, backend filter berdasarkan token user
      // Untuk siswa, kirim kelas_id jika tersedia di storage
      final response = await _apiService.get('/jadwal');
      return _parseList(response.data);
    } catch (e) {
      throw ApiService.parseError(e);
    }
  }

  /// Ambil jadwal siswa berdasarkan kelas_id (lebih akurat)
  Future<List<JadwalModel>> getJadwalByKelas(String kelasId) async {
    try {
      final response = await _apiService.get(
        '/jadwal',
        queryParameters: {'kelas_id': kelasId},
      );
      return _parseList(response.data);
    } catch (e) {
      throw ApiService.parseError(e);
    }
  }

  /// Ambil jadwal mengajar hari ini untuk guru
  Future<List<JadwalModel>> getJadwalHariIniGuru(String guruId) async {
    try {
      final semua = await getJadwalGuru(guruId);
      final hariIni = _getHariIndonesia(DateTime.now().weekday);
      return semua.where((j) => j.hari == hariIni).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Parse response data dari backend
  List<JadwalModel> _parseList(dynamic responseData) {
    if (responseData == null) return [];
    final body = responseData as Map<String, dynamic>;
    final data = body['data'];
    if (data == null) return [];

    // Response bisa berupa List langsung atau paginated object
    final List rawList = data is List ? data : (data['data'] as List? ?? []);
    return rawList
        .map((e) => JadwalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _getHariIndonesia(int weekday) {
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return hari[weekday - 1];
  }
}
