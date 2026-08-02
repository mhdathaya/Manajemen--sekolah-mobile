import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../core/app_responsive.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_utils.dart';
import '../../widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _guruFormKey = GlobalKey<FormState>();
  final _guruIdentifierCtrl = TextEditingController();
  final _guruPasswordCtrl = TextEditingController();
  bool _guruPasswordVisible = false;

  final _siswaFormKey = GlobalKey<FormState>();
  final _siswaIdentifierCtrl = TextEditingController();
  final _siswaPasswordCtrl = TextEditingController();
  bool _siswaPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _guruIdentifierCtrl.dispose();
    _guruPasswordCtrl.dispose();
    _siswaIdentifierCtrl.dispose();
    _siswaPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginGuru() async {
    if (!_guruFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final success = await auth.loginGuru(
      identifier: _guruIdentifierCtrl.text.trim(),
      password: _guruPasswordCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.guruMain);
    } else {
      AppUtils.showErrorSnackbar(context, auth.errorMessage ?? 'Login gagal.');
    }
  }

  Future<void> _loginSiswa() async {
    if (!_siswaFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final success = await auth.loginSiswa(
      identifier: _siswaIdentifierCtrl.text.trim(),
      password: _siswaPasswordCtrl.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.siswaMain);
    } else {
      AppUtils.showErrorSnackbar(context, auth.errorMessage ?? 'Login gagal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = AppResponsive.isWide(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) => LoadingOverlay(
          isLoading: auth.isLoading,
          message: 'Sedang masuk...',
          child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
        ),
      ),
    );
  }

  // ── Layout phone (narrow) ────────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(height: size.height * 0.30),
          _buildFormCard(maxWidth: double.infinity),
          _buildDemoHint(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Layout tablet/desktop (wide) ─────────────────────────────────────────
  Widget _buildWideLayout() {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        // Panel kiri — branding
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.school_rounded,
                        size: 52, color: Colors.white),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppConstants.appTagline,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 40),
                  _buildDemoHintInline(),
                ],
              ),
            ),
          ),
        ),
        // Panel kanan — form
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Masuk ke Akun',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih peran dan masukkan kredensial Anda',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                _buildFormCard(maxWidth: 420),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(Icons.school_rounded,
                  size: 38, color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selamat datang kembali',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required double maxWidth}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: const [Tab(text: 'Guru'), Tab(text: 'Siswa')],
                ),
              ),
              SizedBox(
                height: 320,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildGuruForm(), _buildSiswaForm()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuruForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _guruFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _guruIdentifierCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email atau NIP',
                hintText: 'Masukkan email atau NIP',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Email atau NIP tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _guruPasswordCtrl,
              obscureText: !_guruPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_guruPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () => setState(
                      () => _guruPasswordVisible = !_guruPasswordVisible),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                if (v.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {},
                  child: const Text('Lupa Password?')),
            ),
            const SizedBox(height: 4),
            Consumer<AuthProvider>(
              builder: (_, auth, __) => ElevatedButton(
                onPressed: auth.isLoading ? null : _loginGuru,
                child: const Text('Masuk sebagai Guru'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _siswaFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              controller: _siswaIdentifierCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email atau NIS',
                hintText: 'Contoh: 2025001 atau email@sekolah.sch.id',
                prefixIcon: Icon(Icons.badge_outlined),
                helperText: 'Masukkan NIS atau alamat email',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Email atau NIS tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _siswaPasswordCtrl,
              obscureText: !_siswaPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_siswaPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () => setState(
                      () => _siswaPasswordVisible = !_siswaPasswordVisible),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                if (v.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {},
                  child: const Text('Lupa Password?')),
            ),
            const SizedBox(height: 4),
            Consumer<AuthProvider>(
              builder: (_, auth, __) => ElevatedButton(
                onPressed: auth.isLoading ? null : _loginSiswa,
                child: const Text('Masuk sebagai Siswa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoHint() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: _demoContent(),
    );
  }

  // Demo hint versi inline untuk panel kiri di layout wide
  Widget _buildDemoHintInline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.white70),
              SizedBox(width: 6),
              Text(
                'Demo Credentials',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _demoRowLight('Guru', 'budi@sekolah.sch.id', 'password123'),
          const SizedBox(height: 4),
          _demoRowLight('Siswa (NIS)', '2025001', 'password123'),
          const SizedBox(height: 4),
          _demoRowLight('Siswa (Email)', '2025001@sekolah.sch.id', 'password123'),
        ],
      ),
    );
  }

  Widget _demoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.info),
            const SizedBox(width: 6),
            Text(
              'Demo Credentials',
              style: TextStyle(
                  color: AppColors.info,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _demoRow('Guru', 'budi@sekolah.sch.id', 'password123'),
        const SizedBox(height: 4),
        _demoRow('Siswa (NIS)', '2025001', 'password123'),
        const SizedBox(height: 4),
        _demoRow('Siswa (Email)', '2025001@sekolah.sch.id', 'password123'),
      ],
    );
  }

  Widget _demoRow(String role, String user, String pass) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: AppColors.info, fontSize: 12),
        children: [
          TextSpan(
              text: '$role: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: '$user  •  Pass: $pass'),
        ],
      ),
    );
  }

  Widget _demoRowLight(String role, String user, String pass) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white70, fontSize: 12),
        children: [
          TextSpan(
              text: '$role: ',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          TextSpan(text: '$user  •  Pass: $pass'),
        ],
      ),
    );
  }
}
