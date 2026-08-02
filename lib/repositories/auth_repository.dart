import '../models/user_model.dart';
import '../models/guru_model.dart';
import '../models/siswa_model.dart';
import '../services/auth_service.dart';

/// Repository layer untuk autentikasi - abstraksi antara provider dan service
class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<Map<String, dynamic>> loginGuru({
    required String identifier,
    required String password,
  }) {
    return _authService.loginGuru(
      identifier: identifier,
      password: password,
    );
  }

  Future<Map<String, dynamic>> loginSiswa({
    required String identifier,
    required String password,
  }) {
    return _authService.loginSiswa(identifier: identifier, password: password);
  }

  Future<void> logout() => _authService.logout();

  bool isLoggedIn() => _authService.isLoggedIn();

  String? getUserRole() => _authService.getUserRole();

  UserModel? getCurrentUser() => _authService.getCurrentUser();

  GuruModel? getCurrentGuru() => _authService.getCurrentGuru();

  SiswaModel? getCurrentSiswa() => _authService.getCurrentSiswa();
}
