import 'package:flutter/material.dart';

/// Palet warna utama aplikasi EduBlue
class AppColors {
  AppColors._();

  // Primary - Biru Laut
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryContainer = Color(0xFFD0E4FF);

  // Secondary - Biru Muda
  static const Color secondary = Color(0xFF42A5F5);
  static const Color secondaryLight = Color(0xFF80D8FF);
  static const Color secondaryContainer = Color(0xFFE3F2FD);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFF0F2F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF616161);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0BEC5);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Nilai (nilai akademik)
  static const Color nilaiTinggi = Color(0xFF2E7D32);   // >= 80
  static const Color nilaiSedang = Color(0xFFF57C00);   // 70-79
  static const Color nilaiRendah = Color(0xFFC62828);   // < 70

  // Absensi status
  static const Color hadir = Color(0xFF2E7D32);
  static const Color izin = Color(0xFF0277BD);
  static const Color sakit = Color(0xFFF57C00);
  static const Color alpha = Color(0xFFC62828);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
  );
}
