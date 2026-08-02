import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siswa_provider.dart';
import 'siswa_dashboard_screen.dart';
import 'siswa_jadwal_screen.dart';
import 'siswa_nilai_screen.dart';
import 'siswa_riwayat_absensi_screen.dart';
import 'siswa_qr_code_screen.dart';
import 'siswa_profil_screen.dart';

/// Scaffold utama Siswa dengan Bottom Navigation
class SiswaMainScreen extends StatefulWidget {
  const SiswaMainScreen({super.key});

  @override
  State<SiswaMainScreen> createState() => _SiswaMainScreenState();
}

class _SiswaMainScreenState extends State<SiswaMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SiswaDashboardScreen(),
    SiswaJadwalScreen(),
    SiswaNilaiScreen(),
    SiswaRiwayatAbsensiScreen(),
    SiswaQrCodeScreen(),
    SiswaProfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final siswaId = context.read<AuthProvider>().siswa?.id ?? '';
    if (siswaId.isNotEmpty) {
      // forceRefresh: true — selalu fetch ulang saat login/masuk halaman utama
      // Ini memastikan data segar meskipun provider masih ada di memori
      context.read<SiswaProvider>().loadAll(siswaId, forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade_outlined),
            activeIcon: Icon(Icons.grade),
            label: 'Nilai',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_outlined),
            activeIcon: Icon(Icons.qr_code),
            label: 'QR Code',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
