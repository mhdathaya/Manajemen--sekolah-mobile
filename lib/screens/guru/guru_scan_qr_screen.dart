import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/siswa_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guru_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/loading_indicator.dart';

/// Halaman Scan QR Code oleh Guru untuk absensi siswa.
/// Mendukung:
///   - Scan berkali-kali tanpa keluar halaman
///   - Pilih mata pelajaran sebelum scan
///   - Tampilkan nama mapel aktif di scanner
///   - Status selain Hadir (Izin, Sakit, Alfa) via bottom sheet
class GuruScanQrScreen extends StatefulWidget {
  const GuruScanQrScreen({super.key});

  @override
  State<GuruScanQrScreen> createState() => _GuruScanQrScreenState();
}

class _GuruScanQrScreenState extends State<GuruScanQrScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScanner();

    // Jika belum ada mapel dipilih, tampilkan picker setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GuruProvider>();
      if (provider.selectedMapel == null) {
        _showMapelPicker(isInitial: true);
      }
    });
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _scannerController?.stop();
    } else if (state == AppLifecycleState.resumed && _isScanning) {
      _scannerController?.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.dispose();
    // Reset penuh saat keluar halaman
    context.read<GuruProvider>().resetScanFull();
    super.dispose();
  }

  // ── Pilih Mata Pelajaran ───────────────────────────────────────────────────

  Future<void> _showMapelPicker({bool isInitial = false}) async {
    final provider = context.read<GuruProvider>();

    // Kumpulkan daftar mapel unik dari jadwal hari ini, fallback ke semua jadwal
    final jadwals = provider.jadwalHariIni.isNotEmpty
        ? provider.jadwalHariIni
        : provider.jadwalList;
    final mapels = jadwals.map((j) => j.mataPelajaran).toSet().toList();
    if (mapels.isEmpty) mapels.add('Umum');

    // Jika hanya ada satu mapel, langsung pilih tanpa dialog
    if (mapels.length == 1 && isInitial) {
      provider.setSelectedMapel(mapels.first);
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MapelPickerSheet(
        mapels: mapels,
        current: provider.selectedMapel,
        isInitial: isInitial,
      ),
    );

    if (selected != null) {
      provider.setSelectedMapel(selected);
    } else if (isInitial && provider.selectedMapel == null) {
      // Jika user dismiss tanpa pilih saat awal, pakai mapel pertama
      provider.setSelectedMapel(mapels.first);
    }
  }

  // ── Scanner logic ──────────────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final raw = barcode!.rawValue!;
    _scannerController?.stop();
    setState(() => _isScanning = false);
    _parseSiswaFromQr(raw);
  }

  void _parseSiswaFromQr(String raw) {
    try {
      if (raw.isEmpty) {
        context.read<GuruProvider>().setScanError('QR Code kosong.');
        return;
      }

      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      );

      if (uuidRegex.hasMatch(raw)) {
        final placeholder = SiswaModel(
          id: raw, qrToken: raw, nis: '', nama: '', kelas: '', email: '',
        );
        final provider = context.read<GuruProvider>();
        provider.setScannedSiswa(placeholder);
        provider.fetchSiswaByQrToken(raw);
        return;
      }

      if (raw.startsWith('EDUBLUE_STUDENT_')) {
        final parts = raw.replaceFirst('EDUBLUE_STUDENT_', '').split('_');
        if (parts.length < 4) {
          context.read<GuruProvider>().setScanError('Data QR tidak lengkap.');
          return;
        }
        context.read<GuruProvider>().setScannedSiswa(SiswaModel(
          id: parts[0], nis: parts[1], nama: parts[2],
          kelas: parts[3], email: '',
        ));
        return;
      }

      context.read<GuruProvider>().setScanError('Format QR Code tidak dikenali.');
    } catch (_) {
      context.read<GuruProvider>().setScanError('Gagal membaca QR Code.');
    }
  }

  /// Reset ke state scanning — mapel tetap tersimpan
  void _resetScan() {
    context.read<GuruProvider>().resetScan();
    setState(() => _isScanning = true);
    _scannerController?.start();
  }

  // ── Konfirmasi absensi ─────────────────────────────────────────────────────

  Future<void> _konfirmasiAbsensi(String status, {String? keterangan}) async {
    final guru = context.read<AuthProvider>().guru;
    final provider = context.read<GuruProvider>();

    final result = await provider.simpanAbsensi(
      guruId: guru?.id ?? '',
      namaGuru: guru?.nama ?? '',
      status: status,
      keterangan: keterangan,
    );

    if (!mounted) return;
    if (result['success'] == true) {
      AppUtils.showSuccessSnackbar(
        context, result['message'] ?? 'Absensi berhasil disimpan!',
      );
      _resetScan();
    } else if (result['duplicate'] == true) {
      AppUtils.showInfoSnackbar(
        context, result['message'] ?? 'Siswa sudah absen hari ini.',
      );
      _resetScan();
    } else {
      AppUtils.showErrorSnackbar(
        context, result['message'] ?? 'Gagal menyimpan absensi.',
      );
    }
  }

  /// Tampilkan bottom sheet pilih status non-hadir (Izin/Sakit/Alfa)
  Future<void> _showStatusPicker() async {
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _StatusPickerSheet(),
    );

    if (result != null && mounted) {
      await _konfirmasiAbsensi(
        result['status']!,
        keterangan: result['keterangan'],
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scan QR Code',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tombol ganti mapel
          Consumer<GuruProvider>(
            builder: (_, p, __) => TextButton.icon(
              onPressed: () => _showMapelPicker(),
              icon: const Icon(Icons.book_outlined,
                  color: Colors.white70, size: 18),
              label: Text(
                p.selectedMapel ?? 'Pilih Mapel',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          // Tombol senter
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () {
              _scannerController?.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Consumer<GuruProvider>(
        builder: (context, provider, _) {
          if (provider.scannedSiswa != null) {
            return _buildScanResult(provider);
          }
          if (provider.scanError != null) {
            return _buildScanError(provider);
          }
          return _buildScanner(provider);
        },
      ),
    );
  }

  // ── Widget: Scanner ────────────────────────────────────────────────────────

  Widget _buildScanner(GuruProvider provider) {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController!,
          onDetect: _onDetect,
        ),
        _buildScanOverlay(),
        // Chip mapel aktif di atas overlay
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.book_outlined,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    provider.selectedMapel ?? 'Belum pilih mapel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Hint bawah
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Arahkan kamera ke QR Code siswa',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanOverlay() {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }

  // ── Widget: Hasil Scan ─────────────────────────────────────────────────────

  Widget _buildScanResult(GuruProvider provider) {
    final siswa = provider.scannedSiswa!;
    final bool isLoadingData = siswa.nama.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Chip mapel aktif
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.book_outlined,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  provider.selectedMapel ?? '-',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showMapelPicker(),
                  child: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Icon status
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isLoadingData
                  ? AppColors.greyLight
                  : AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: isLoadingData
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(Icons.qr_code_2,
                    size: 44, color: AppColors.success),
          ),
          const SizedBox(height: 12),
          Text(
            isLoadingData ? 'Memuat data siswa...' : 'QR Code Terbaca!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          // Card info siswa
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isLoadingData
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Mengambil data dari server...',
                        style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          siswa.nama.isNotEmpty
                              ? siswa.nama[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _infoRow(Icons.person, 'Nama', siswa.nama),
                      const Divider(height: 20),
                      _infoRow(Icons.badge_outlined, 'NIS', siswa.nis),
                      const Divider(height: 20),
                      _infoRow(Icons.class_outlined, 'Kelas', siswa.kelas),
                      const Divider(height: 20),
                      _infoRow(Icons.book_outlined, 'Mapel',
                          provider.selectedMapel ?? '-'),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          // Tombol aksi
          LoadingOverlay(
            isLoading: provider.isSavingAbsensi,
            child: Column(
              children: [
                // Hadir
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        (provider.isSavingAbsensi || isLoadingData)
                            ? null
                            : () => _konfirmasiAbsensi('hadir'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Konfirmasi Hadir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Status lain
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        (provider.isSavingAbsensi || isLoadingData)
                            ? null
                            : _showStatusPicker,
                    icon: const Icon(Icons.more_horiz_outlined),
                    label: const Text('Status Lain (Izin/Sakit/Alfa)'),
                  ),
                ),
                const SizedBox(height: 10),
                // Scan ulang
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed:
                        provider.isSavingAbsensi ? null : _resetScan,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Siswa Berikutnya'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ── Widget: Error ──────────────────────────────────────────────────────────

  Widget _buildScanError(GuruProvider provider) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_2,
                size: 44, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gagal Membaca QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.scanError ?? 'QR Code tidak valid.',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _resetScan,
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Ulang'),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Sheet: Pilih Mata Pelajaran ────────────────────────────────────────

class _MapelPickerSheet extends StatelessWidget {
  final List<String> mapels;
  final String? current;
  final bool isInitial;

  const _MapelPickerSheet({
    required this.mapels,
    required this.current,
    this.isInitial = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isInitial ? 'Pilih Mata Pelajaran' : 'Ganti Mata Pelajaran',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih mata pelajaran untuk sesi scan ini',
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...mapels.map((m) {
            final isSelected = m == current;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.book_outlined,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              title: Text(
                m,
                style: TextStyle(
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 20)
                  : null,
              onTap: () => Navigator.pop(context, m),
            );
          }),
        ],
      ),
    );
  }
}

// ── Bottom Sheet: Pilih Status Absensi ────────────────────────────────────────

class _StatusPickerSheet extends StatefulWidget {
  const _StatusPickerSheet();

  @override
  State<_StatusPickerSheet> createState() => _StatusPickerSheetState();
}

class _StatusPickerSheetState extends State<_StatusPickerSheet> {
  String _selectedStatus = 'izin';
  final _keteranganCtrl = TextEditingController();

  static const _options = [
    {'status': 'izin',  'label': 'Izin',  'icon': Icons.event_note_outlined,  'color': AppColors.izin},
    {'status': 'sakit', 'label': 'Sakit', 'icon': Icons.local_hospital_outlined,'color': AppColors.sakit},
    {'status': 'alfa',  'label': 'Alfa',  'icon': Icons.cancel_outlined,       'color': AppColors.alpha},
  ];

  @override
  void dispose() {
    _keteranganCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Status Kehadiran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Pilihan status
          Row(
            children: _options.map((opt) {
              final status = opt['status'] as String;
              final label  = opt['label'] as String;
              final icon   = opt['icon'] as IconData;
              final color  = opt['color'] as Color;
              final isSelected = _selectedStatus == status;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.12)
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: color, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(icon,
                              color: isSelected
                                  ? color
                                  : AppColors.textSecondary,
                              size: 22),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? color
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Keterangan
          TextField(
            controller: _keteranganCtrl,
            decoration: const InputDecoration(
              labelText: 'Keterangan (opsional)',
              hintText: 'Contoh: Surat dokter, keperluan keluarga...',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'status': _selectedStatus,
                'keterangan': _keteranganCtrl.text.trim().isEmpty
                    ? null
                    : _keteranganCtrl.text.trim(),
              }),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlay Painter ────────────────────────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    const cutSize = 260.0;
    final cutLeft = (size.width - cutSize) / 2;
    final cutTop  = (size.height - cutSize) / 2;
    final cutRect = Rect.fromLTWH(cutLeft, cutTop, cutSize, cutSize);

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    final bp = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const cl = 24.0;
    final r = cutRect;
    canvas.drawLine(Offset(r.left, r.top + cl), Offset(r.left, r.top), bp);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + cl, r.top), bp);
    canvas.drawLine(Offset(r.right - cl, r.top), Offset(r.right, r.top), bp);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + cl), bp);
    canvas.drawLine(Offset(r.left, r.bottom - cl), Offset(r.left, r.bottom), bp);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left + cl, r.bottom), bp);
    canvas.drawLine(Offset(r.right - cl, r.bottom), Offset(r.right, r.bottom), bp);
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right, r.bottom - cl), bp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
