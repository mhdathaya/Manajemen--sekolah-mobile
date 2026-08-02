import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_responsive.dart';
import '../../models/absensi_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guru_provider.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';

/// Halaman Riwayat Absensi - Guru
class GuruRiwayatAbsensiScreen extends StatefulWidget {
  const GuruRiwayatAbsensiScreen({super.key});

  @override
  State<GuruRiwayatAbsensiScreen> createState() =>
      _GuruRiwayatAbsensiScreenState();
}

class _GuruRiwayatAbsensiScreenState extends State<GuruRiwayatAbsensiScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, GuruProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.filterTanggal ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      provider.setFilterTanggal(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guru = context.watch<AuthProvider>().guru;
    final provider = context.watch<GuruProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        actions: [
          if (provider.filterTanggal != null || _searchCtrl.text.isNotEmpty)
            TextButton(
              onPressed: () {
                provider.resetFilters();
                _searchCtrl.clear();
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => provider.loadAbsensi(guru?.id ?? '', forceRefresh: true),
        child: Column(
          children: [
            _buildSearchAndFilter(context, provider),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppResponsive.isWide(context)
                        ? AppResponsive.hPad(context) - 16
                        : 0),
                child: _buildBody(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, GuruProvider provider) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchCtrl,
            onChanged: provider.setSearch,
            decoration: InputDecoration(
              hintText: 'Cari nama siswa, NIS, atau mata pelajaran...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        provider.setSearch('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          // Filter tanggal
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              const Text(
                'Filter tanggal:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _pickDate(context, provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: provider.filterTanggal != null
                        ? AppColors.primaryContainer
                        : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.filterTanggal != null
                          ? AppColors.primary
                          : AppColors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: provider.filterTanggal != null
                            ? AppColors.primary
                            : AppColors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.filterTanggal != null
                            ? DateFormatter.formatShortDate(
                                provider.filterTanggal!)
                            : 'Pilih tanggal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: provider.filterTanggal != null
                              ? AppColors.primary
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.filterTanggal != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => provider.setFilterTanggal(null),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(GuruProvider provider) {
    if (provider.absensiState == LoadState.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: ShimmerList(count: 6),
      );
    }

    if (provider.absensiState == LoadState.error) {
      return ErrorState(
        onRetry: () => provider.loadAbsensi(
          context.read<AuthProvider>().guru?.id ?? '',
          forceRefresh: true,
        ),
      );
    }

    final list = provider.absensiList;

    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.history_toggle_off,
        title: 'Tidak ada data absensi',
        subtitle: 'Belum ada riwayat absensi yang cocok dengan filter.',
      );
    }

    return AppResponsive.isWide(context)
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.6,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) => _buildAbsensiCard(list[i]),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _buildAbsensiCard(list[i]),
          );
  }

  Widget _buildAbsensiCard(AbsensiModel absensi) {
    return CustomCard(
      elevation: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar initial
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              absensi.namaSiswa.isNotEmpty
                  ? absensi.namaSiswa[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        absensi.namaSiswa,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    AbsensiStatusBadge(status: absensi.status),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'NIS: ${absensi.nisSiswa}  •  ${absensi.kelasSiswa}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.book_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        absensi.mataPelajaran,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.isoToShortDate(absensi.tanggal),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (absensi.waktuAbsen != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        absensi.waktuAbsen!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (absensi.keterangan != null &&
                    absensi.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ket: ${absensi.keterangan}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
