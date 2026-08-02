import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guru_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_card.dart';

/// Halaman Profil Guru
class GuruProfilScreen extends StatelessWidget {
  const GuruProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guru = context.watch<AuthProvider>().guru;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Photo & name
            _buildProfileHeader(guru),
            const SizedBox(height: 20),
            // Info detail
            _buildInfoSection(
              title: 'Informasi Akun',
              items: [
                _InfoItem(Icons.badge_outlined, 'NIP', guru?.nip ?? '-'),
                _InfoItem(Icons.email_outlined, 'Email', guru?.email ?? '-'),
                _InfoItem(
                  Icons.phone_outlined,
                  'Telepon',
                  guru?.nomorTelepon ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Informasi Profesi',
              items: [
                _InfoItem(
                  Icons.school_outlined,
                  'Mata Pelajaran',
                  guru?.mataPelajaran ?? '-',
                ),
                _InfoItem(
                  Icons.work_outline,
                  'Jabatan',
                  guru?.jabatan ?? '-',
                ),
                _InfoItem(
                  Icons.wc,
                  'Jenis Kelamin',
                  guru?.jenisKelamin ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Logout button
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic guru) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 52, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            guru?.nama ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Guru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<_InfoItem> items,
  }) {
    return CustomCard(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                _buildInfoRow(e.value),
                if (!isLast) const Divider(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _konfirmasiLogout(context),
        icon: const Icon(Icons.logout),
        label: const Text('Keluar dari Akun'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _konfirmasiLogout(BuildContext context) async {
    final confirm = await AppUtils.showConfirmDialog(
      context,
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar dari akun?',
      confirmText: 'Keluar',
      cancelText: 'Batal',
      confirmColor: AppColors.error,
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout(
        onBeforeLogout: () {
          context.read<GuruProvider>().reset();
        },
      );
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem(this.icon, this.label, this.value);
}
