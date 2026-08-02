import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import '../models/guru_model.dart';
import '../models/siswa_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Provider untuk manajemen state autentikasi
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  GuruModel? _guru;
  SiswaModel? _siswa;
  String? _userRole;

  AuthProvider(this._authRepository) {
    _initSession();
  }

  // Getters
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  GuruModel? get guru => _guru;
  SiswaModel? get siswa => _siswa;
  String? get userRole => _userRole;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isGuru => _userRole == AppConstants.roleGuru || _userRole == AppConstants.roleAdmin;
  bool get isSiswa => _userRole == AppConstants.roleSiswa;

  /// Tidak restore session saat app dibuka — user harus login ulang setiap buka app.
  /// Data SharedPreferences di-clear agar tidak ada sisa session lama.
  void _initSession() {
    _authRepository.logout(); // clear storage tanpa await — tidak perlu tunggu
    _status = AuthStatus.unauthenticated;
  }

  /// Login Guru dengan email + password
  /// Seeder: budi@sekolah.sch.id / password123
  Future<bool> loginGuru({
    required String identifier, // email guru
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.loginGuru(
      identifier: identifier,
      password: password,
    );

    if (result['success'] == true) {
      _guru = GuruModel.fromJson(result['data']);
      _userRole = (result['data']['role'] as String?) ?? AppConstants.roleGuru;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Login Siswa dengan email atau NIS + password
  /// [identifier] bisa berupa email lengkap atau NIS saja.
  /// Konversi ke email dilakukan di AuthService.
  Future<bool> loginSiswa({
    required String identifier,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.loginSiswa(
      identifier: identifier,
      password: password,
    );

    if (result['success'] == true) {
      _siswa = SiswaModel.fromJson(result['data']);
      _userRole = AppConstants.roleSiswa;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Logout — hapus token dari backend dan local storage
  Future<void> logout({
    VoidCallback? onBeforeLogout,
  }) async {
    // Beri kesempatan caller untuk reset provider lain sebelum state diubah
    onBeforeLogout?.call();

    _status = AuthStatus.loading;
    notifyListeners();

    await _authRepository.logout();

    _guru = null;
    _siswa = null;
    _userRole = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
