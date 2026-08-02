import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_responsive.dart';
import '../../models/nilai_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siswa_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';

class SiswaNilaiScreen extends StatelessWidget {
  const SiswaNilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final siswa = context.watch<AuthProvider>().siswa;
    final provider = context.watch<SiswaProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Nilai Akademik')),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            provider.loadNilai(siswa?.id ?? '', forceRefresh: true),
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SiswaProvider provider) {
    if (provider.nilaiState == LoadState.loading) {
      return const Padding(
          padding: EdgeInsets.all(16),
          child: ShimmerList(count: 6, cardHeight: 68));
    }
    if (provider.nilaiState == LoadState.error) {
      return ErrorState(
        onRetry: () => provider.loadNilai(
            context.read<AuthProvider>().siswa?.id ?? '',
            forceRefresh: true),
      );
    }
    if (provider.nilaiList.isEmpty) {
      return const EmptyState(
        icon: Icons.grade_outlined,
        title: 'Belum ada nilai',
        subtitle: 'Nilai akademik belum tersedia.',
      );
    }

    final hPad = AppResponsive.hPad(context);
    final isWide = AppResponsive.isWide(context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      children: [
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSummaryCard(provider)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLegend()),
                ],
              )
            : Column(
                children: [
                  _buildSummaryCard(provider),
                  const SizedBox(height: 16),
                  _buildLegend(),
                ],
              ),
        const SizedBox(height: 16),
        _buildNilaiTable(context, provider.nilaiList),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSummaryCard(SiswaProvider provider) {
    final avg = provider.rataRataNilai;
    final predikat = AppUtils.getNilaiPredikat(avg);

    return GradientCard(
      gradient: AppColors.headerGradient,
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(predikat,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rata-rata Nilai Akhir',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(avg.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800)),
              Text('${provider.nilaiList.length} mata pelajaran',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(AppColors.nilaiTinggi, '≥ 80', 'Baik'),
          _legendItem(AppColors.nilaiSedang, '70-79', 'Cukup'),
          _legendItem(AppColors.nilaiRendah, '< 70', 'Kurang'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String range, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(range,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildNilaiTable(BuildContext context, List<NilaiModel> list) {
    // Di layar lebar: tampilkan 2 kolom tabel nilai berdampingan
    if (AppResponsive.isWide(context) && list.length > 1) {
      final mid = (list.length / 2).ceil();
      final left = list.sublist(0, mid);
      final right = list.sublist(mid);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildTableCard(left, startIndex: 0)),
          const SizedBox(width: 16),
          Expanded(child: _buildTableCard(right, startIndex: mid)),
        ],
      );
    }
    return _buildTableCard(list, startIndex: 0);
  }

  Widget _buildTableCard(List<NilaiModel> list, {required int startIndex}) {
    return CustomCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _buildTableHeader(),
          ...list.asMap().entries.map((e) {
            final globalIndex = e.key + startIndex;
            return _buildNilaiRow(
                e.value, e.key == list.length - 1, globalIndex.isEven);
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('Mata Pelajaran',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12))),
          Expanded(
              child: Text('Tugas',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center)),
          Expanded(
              child: Text('UTS',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center)),
          Expanded(
              child: Text('UAS',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center)),
          Expanded(
              child: Text('Akhir',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildNilaiRow(NilaiModel nilai, bool isLast, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven
            ? AppColors.white
            : AppColors.greyLight.withValues(alpha: 0.5),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(nilai.mataPelajaran,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          Expanded(child: _nilaiCell(nilai.nilaiTugas)),
          Expanded(child: _nilaiCell(nilai.nilaiUts)),
          Expanded(child: _nilaiCell(nilai.nilaiUas)),
          Expanded(
            child: Center(child: NilaiBadge(nilai: nilai.nilaiAkhir)),
          ),
        ],
      ),
    );
  }

  Widget _nilaiCell(double nilai) {
    return Center(
      child: Text(
        nilai.toStringAsFixed(0),
        style: TextStyle(
            fontSize: 12,
            color: AppUtils.getNilaiColor(nilai),
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
