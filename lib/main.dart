import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/jadwal_repository.dart';
import 'repositories/absensi_repository.dart';
import 'repositories/nilai_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/guru_provider.dart';
import 'providers/siswa_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/guru/guru_main_screen.dart';
import 'screens/siswa/siswa_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia untuk intl
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi SharedPreferences
  final storageService = await StorageService.getInstance();

  // Paksa orientasi portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparansi status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(EduBlueApp(storageService: storageService));
}

/// Root widget aplikasi EduBlue
class EduBlueApp extends StatelessWidget {
  final StorageService storageService;

  const EduBlueApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    // Setup dependency injection manual
    final apiService = ApiService(storageService);
    final authService = AuthService(apiService, storageService);

    final authRepository = AuthRepository(authService);
    final jadwalRepository = JadwalRepository(apiService);
    final absensiRepository = AbsensiRepository(apiService);
    final nilaiRepository = NilaiRepository(apiService);

    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        // Guru Provider
        ChangeNotifierProvider(
          create: (_) => GuruProvider(jadwalRepository, absensiRepository),
        ),
        // Siswa Provider
        ChangeNotifierProvider(
          create: (_) => SiswaProvider(
            jadwalRepository,
            nilaiRepository,
            absensiRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'EduBlue',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.guruMain: (_) => const GuruMainScreen(),
          AppRoutes.siswaMain: (_) => const SiswaMainScreen(),
        },
        // Animasi transisi halaman — hanya untuk route yang tidak terdaftar
        // di routes: {} di atas. Mengembalikan LoginScreen sebagai fallback
        // agar tidak ada layar hitam kosong jika route tidak dikenal.
        onGenerateRoute: (settings) {
          // Lookup dulu di routes statis
          final staticRoutes = <String, Widget Function()>{
            AppRoutes.splash: () => const SplashScreen(),
            AppRoutes.login: () => const LoginScreen(),
            AppRoutes.guruMain: () => const GuruMainScreen(),
            AppRoutes.siswaMain: () => const SiswaMainScreen(),
          };

          final builder = staticRoutes[settings.name];
          final page = builder != null ? builder() : const LoginScreen();

          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => page,
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 250),
          );
        },
      ),
    );
  }
}
