import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../utils/app_utils.dart';

/// Badge status absensi (Hadir, Izin, Sakit, Alpha)
class AbsensiStatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;

  const AbsensiStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.getAbsensiColor(status);
    final icon = AppUtils.getAbsensiIcon(status);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge nilai akademik dengan warna indikator
class NilaiBadge extends StatelessWidget {
  final double nilai;
  final bool showPredikat;

  const NilaiBadge({super.key, required this.nilai, this.showPredikat = false});

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.getNilaiColor(nilai);
    final predikat = AppUtils.getNilaiPredikat(nilai);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nilai.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (showPredikat) ...[
              const SizedBox(width: 4),
              Text(
                '($predikat)',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chip untuk hari pelajaran
class HariChip extends StatelessWidget {
  final String hari;
  final bool isActive;

  const HariChip({super.key, required this.hari, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        hari,
        style: TextStyle(
          color: isActive ? AppColors.white : AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
