import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_responsive.dart';
import '../../models/absensi_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siswa_provider.dart';
import '../../utils/app_utils.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';

/// Halaman Riwayat Absensi Siswa
class SiswaRiwayatAbsensiScreen extends StatelessWidget {
  const SiswaRiwayatAbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final siswa = context.watch<AuthProvider>().siswa;
    final provider = context.watch<SiswaProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            provider.loadAbsensi(siswa?.id ?? '', forceRefresh: true),
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SiswaProvider provider) {
    if (provider.absensiState == LoadState.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerList(count: 6),
      );
    }

    if (provider.absensiState == LoadState.error) {
      return ErrorState(
        onRetry: () => provider.loadAbsensi(
          context.read<AuthProvider>().siswa?.id ?? '',
          forceRefresh: true,
        ),
      );
    }

    if (provider.absensiList.isEmpty) {
      return const EmptyState(
        icon: Icons.history_toggle_off,
        title: 'Belum ada riwayat',
        subtitle: 'Riwayat absensi belum tersedia.',
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.hPad(context),
        vertical: 16,
      ),
      children: [
        _buildStatistikCard(provider),
        const SizedBox(height: 16),
        _buildSectionTitle('Riwayat Kehadiran'),
        const SizedBox(height: 8),
        if (AppResponsive.isWide(context))
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: provider.absensiList.length,
            itemBuilder: (_, i) => _buildAbsensiCard(provider.absensiList[i]),
          )
        else
          ...provider.absensiList.map((a) => _buildAbsensiCard(a)),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatistikCard(SiswaProvider provider) {
    final stats = provider.statistikAbsensi;
    final total = provider.absensiList.length;
    final hadir = stats['hadir'] ?? 0;
    final persen = total > 0 ? (hadir / total * 100).toStringAsFixed(1) : '0';

    return GradientCard(
      gradient: AppColors.headerGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Kehadiran',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$persen%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tingkat Kehadiran',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$hadir dari $total pertemuan',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _statChip('Hadir', '${stats['hadir']}', AppColors.hadir),
              const SizedBox(width: 8),
              _statChip('Izin', '${stats['izin']}', AppColors.izin),
              const SizedBox(width: 8),
              _statChip('Sakit', '${stats['sakit']}', AppColors.sakit),
              const SizedBox(width: 8),
              _statChip('Alpha', '${stats['alpha']}', AppColors.alpha),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildAbsensiCard(AbsensiModel absensi) {
    final statusColor = AppUtils.getAbsensiColor(absensi.status);
    final statusIcon = AppUtils.getAbsensiIcon(absensi.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        elevation: 1,
        child: Row(
          children: [
            // Status icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    absensi.mataPelajaran,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.isoToLongDate(absensi.tanggal),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (absensi.namaGuru != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          absensi.namaGuru!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (absensi.keterangan != null &&
                      absensi.keterangan!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Keterangan: ${absensi.keterangan}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            AbsensiStatusBadge(status: absensi.status),
          ],
        ),
      ),
    );
  }
}
