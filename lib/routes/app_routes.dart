/// Nama-nama route untuk navigasi aplikasi EduBlue
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/';
  static const String login = '/login';

  // Guru
  static const String guruMain = '/guru/main';
  static const String guruDashboard = '/guru/dashboard';
  static const String guruJadwal = '/guru/jadwal';
  static const String guruScanQr = '/guru/scan-qr';
  static const String guruRiwayatAbsensi = '/guru/riwayat-absensi';
  static const String guruProfil = '/guru/profil';

  // Siswa
  static const String siswaMain = '/siswa/main';
  static const String siswaDashboard = '/siswa/dashboard';
  static const String siswaJadwal = '/siswa/jadwal';
  static const String siswaNilai = '/siswa/nilai';
  static const String siswaRiwayatAbsensi = '/siswa/riwayat-absensi';
  static const String siswaQrCode = '/siswa/qr-code';
  static const String siswaProfil = '/siswa/profil';
}
