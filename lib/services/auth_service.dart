import '../models/user_model.dart';
import '../models/guru_model.dart';
import '../models/siswa_model.dart';
import '../core/app_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Service untuk autentikasi via Laravel Sanctum
///
/// Backend endpoint: POST /api/auth/login
/// Validasi backend: email (required, email format) + password
///
/// Seeder credentials:
///   Guru  : budi@sekolah.sch.id  / password123
///   Admin : admin@sekolah.sch.id / password123
///   Siswa : tidak ada user account di seeder (perlu tambah manual)
class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

  /// Login Guru menggunakan email + password
  /// identifier = email guru (contoh: budi@sekolah.sch.id)
  Future<Map<String, dynamic>> loginGuru({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': identifier,
          'password': password,
        },
      );

      final body = response.data as Map<String, dynamic>;

      if (body['success'] != true) {
        return {
          'success': false,
          'message': body['message'] ?? 'Login gagal.',
        };
      }

      final data = body['data'] as Map<String, dynamic>;
      final token = data['token']?.toString() ?? '';
      final userMap = data['user'] as Map<String, dynamic>;
      final role = userMap['role']?.toString() ?? '';

      if (role != AppConstants.roleGuru && role != AppConstants.roleAdmin) {
        return {
          'success': false,
          'message': 'Akun ini bukan akun Guru.',
        };
      }

      // Simpan token agar request /auth/me bisa terautentikasi
      await _storageService.saveToken(token);

      // Ambil detail guru dari GET /api/auth/me
      // Response: { success, data: { id, name, email, role, guru: {...} } }
      final meData = await _fetchMe();
      final guruNested = meData?['guru'] as Map<String, dynamic>?;

      final userData = <String, dynamic>{
        'id': userMap['id']?.toString() ?? '',
        'nama': guruNested?['nama'] ?? userMap['name'] ?? '',
        'email': userMap['email'] ?? '',
        'nip': guruNested?['nip'] ?? '',
        'telepon': guruNested?['telepon'],
        'mata_pelajaran': guruNested?['mata_pelajaran'],
        'jabatan': guruNested?['jabatan'],
        'jenis_kelamin': guruNested?['jenis_kelamin'],
        'alamat': guruNested?['alamat'],
        // guru_id dari tabel gurus (bukan users)
        'guru_id': guruNested?['id']?.toString() ?? '',
        'role': role,
        'token': token,
      };

      await _storageService.saveUserRole(role);
      await _storageService.saveUserId(userData['guru_id'] as String);
      await _storageService.saveUserName(userData['nama'] as String);
      await _storageService.saveUserEmail(userData['email'] as String);
      await _storageService.saveLoginStatus(true);
      await _storageService.saveUserData(userData);

      return {'success': true, 'data': userData};
    } catch (e) {
      // Untuk DioException 422 (ValidationException Laravel),
      // parseError sudah mengambil pesan dari errors.email
      return {
        'success': false,
        'message': ApiService.parseError(e),
      };
    }
  }

  /// Login Siswa menggunakan email atau NIS + password
  /// Jika [identifier] berisi '@', dianggap sebagai email langsung.
  /// Jika tidak, dianggap sebagai NIS dan dikonversi ke format {nis}@sekolah.sch.id
  Future<Map<String, dynamic>> loginSiswa({
    required String identifier,
    required String password,
  }) async {
    try {
      // Deteksi apakah input adalah email atau NIS
      final String email = identifier.contains('@')
          ? identifier
          : '$identifier@sekolah.sch.id';

      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final body = response.data as Map<String, dynamic>;

      if (body['success'] != true) {
        return {
          'success': false,
          'message': body['message'] ?? 'Login gagal.',
        };
      }

      final data = body['data'] as Map<String, dynamic>;
      final token = data['token']?.toString() ?? '';
      final userMap = data['user'] as Map<String, dynamic>;
      final role = userMap['role']?.toString() ?? '';

      if (role != AppConstants.roleSiswa) {
        return {
          'success': false,
          'message': 'Akun ini bukan akun Siswa.',
        };
      }

      await _storageService.saveToken(token);

      // GET /api/auth/me — sekarang return data.siswa (dengan kelas)
      final meData = await _fetchMe();
      final siswaNested = meData?['siswa'] as Map<String, dynamic>?;
      final kelasNested = siswaNested?['kelas'] as Map<String, dynamic>?;

      final userData = <String, dynamic>{
        'id': siswaNested?['id']?.toString() ?? userMap['id']?.toString() ?? '',
        'nama': siswaNested?['nama'] ?? userMap['name'] ?? '',
        'nis': siswaNested?['nis'] ?? '',
        'email': userMap['email'] ?? '',
        'kelas': kelasNested?['nama_kelas'] ?? '',
        'kelas_id': kelasNested?['id']?.toString() ?? siswaNested?['kelas_id']?.toString(),
        'telepon': siswaNested?['telepon'],
        'telepon_ortu': siswaNested?['telepon_ortu'],
        'jenis_kelamin': siswaNested?['jenis_kelamin'],
        'tanggal_lahir': siswaNested?['tanggal_lahir']?.toString(),
        'alamat': siswaNested?['alamat'],
        'qr_token': siswaNested?['qr_token'],
        'role': role,
        'token': token,
      };

      await _storageService.saveUserRole(role);
      await _storageService.saveUserId(userData['id'] as String);
      await _storageService.saveUserName(userData['nama'] as String);
      await _storageService.saveUserEmail(userData['email'] as String);
      await _storageService.saveLoginStatus(true);
      await _storageService.saveUserData(userData);

      return {'success': true, 'data': userData};
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.parseError(e),
      };
    }
  }

  /// GET /api/auth/me — ambil profil user yang sedang login
  /// Response: { success, data: { id, name, email, role, guru?: {...} } }
  Future<Map<String, dynamic>?> _fetchMe() async {
    try {
      final response = await _apiService.get('/auth/me');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  /// POST /api/auth/logout — hapus token dari backend
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (_) {
      // Abaikan error jaringan saat logout
    } finally {
      await _storageService.clearAll();
    }
  }

  bool isLoggedIn() => _storageService.isLoggedIn();

  String? getUserRole() => _storageService.getUserRole();

  UserModel? getCurrentUser() {
    final data = _storageService.getUserData();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  GuruModel? getCurrentGuru() {
    final data = _storageService.getUserData();
    if (data == null) return null;
    return GuruModel.fromJson(data);
  }

  SiswaModel? getCurrentSiswa() {
    final data = _storageService.getUserData();
    if (data == null) return null;
    return SiswaModel.fromJson(data);
  }
}
