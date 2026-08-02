import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';
import '../models/absensi_model.dart';
import '../models/siswa_model.dart';
import '../repositories/jadwal_repository.dart';
import '../repositories/absensi_repository.dart';

/// Enum state loading
enum LoadState { initial, loading, loaded, error }

/// Provider untuk data dan state halaman Guru
class GuruProvider extends ChangeNotifier {
  final JadwalRepository _jadwalRepository;
  final AbsensiRepository _absensiRepository;

  // Jadwal
  LoadState _jadwalState = LoadState.initial;
  List<JadwalModel> _jadwalList = [];
  List<JadwalModel> _jadwalHariIni = [];

  // Riwayat Absensi
  LoadState _absensiState = LoadState.initial;
  List<AbsensiModel> _absensiList = [];
  List<AbsensiModel> _absensiFiltered = [];
  String _searchQuery = '';
  DateTime? _filterTanggal;

  // Scan QR
  SiswaModel? _scannedSiswa;
  bool _isSavingAbsensi = false;
  String? _scanError;
  String? _selectedMapel; // mapel yang dipilih guru saat scan

  GuruProvider(this._jadwalRepository, this._absensiRepository);

  // Getters - Jadwal
  LoadState get jadwalState => _jadwalState;
  List<JadwalModel> get jadwalList => _jadwalList;
  List<JadwalModel> get jadwalHariIni => _jadwalHariIni;
  int get jumlahJadwalHariIni => _jadwalHariIni.length;

  // Getters - Absensi
  LoadState get absensiState => _absensiState;
  List<AbsensiModel> get absensiList => _absensiFiltered;
  String get searchQuery => _searchQuery;
  DateTime? get filterTanggal => _filterTanggal;

  // Getters - Scan QR
  SiswaModel? get scannedSiswa => _scannedSiswa;
  bool get isSavingAbsensi => _isSavingAbsensi;
  String? get scanError => _scanError;
  String? get selectedMapel => _selectedMapel;

  /// Muat jadwal mengajar guru
  Future<void> loadJadwal(String guruId, {bool forceRefresh = false}) async {
    if (_jadwalState == LoadState.loaded && !forceRefresh) return;

    _jadwalState = LoadState.loading;
    notifyListeners();

    try {
      _jadwalList = await _jadwalRepository.getJadwalGuru(guruId);
      _jadwalHariIni = await _jadwalRepository.getJadwalHariIniGuru(guruId);
      _jadwalState = LoadState.loaded;
    } catch (e) {
      _jadwalState = LoadState.error;
    }
    notifyListeners();
  }

  /// Muat riwayat absensi guru
  Future<void> loadAbsensi(String guruId, {bool forceRefresh = false}) async {
    if (_absensiState == LoadState.loaded && !forceRefresh) return;

    _absensiState = LoadState.loading;
    notifyListeners();

    try {
      _absensiList = await _absensiRepository.getRiwayatAbsensiGuru(guruId);
      _applyFilters();
      _absensiState = LoadState.loaded;
    } catch (e) {
      _absensiState = LoadState.error;
    }
    notifyListeners();
  }

  /// Reset semua data — dipanggil saat logout atau ganti akun
  void reset() {
    _jadwalState = LoadState.initial;
    _jadwalList = [];
    _jadwalHariIni = [];
    _absensiState = LoadState.initial;
    _absensiList = [];
    _absensiFiltered = [];
    _searchQuery = '';
    _filterTanggal = null;
    _scannedSiswa = null;
    _scanError = null;
    _selectedMapel = null;
    _isSavingAbsensi = false;
    notifyListeners();
  }

  /// Set mata pelajaran yang dipilih guru untuk sesi scan
  void setSelectedMapel(String mapel) {
    _selectedMapel = mapel;
    notifyListeners();
  }

  /// Set hasil scan QR Code — jika UUID, otomatis fetch data siswa dari backend
  void setScannedSiswa(SiswaModel siswa) {
    _scannedSiswa = siswa;
    _scanError = null;
    notifyListeners();
  }

  /// Fetch data siswa dari backend menggunakan qr_token (UUID),
  /// lalu update _scannedSiswa dengan data lengkap (nama, NIS, kelas).
  Future<void> fetchSiswaByQrToken(String qrToken) async {
    final result = await _absensiRepository.lookupSiswaByQr(qrToken);
    if (result['success'] == true && result['data'] is Map) {
      final d = result['data'] as Map<String, dynamic>;
      _scannedSiswa = SiswaModel(
        id: d['id']?.toString() ?? qrToken,
        nama: d['nama']?.toString() ?? '-',
        nis: d['nis']?.toString() ?? '-',
        kelas: d['kelas']?.toString() ?? '-',
        kelasId: d['kelas_id']?.toString(),
        email: '',
        qrToken: d['qr_token']?.toString() ?? qrToken,
      );
      _scanError = null;
    } else {
      _scanError = result['message'] ?? 'Siswa tidak ditemukan.';
      _scannedSiswa = null;
    }
    notifyListeners();
  }

  /// Set error scan QR
  void setScanError(String error) {
    _scanError = error;
    _scannedSiswa = null;
    notifyListeners();
  }

  /// Reset data scan QR (tidak reset selectedMapel agar bisa scan siswa berikutnya)
  void resetScan() {
    _scannedSiswa = null;
    _scanError = null;
    notifyListeners();
  }

  /// Reset scan + mapel (dipanggil saat keluar dari halaman scan)
  void resetScanFull() {
    _scannedSiswa = null;
    _scanError = null;
    _selectedMapel = null;
    notifyListeners();
  }

  /// Simpan absensi dari hasil scan QR
  /// [mataPelajaran] opsional — jika kosong pakai _selectedMapel
  Future<Map<String, dynamic>> simpanAbsensi({
    required String guruId,
    required String namaGuru,
    String? mataPelajaran,
    String status = 'hadir',
    String? keterangan,
  }) async {
    if (_scannedSiswa == null) {
      return {'success': false, 'message': 'Data siswa tidak ditemukan.'};
    }

    final mapel = mataPelajaran ?? _selectedMapel ?? 'Umum';

    _isSavingAbsensi = true;
    notifyListeners();

    final now = DateTime.now();
    final tanggal =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final waktu =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final absensi = AbsensiModel(
      id: 'NEW_${DateTime.now().millisecondsSinceEpoch}',
      siswaId: _scannedSiswa!.qrToken ?? _scannedSiswa!.id,
      namaSiswa: _scannedSiswa!.nama,
      nisSiswa: _scannedSiswa!.nis,
      kelasSiswa: _scannedSiswa!.kelas,
      kelasId: _scannedSiswa!.kelasId,
      mataPelajaran: mapel,
      tanggal: tanggal,
      status: status,
      guruId: guruId,
      namaGuru: namaGuru,
      waktuAbsen: waktu,
      keterangan: keterangan,
    );

    final result = await _absensiRepository.simpanAbsensi(absensi);

    if (result['success'] == true) {
      _absensiList.insert(0, absensi);
      _applyFilters();
    }

    _isSavingAbsensi = false;
    notifyListeners();

    return result;
  }

  /// Set pencarian absensi
  void setSearch(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Set filter tanggal absensi
  void setFilterTanggal(DateTime? tanggal) {
    _filterTanggal = tanggal;
    _applyFilters();
    notifyListeners();
  }

  /// Reset semua filter
  void resetFilters() {
    _searchQuery = '';
    _filterTanggal = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<AbsensiModel>.from(_absensiList);

    if (_searchQuery.isNotEmpty) {
      result = _absensiRepository.filterByKeyword(result, _searchQuery);
    }

    if (_filterTanggal != null) {
      result = _absensiRepository.filterByTanggal(result, _filterTanggal!);
    }

    _absensiFiltered = result;
  }

  /// Pull-to-refresh
  Future<void> refresh(String guruId) async {
    await loadJadwal(guruId, forceRefresh: true);
    await loadAbsensi(guruId, forceRefresh: true);
  }
}
