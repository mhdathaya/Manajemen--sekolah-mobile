/// Konstanta global aplikasi EduBlue
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'EduBlue';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Sistem Manajemen Sekolah';

  // API Base URL — device fisik via IP lokal
  // Laragon www: C:\laragon\www\manajemen_sekolah → symlink ke E:\manajemen_sekolah\backend\public
  // URL yang diakses: http://192.168.100.177/manajemen_sekolah/api
  static const String baseUrl =
      'http://192.168.100.177/manajemen_sekolah/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // SharedPreferences Keys
  static const String keyToken = 'auth_token';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserData = 'user_data';
  // Key tambahan untuk menyimpan data guru & siswa secara terpisah
  static const String keyGuruData = 'guru_data';
  static const String keySiswaData = 'siswa_data';

  // User Roles — sesuai dengan nilai field 'role' di database backend
  static const String roleGuru = 'guru';
  static const String roleSiswa = 'siswa';
  static const String roleAdmin = 'admin';

  // Absensi Status — backend menggunakan lowercase
  static const String statusHadir = 'hadir';
  static const String statusIzin = 'izin';
  static const String statusSakit = 'sakit';
  static const String statusAlfa = 'alfa'; // backend: alfa (bukan alpha)

  // Label display untuk status (huruf kapital untuk UI)
  static const Map<String, String> statusLabel = {
    'hadir': 'Hadir',
    'izin': 'Izin',
    'sakit': 'Sakit',
    'alfa': 'Alpha',
  };

  // Hari
  static const List<String> hariList = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu',
  ];

  // Pagination
  static const int defaultPageSize = 20;

  // Animation
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Splash
  static const Duration splashDuration = Duration(seconds: 2);

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // QR Code
  static const double qrCodeSize = 250.0;
  static const String qrCodePrefix = 'EDUBLUE_STUDENT_';
}
