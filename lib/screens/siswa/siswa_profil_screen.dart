import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siswa_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_card.dart';

/// Halaman Profil Siswa — responsive, tanggal lahir terformat lengkap
class SiswaProfilScreen extends StatelessWidget {
  const SiswaProfilScreen({super.key});

  /// Format tanggal dari berbagai format backend ke "DD Bulan YYYY".
  /// Mendukung: "YYYY-MM-DD", "YYYY-MM-DDTHH:mm:ss.000Z", dll.
  static String _formatTanggal(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw == '-') return '-';
    try {
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];

      // Jika format YYYY-MM-DD (plain, tanpa waktu) — parse langsung
      // tanpa konversi timezone agar tidak bergeser hari
      final plainDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
      final matchPlain = plainDate.firstMatch(raw.trim());
      if (matchPlain != null) {
        final y = matchPlain.group(1)!;
        final m = int.parse(matchPlain.group(2)!);
        final d = int.parse(matchPlain.group(3)!);
        if (m >= 1 && m <= 12) return '$d ${bulan[m]} $y';
      }

      // Jika format ISO 8601 dengan timezone — parse via DateTime,
      // lalu ambil bagian tanggal lokal (toLocal())
      final dt = DateTime.parse(raw.trim()).toLocal();
      final m = dt.month;
      return '${dt.day} ${bulan[m]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final siswa = context.watch<AuthProvider>().siswa;
    final screenWidth = MediaQuery.of(context).size.width;
    // Breakpoint: jika lebar > 600 anggap tablet/landscape
    final isWide = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? screenWidth * 0.1 : 16,
          vertical: 16,
        ),
        child: isWide
            ? _buildWideLayout(context, siswa)
            : _buildNarrowLayout(context, siswa),
      ),
    );
  }

  // ── Layout sempit (phone portrait) ──────────────────────────────────────────

  Widget _buildNarrowLayout(BuildContext context, dynamic siswa) {
    return Column(
      children: [
        _buildProfileHeader(siswa, compact: false),
        const SizedBox(height: 20),
        _buildInfoSection(
          title: 'Informasi Akun',
          items: _akunItems(siswa),
        ),
        const SizedBox(height: 16),
        _buildInfoSection(
          title: 'Informasi Akademik',
          items: _akademikItems(siswa),
        ),
        const SizedBox(height: 16),
        _buildInfoSection(
          title: 'Informasi Orang Tua',
          items: _orangTuaItems(siswa),
        ),
        const SizedBox(height: 16),
        _buildLogoutButton(context),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Layout lebar (tablet/landscape) ─────────────────────────────────────────

  Widget _buildWideLayout(BuildContext context, dynamic siswa) {
    return Column(
      children: [
        _buildProfileHeader(siswa, compact: true),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildInfoSection(
                    title: 'Informasi Akun',
                    items: _akunItems(siswa),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    title: 'Informasi Orang Tua',
                    items: _orangTuaItems(siswa),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoSection(
                title: 'Informasi Akademik',
                items: _akademikItems(siswa),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLogoutButton(context),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Data items ───────────────────────────────────────────────────────────────

  List<_InfoItem> _akunItems(dynamic siswa) => [
        _InfoItem(Icons.badge_outlined, 'NIS', siswa?.nis ?? '-'),
        _InfoItem(Icons.email_outlined, 'Email', siswa?.email ?? '-'),
        _InfoItem(Icons.phone_outlined, 'Telepon', siswa?.nomorTelepon ?? '-'),
      ];

  List<_InfoItem> _akademikItems(dynamic siswa) => [
        _InfoItem(Icons.class_outlined, 'Kelas', siswa?.kelas ?? '-'),
        _InfoItem(
          Icons.wc,
          'Jenis Kelamin',
          _formatJenisKelamin(siswa?.jenisKelamin),
        ),
        _InfoItem(
          Icons.cake_outlined,
          'Tanggal Lahir',
          _formatTanggal(siswa?.tanggalLahir),
        ),
        _InfoItem(Icons.home_outlined, 'Alamat', siswa?.alamat ?? '-'),
      ];

  List<_InfoItem> _orangTuaItems(dynamic siswa) => [
        _InfoItem(
          Icons.family_restroom,
          'Nama Orang Tua',
          siswa?.namaOrangTua ?? '-',
        ),
        _InfoItem(
          Icons.phone_outlined,
          'Telepon Orang Tua',
          siswa?.teleponOrangTua ?? '-',
        ),
      ];

  static String _formatJenisKelamin(String? val) {
    if (val == null) return '-';
    switch (val.toUpperCase()) {
      case 'L':
        return 'Laki-laki';
      case 'P':
        return 'Perempuan';
      default:
        return val;
    }
  }

  // ── Widgets ──────────────────────────────────────────────────────────────────

  Widget _buildProfileHeader(dynamic siswa, {required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: compact ? 20 : 28,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: compact
          ? Row(
              children: [
                _buildAvatar(siswa, radius: 40),
                const SizedBox(width: 16),
                Expanded(child: _buildHeaderText(siswa)),
              ],
            )
          : Column(
              children: [
                _buildAvatar(siswa, radius: 48),
                const SizedBox(height: 14),
                _buildHeaderText(siswa),
              ],
            ),
    );
  }

  Widget _buildAvatar(dynamic siswa, {required double radius}) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: Text(
            siswa?.nama != null && (siswa!.nama as String).isNotEmpty
                ? (siswa.nama as String)[0].toUpperCase()
                : 'S',
            style: TextStyle(
              fontSize: radius * 0.8,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
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
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderText(dynamic siswa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          siswa?.nama ?? '-',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _headerChip('Kelas ${siswa?.kelas ?? '-'}'),
            _headerChip('Siswa'),
            if (siswa?.nis != null) _headerChip('NIS: ${siswa!.nis}'),
          ],
        ),
      ],
    );
  }

  Widget _headerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 2),
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
          context.read<SiswaProvider>().reset();
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
