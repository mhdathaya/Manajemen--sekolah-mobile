import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';

/// Halaman QR Code Siswa - ditampilkan saat absensi oleh guru
class SiswaQrCodeScreen extends StatelessWidget {
  const SiswaQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final siswa = context.watch<AuthProvider>().siswa;
    final qrData = siswa?.toQrData() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('QR Code Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header info
            _buildInfoHeader(siswa),
            const SizedBox(height: 28),
            // QR Code card
            _buildQrCard(context, qrData),
            const SizedBox(height: 24),
            // Instruksi
            _buildInstruksi(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoHeader(dynamic siswa) {
    return GradientCard(
      gradient: AppColors.headerGradient,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              siswa?.nama != null && (siswa!.nama as String).isNotEmpty
                  ? (siswa.nama as String)[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa?.nama ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'NIS: ${siswa?.nis ?? '-'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  'Kelas: ${siswa?.kelas ?? '-'}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(BuildContext context, String qrData) {
    return CustomCard(
      elevation: 4,
      child: Column(
        children: [
          // QR Code label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_2, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'QR Code Absensi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // QR Code widget
          if (qrData.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: AppConstants.qrCodeSize,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primaryDark,
                ),
              ),
            )
          else
            const SizedBox(
              width: AppConstants.qrCodeSize,
              height: AppConstants.qrCodeSize,
              child: Center(
                child: Text(
                  'Data tidak tersedia',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          const SizedBox(height: 16),
          // App watermark
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.school_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstruksi() {
    final steps = [
      'Tunjukkan QR Code ini kepada guru saat proses absensi berlangsung.',
      'Pastikan layar tidak terlalu gelap agar QR Code mudah dipindai.',
      'Jangan bagikan QR Code ini kepada orang lain.',
      'QR Code ini berisi data identitas Anda untuk keperluan absensi.',
    ];

    return CustomCard(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.info),
              SizedBox(width: 8),
              Text(
                'Petunjuk Penggunaan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
