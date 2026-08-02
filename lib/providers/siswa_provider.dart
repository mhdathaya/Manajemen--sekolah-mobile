import 'package:flutter/material.dart';
import '../models/jadwal_model.dart';
import '../models/nilai_model.dart';
import '../models/absensi_model.dart';
import '../repositories/jadwal_repository.dart';
import '../repositories/nilai_repository.dart';
import '../repositories/absensi_repository.dart';

enum LoadState { initial, loading, loaded, error }

/// Provider untuk data dan state halaman Siswa
class SiswaProvider extends ChangeNotifier {
  final JadwalRepository _jadwalRepository;
  final NilaiRepository _nilaiRepository;
  final AbsensiRepository _absensiRepository;

  // Jadwal
  LoadState _jadwalState = LoadState.initial;
  List<JadwalModel> _jadwalList = [];

  // Nilai
  LoadState _nilaiState = LoadState.initial;
  List<NilaiModel> _nilaiList = [];

  // Absensi
  LoadState _absensiState = LoadState.initial;
  List<AbsensiModel> _absensiList = [];

  SiswaProvider(
    this._jadwalRepository,
    this._nilaiRepository,
    this._absensiRepository,
  );

  // Getters - Jadwal
  LoadState get jadwalState => _jadwalState;
  List<JadwalModel> get jadwalList => _jadwalList;

  // Getters - Nilai
  LoadState get nilaiState => _nilaiState;
  List<NilaiModel> get nilaiList => _nilaiList;
  double get rataRataNilai => _nilaiRepository.hitungRataRata(_nilaiList);

  // Getters - Absensi
  LoadState get absensiState => _absensiState;
  List<AbsensiModel> get absensiList => _absensiList;

  /// Statistik kehadiran
  Map<String, int> get statistikAbsensi {
    final hadir = _absensiList.where((a) => a.status.toLowerCase() == 'hadir').length;
    final izin = _absensiList.where((a) => a.status.toLowerCase() == 'izin').length;
    final sakit = _absensiList.where((a) => a.status.toLowerCase() == 'sakit').length;
    final alpha = _absensiList.where((a) => a.status.toLowerCase() == 'alfa' || a.status.toLowerCase() == 'alpha').length;
    return {'hadir': hadir, 'izin': izin, 'sakit': sakit, 'alpha': alpha};
  }

  /// Reset semua data — dipanggil saat logout atau ganti akun
  void reset() {
    _jadwalState = LoadState.initial;
    _nilaiState = LoadState.initial;
    _absensiState = LoadState.initial;
    _jadwalList = [];
    _nilaiList = [];
    _absensiList = [];
    notifyListeners();
  }

  /// Muat jadwal siswa
  Future<void> loadJadwal(String siswaId, {bool forceRefresh = false}) async {
    if (_jadwalState == LoadState.loaded && !forceRefresh) return;

    _jadwalState = LoadState.loading;
    notifyListeners();

    try {
      _jadwalList = await _jadwalRepository.getJadwalSiswa(siswaId);
      _jadwalState = LoadState.loaded;
    } catch (e) {
      _jadwalState = LoadState.error;
    }
    notifyListeners();
  }

  /// Muat nilai siswa
  Future<void> loadNilai(String siswaId, {bool forceRefresh = false}) async {
    if (_nilaiState == LoadState.loaded && !forceRefresh) return;

    _nilaiState = LoadState.loading;
    notifyListeners();

    try {
      _nilaiList = await _nilaiRepository.getNilaiSiswa(siswaId);
      _nilaiState = LoadState.loaded;
    } catch (e) {
      _nilaiState = LoadState.error;
    }
    notifyListeners();
  }

  /// Muat riwayat absensi siswa
  Future<void> loadAbsensi(String siswaId, {bool forceRefresh = false}) async {
    if (_absensiState == LoadState.loaded && !forceRefresh) return;

    _absensiState = LoadState.loading;
    notifyListeners();

    try {
      _absensiList = await _absensiRepository.getRiwayatAbsensiSiswa(siswaId);
      _absensiState = LoadState.loaded;
    } catch (e) {
      _absensiState = LoadState.error;
    }
    notifyListeners();
  }

  /// Muat semua data siswa sekaligus
  Future<void> loadAll(String siswaId, {bool forceRefresh = false}) async {
    await Future.wait([
      loadJadwal(siswaId, forceRefresh: forceRefresh),
      loadNilai(siswaId, forceRefresh: forceRefresh),
      loadAbsensi(siswaId, forceRefresh: forceRefresh),
    ]);
  }

  /// Pull-to-refresh
  Future<void> refresh(String siswaId) async {
    await loadAll(siswaId, forceRefresh: true);
  }

  /// Dapatkan jadwal per hari
  Map<String, List<JadwalModel>> get jadwalPerHari {
    final Map<String, List<JadwalModel>> result = {};
    for (final j in _jadwalList) {
      result.putIfAbsent(j.hari, () => []).add(j);
    }
    return result;
  }
}
