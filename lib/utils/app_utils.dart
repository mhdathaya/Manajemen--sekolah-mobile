import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Utilitas umum untuk tampilan dan fungsionalitas
class AppUtils {
  AppUtils._();

  /// Tampilkan SnackBar sukses
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Tampilkan SnackBar error
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Tampilkan SnackBar info
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Dialog konfirmasi
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Konfirmasi',
    String cancelText = 'Batal',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Dapatkan warna berdasarkan nilai akademik
  static Color getNilaiColor(double nilai) {
    if (nilai >= 80) return AppColors.nilaiTinggi;
    if (nilai >= 70) return AppColors.nilaiSedang;
    return AppColors.nilaiRendah;
  }

  /// Dapatkan warna berdasarkan status absensi
  static Color getAbsensiColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return AppColors.hadir;
      case 'izin':
        return AppColors.izin;
      case 'sakit':
        return AppColors.sakit;
      case 'alpha':
        return AppColors.alpha;
      default:
        return AppColors.grey;
    }
  }

  /// Dapatkan ikon berdasarkan status absensi
  static IconData getAbsensiIcon(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Icons.check_circle;
      case 'izin':
        return Icons.assignment_ind;
      case 'sakit':
        return Icons.local_hospital;
      case 'alpha':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  /// Dapatkan predikat nilai
  static String getNilaiPredikat(double nilai) {
    if (nilai >= 90) return 'A';
    if (nilai >= 80) return 'B';
    if (nilai >= 70) return 'C';
    if (nilai >= 60) return 'D';
    return 'E';
  }

  /// Format nama hari Indonesia
  static String getHariIndonesia(int weekday) {
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return hari[weekday - 1];
  }

  /// Kapitalisasi kata pertama
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
