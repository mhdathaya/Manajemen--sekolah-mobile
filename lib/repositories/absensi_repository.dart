import '../models/absensi_model.dart';
import '../services/api_service.dart';

/// Repository untuk data absensi
/// Endpoint: GET /api/absensi  (paginated, filter by kelas/siswa/tanggal/status)
/// Scan QR : POST /api/absensi/scan
class AbsensiRepository {
  final ApiService _apiService;

  AbsensiRepository(this._apiService);

  /// Lookup data siswa dari qr_token sebelum konfirmasi absen.
  /// Endpoint: POST /api/siswa/lookup-qr
  Future<Map<String, dynamic>> lookupSiswaByQr(String qrToken) async {
    try {
      final response = await _apiService.post(
        '/siswa/lookup-qr',
        data: {'qr_token': qrToken},
      );
      final body = response.data as Map<String, dynamic>;
      return {
        'success': body['success'] == true,
        'message': body['message'] ?? '',
        'data': body['data'],
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.parseError(e)};
    }
  }

  /// Ambil riwayat absensi untuk guru (semua kelas yang diajar).
  /// Backend auto-filter ke kelas milik guru yang login.
  Future<List<AbsensiModel>> getRiwayatAbsensiGuru(String guruId) async {
    try {
      final response = await _apiService.get(
        '/absensi',
        queryParameters: {'per_page': 100},
      );
      return _parseList(response.data);
    } catch (e) {
      throw ApiService.parseError(e);
    }
  }

  /// Ambil riwayat absensi siswa berdasarkan siswa_id.
  Future<List<AbsensiModel>> getRiwayatAbsensiSiswa(String siswaId) async {
    try {
      final response = await _apiService.get(
        '/absensi',
        queryParameters: {
          'siswa_id': siswaId,
          'per_page': 100,
        },
      );
      return _parseList(response.data);
    } catch (e) {
      throw ApiService.parseError(e);
    }
  }

  /// Simpan absensi via QR Scan — POST /api/absensi/scan
  /// Backend membutuhkan:
  ///   - qr_token     : string (UUID dari model Siswa)
  ///   - kelas_id     : int
  ///   - mata_pelajaran: string
  ///   - tanggal      : date (opsional, default hari ini)
  Future<Map<String, dynamic>> simpanAbsensi(AbsensiModel absensi) async {
    try {
      final response = await _apiService.post(
        '/absensi/scan',
        data: {
          'qr_token': absensi.siswaId, // siswaId diisi dengan qr_token saat scan
          'kelas_id': absensi.kelasId,
          'mata_pelajaran': absensi.mataPelajaran,
          'tanggal': absensi.tanggal,
          'status': absensi.status,
          if (absensi.keterangan != null) 'keterangan': absensi.keterangan,
        },
      );

      final body = response.data as Map<String, dynamic>;

      // Backend mengembalikan success:false dengan duplicate:true jika sudah absen
      if (body['success'] == false && body['duplicate'] == true) {
        return {
          'success': false,
          'duplicate': true,
          'message': body['message'] ?? 'Siswa sudah absen hari ini.',
        };
      }

      return {
        'success': body['success'] == true,
        'message': body['message'] ?? 'Absensi berhasil disimpan.',
        'data': body['data'],
      };
    } catch (e) {
      return {'success': false, 'message': ApiService.parseError(e)};
    }
  }

  /// Parse response (paginated) dari backend
  List<AbsensiModel> _parseList(dynamic responseData) {
    if (responseData == null) return [];
    final body = responseData as Map<String, dynamic>;
    final data = body['data'];
    if (data == null) return [];

    // Paginated: { data: { data: [...], total: ..., ... } }
    // atau flat: { data: [...] }
    final List rawList = data is List ? data : (data['data'] as List? ?? []);
    return rawList
        .map((e) => AbsensiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Filter absensi berdasarkan tanggal (client-side)
  List<AbsensiModel> filterByTanggal(
    List<AbsensiModel> list,
    DateTime tanggal,
  ) {
    final dateStr =
        '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
    return list.where((a) => a.tanggal == dateStr).toList();
  }

  /// Filter absensi berdasarkan keyword pencarian (client-side)
  List<AbsensiModel> filterByKeyword(
    List<AbsensiModel> list,
    String keyword,
  ) {
    final q = keyword.toLowerCase();
    return list
        .where(
          (a) =>
              a.namaSiswa.toLowerCase().contains(q) ||
              a.mataPelajaran.toLowerCase().contains(q) ||
              a.nisSiswa.contains(q),
        )
        .toList();
  }
}
