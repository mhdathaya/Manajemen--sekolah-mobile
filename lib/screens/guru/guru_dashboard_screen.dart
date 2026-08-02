import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_responsive.dart';
import '../../models/jadwal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guru_provider.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_indicator.dart';

class GuruDashboardScreen extends StatelessWidget {
  const GuruDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guru = context.watch<AuthProvider>().guru;
    final provider = context.watch<GuruProvider>();
    final hPad = AppResponsive.hPad(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => provider.refresh(guru?.id ?? ''),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, guru?.nama ?? ''),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                child: AppResponsive.isWide(context)
                    ? _buildWideBody(context, guru, provider)
                    : _buildNarrowBody(context, guru, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Narrow (phone) ────────────────────────────────────────────────────────
  Widget _buildNarrowBody(BuildContext context, dynamic guru, GuruProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileCard(guru),
        const SizedBox(height: 16),
        _buildStatCards(context, provider),
        const SizedBox(height: 20),
        _sectionTitle('Jadwal Mengajar Hari Ini'),
        const SizedBox(height: 12),
        _buildJadwalHariIni(context, provider),
        const SizedBox(height: 20),
        _sectionTitle('Menu Utama'),
        const SizedBox(height: 12),
        _buildMenuGrid(context, cols: AppResponsive.menuCols(context, phone: 2)),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Wide (tablet/desktop) ─────────────────────────────────────────────────
  Widget _buildWideBody(BuildContext context, dynamic guru, GuruProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildProfileCard(guru)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildStatCards(context, provider)),
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
                  _sectionTitle('Jadwal Mengajar Hari Ini'),
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
                      cols: AppResponsive.menuCols(context, phone: 2, tablet: 2, desktop: 2)),
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
      expandedHeight: 0,
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

  Widget _buildProfileCard(dynamic guru) {
    return GradientCard(
      gradient: AppColors.headerGradient,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guru?.nama ?? '-',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(guru?.mataPelajaran ?? 'Guru',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                Text('NIP: ${guru?.nip ?? '-'}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Guru',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, GuruProvider provider) {
    final isWide = AppResponsive.isWide(context);
    final cards = [
      _StatCard(
        icon: Icons.today,
        label: 'Jadwal Hari Ini',
        value: provider.jadwalState == LoadState.loaded
            ? '${provider.jumlahJadwalHariIni} Kelas'
            : '-',
        color: AppColors.primary,
      ),
      _StatCard(
        icon: Icons.people_alt_outlined,
        label: 'Total Absensi',
        value: provider.absensiState == LoadState.loaded
            ? '${provider.absensiList.length}'
            : '-',
        color: AppColors.success,
      ),
    ];

    return isWide
        ? Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: c,
                    ))
                .toList(),
          )
        : Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          );
  }

  Widget _buildJadwalHariIni(BuildContext context, GuruProvider provider) {
    if (provider.jadwalState == LoadState.loading) {
      return const ShimmerList(count: 2, cardHeight: 72);
    }
    final jadwal = provider.jadwalHariIni;
    if (jadwal.isEmpty) {
      return CustomCard(
        child: const Row(
          children: [
            Icon(Icons.event_available, color: AppColors.success),
            SizedBox(width: 12),
            Text('Tidak ada jadwal mengajar hari ini',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }
    return Column(children: jadwal.map((j) => _JadwalCard(jadwal: j)).toList());
  }

  Widget _buildMenuGrid(BuildContext context, {required int cols}) {
    final menus = [
      _MenuData('Jadwal\nMengajar', Icons.calendar_month, AppColors.primary),
      _MenuData('Scan\nQR Code', Icons.qr_code_scanner, AppColors.secondary),
      _MenuData('Riwayat\nAbsensi', Icons.history, AppColors.success),
      _MenuData('Profil\nSaya', Icons.person_pin, AppColors.warning),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: AppResponsive.isWide(context) ? 1.2 : 1.3,
      children: menus.asMap().entries.map((e) {
        return _MenuCard(
          data: e.value,
          onTap: () {
            final scaffold =
                context.findAncestorStateOfType<State<StatefulWidget>>();
            final indices = [1, 2, 3, 4];
            if (scaffold != null) {
              (scaffold as dynamic).setState(
                  () => (scaffold as dynamic)._currentIndex = indices[e.key]);
            }
          },
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

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 2,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JadwalCard extends StatelessWidget {
  final JadwalModel jadwal;
  const _JadwalCard({required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        elevation: 1,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.class_outlined,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jadwal.mataPelajaran,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                      '${jadwal.kelas}  •  ${jadwal.jamPelajaran}  •  ${jadwal.ruangan}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
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
  final VoidCallback onTap;
  const _MenuCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: 2,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3),
          ),
        ],
      ),
    );
  }
}
