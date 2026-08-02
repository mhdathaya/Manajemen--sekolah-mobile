import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_responsive.dart';
import '../../models/jadwal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guru_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';

class GuruJadwalScreen extends StatefulWidget {
  const GuruJadwalScreen({super.key});
  @override
  State<GuruJadwalScreen> createState() => _GuruJadwalScreenState();
}

class _GuruJadwalScreenState extends State<GuruJadwalScreen> {
  String _selectedHari = 'Semua';
  final List<String> _hariOptions = ['Semua', ...AppConstants.hariList];

  @override
  Widget build(BuildContext context) {
    final guru = context.watch<AuthProvider>().guru;
    final provider = context.watch<GuruProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jadwal Mengajar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildHariFilter(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            provider.loadJadwal(guru?.id ?? '', forceRefresh: true),
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
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, GuruProvider provider) {
    if (provider.jadwalState == LoadState.loading) {
      return const Padding(
          padding: EdgeInsets.all(16), child: ShimmerList(count: 5));
    }
    if (provider.jadwalState == LoadState.error) {
      return ErrorState(
        onRetry: () => provider.loadJadwal(
            context.read<AuthProvider>().guru?.id ?? '',
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
            ? 'Belum ada jadwal mengajar.'
            : 'Tidak ada jadwal pada hari $_selectedHari.',
      );
    }

    final Map<String, List<JadwalModel>> grouped = {};
    for (final j in list) {
      grouped.putIfAbsent(j.hari, () => []).add(j);
    }

    final hPad = AppResponsive.hPad(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      children: [
        _buildSummaryCard(provider.jadwalList.length),
        const SizedBox(height: 16),
        // Di layar lebar: tampilkan dua kolom per hari
        if (AppResponsive.isWide(context))
          ...grouped.entries
              .map((e) => _buildHariSectionWide(e.key, e.value))
        else
          ...grouped.entries
              .map((e) => _buildHariSection(e.key, e.value)),
      ],
    );
  }

  Widget _buildSummaryCard(int total) {
    return GradientCard(
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Jadwal Mengajar',
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
        const SizedBox(height: 8),
      ],
    );
  }

  // Wide: grid 2 kolom per hari
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
          childAspectRatio: 3.2,
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
              width: 64,
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
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Container(
                      width: 1,
                      height: 12,
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 2),
                  Text(jadwal.jamSelesai,
                      style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
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
                  Row(
                    children: [
                      const Icon(Icons.class_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(jadwal.kelas,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.room_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(jadwal.ruangan,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
