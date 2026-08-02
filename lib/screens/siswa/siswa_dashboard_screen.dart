import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siswa_provider.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';

class SiswaDashboardScreen extends StatelessWidget {
  const SiswaDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final siswa = context.watch<AuthProvider>().siswa;
    final provider = context.watch<SiswaProvider>();
    final hPad = AppResponsive.hPad(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => provider.refresh(siswa?.id ?? ''),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, siswa?.nama ?? ''),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                child: AppResponsive.isWide(context)
                    ? _buildWideBody(context, siswa, provider)
                    : _buildNarrowBody(context, siswa, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowBody(
      BuildContext context, dynamic siswa, SiswaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileCard(siswa),
        const SizedBox(height: 16),
        _buildStatRow(context, provider),
        const SizedBox(height: 20),
        _sectionTitle('Menu Utama'),
        const SizedBox(height: 12),
        _buildMenuGrid(context,
            cols: AppResponsive.menuCols(context, phone: 3)),
        const SizedBox(height: 20),
        _sectionTitle('Jadwal Hari Ini'),
        const SizedBox(height: 12),
        _buildJadwalHariIni(context, provider),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildWideBody(
      BuildContext context, dynamic siswa, SiswaProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildProfileCard(siswa)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildStatRow(context, provider)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Jadwal Hari Ini'),
                  const SizedBox(height: 12),
                  _buildJadwalHariIni(context, provider),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Menu Utama'),
                  const SizedBox(height: 12),
                  _buildMenuGrid(context,
                      cols: AppResponsive.menuCols(
                          context, phone: 3, tablet: 3, desktop: 3)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, String nama) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: AppColors.primary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Halo, ${nama.split(' ').first}! 👋',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          Text(DateFormatter.formatFullDate(DateTime.now()),
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileCard(dynamic siswa) {
    return GradientCard(
      gradient: AppColors.headerGradient,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              siswa?.nama != null && (siswa!.nama as String).isNotEmpty
                  ? (siswa.nama as String)[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(siswa?.nama ?? '-',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('NIS: ${siswa?.nis ?? '-'}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                Text('Kelas: ${siswa?.kelas ?? '-'}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Siswa',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, SiswaProvider provider) {
    final stats = provider.statistikAbsensi;
    final isWide = AppResponsive.isWide(context);
    final items = [
      _StatMini(label: 'Hadir', value: '${stats['hadir'] ?? 0}',
          color: AppColors.hadir, icon: Icons.check_circle),
      _StatMini(label: 'Izin', value: '${stats['izin'] ?? 0}',
          color: AppColors.izin, icon: Icons.assignment_ind),
      _StatMini(label: 'Sakit', value: '${stats['sakit'] ?? 0}',
          color: AppColors.sakit, icon: Icons.local_hospital),
      _StatMini(label: 'Alpha', value: '${stats['alpha'] ?? 0}',
          color: AppColors.alpha, icon: Icons.cancel),
    ];

    if (isWide) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.0,
        children: items,
      );
    }
    return Row(
      children: items
          .map((w) => Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: w),
              ))
          .toList(),
    );
  }

  Widget _buildMenuGrid(BuildContext context, {required int cols}) {
    final menus = [
      _MenuData('Jadwal\nPelajaran', Icons.calendar_month, AppColors.primary),
      _MenuData('Nilai\nAkademik', Icons.grade, AppColors.secondary),
      _MenuData('Riwayat\nAbsensi', Icons.history, AppColors.success),
      _MenuData('QR Code\nSaya', Icons.qr_code_2, AppColors.warning),
      _MenuData('Profil\nSaya', Icons.person_pin, AppColors.info),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: AppResponsive.menuRatio(context),
      children: menus.map((m) => _MenuCard(data: m)).toList(),
    );
  }

  Widget _buildJadwalHariIni(BuildContext context, SiswaProvider provider) {
    if (provider.jadwalState == LoadState.loading) {
      return const ShimmerList(count: 2, cardHeight: 72);
    }
    final hariIni = DateFormatter.formatDayName(DateTime.now());
    final jadwalHariIni =
        provider.jadwalList.where((j) => j.hari == hariIni).toList();

    if (jadwalHariIni.isEmpty) {
      return CustomCard(
        child: const Row(
          children: [
            Icon(Icons.event_available, color: AppColors.success),
            SizedBox(width: 12),
            Text('Tidak ada jadwal hari ini',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      children: jadwalHariIni.map((j) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: CustomCard(
            elevation: 1,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(j.jamMulai,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(j.mataPelajaran,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('${j.namaGuru ?? '-'}  •  ${j.ruangan}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
      );
}

class _StatMini extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatMini(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 1,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MenuData {
  final String label;
  final IconData icon;
  final Color color;
  _MenuData(this.label, this.icon, this.color);
}

class _MenuCard extends StatelessWidget {
  final _MenuData data;
  const _MenuCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 2,
      onTap: () {},
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(height: 5),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3),
          ),
        ],
      ),
    );
  }
}
