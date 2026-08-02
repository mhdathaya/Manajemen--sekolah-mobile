import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_responsive.dart';
import '../../models/jadwal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siswa_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';

class SiswaJadwalScreen extends StatefulWidget {
  const SiswaJadwalScreen({super.key});
  @override
  State<SiswaJadwalScreen> createState() => _SiswaJadwalScreenState();
}

class _SiswaJadwalScreenState extends State<SiswaJadwalScreen> {
  String _selectedHari = 'Semua';
  final List<String> _hariOptions = ['Semua', ...AppConstants.hariList];

  @override
  Widget build(BuildContext context) {
    final siswa = context.watch<AuthProvider>().siswa;
    final provider = context.watch<SiswaProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jadwal Pelajaran'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildHariFilter(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            provider.loadJadwal(siswa?.id ?? '', forceRefresh: true),
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildHariFilter() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: _hariOptions.length,
        itemBuilder: (_, i) {
          final hari = _hariOptions[i];
          final active = _selectedHari == hari;
          return GestureDetector(
            onTap: () => setState(() => _selectedHari = hari),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hari,
                style: TextStyle(
                  color: active ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SiswaProvider provider) {
    if (provider.jadwalState == LoadState.loading) {
      return const Padding(
          padding: EdgeInsets.all(16), child: ShimmerList(count: 6));
    }
    if (provider.jadwalState == LoadState.error) {
      return ErrorState(
        onRetry: () => provider.loadJadwal(
            context.read<AuthProvider>().siswa?.id ?? '',
            forceRefresh: true),
      );
    }

    final list = _selectedHari == 'Semua'
        ? provider.jadwalList
        : provider.jadwalList
            .where((j) => j.hari == _selectedHari)
            .toList();

    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Tidak ada jadwal',
        subtitle: _selectedHari == 'Semua'
            ? 'Belum ada jadwal pelajaran.'
            : 'Tidak ada jadwal pada hari $_selectedHari.',
      );
    }

    final Map<String, List<JadwalModel>> grouped = {};
    for (final j in list) {
      grouped.putIfAbsent(j.hari, () => []).add(j);
    }

    final hPad = AppResponsive.hPad(context);
    final isWide = AppResponsive.isWide(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      children: [
        _buildSummary(provider.jadwalList.length),
        const SizedBox(height: 16),
        ...grouped.entries.map((e) => isWide
            ? _buildHariSectionWide(e.key, e.value)
            : _buildHariSection(e.key, e.value)),
      ],
    );
  }

  Widget _buildSummary(int total) {
    return GradientCard(
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Mata Pelajaran',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('$total Sesi / Minggu',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHariSection(String hari, List<JadwalModel> jadwalList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: HariChip(hari: hari, isActive: true),
        ),
        ...jadwalList.map((j) => _buildJadwalCard(j)),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildHariSectionWide(String hari, List<JadwalModel> jadwalList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: HariChip(hari: hari, isActive: true),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.8,
          children: jadwalList.map((j) => _buildJadwalCard(j)).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildJadwalCard(JadwalModel jadwal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        elevation: 2,
        child: Row(
          children: [
            Container(
              width: 62,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(jadwal.jamMulai,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  Container(
                    width: 1,
                    height: 10,
                    color: AppColors.primary.withValues(alpha: 0.3),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                  Text(jadwal.jamSelesai,
                      style: const TextStyle(
                          color: AppColors.primaryLight, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jadwal.mataPelajaran,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.person_outline,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(jadwal.namaGuru ?? '-',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.room_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(jadwal.ruangan,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
