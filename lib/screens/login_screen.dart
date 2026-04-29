import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _obscurePassword = true;

  // Brand Colors from BMI Logo
  static const Color kNavy = Color(0xFF2B3A8F);
  static const Color kGold = Color(0xFFC9A84C);
  static const Color kBg = Color(0xFFF7F8FC);
  static const Color kSurface = Color(0xFFFFFFFF);
  static const Color kBorder = Color(0xFFE4E7F0);
  static const Color kTextMuted = Color(0xFF8E96AE);
  static const Color kTextDark = Color(0xFF1A2140);

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Username dan password tidak boleh kosong',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    context.read<AuthProvider>().login(username, password).then((success) {
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Login berhasil!',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: const Color(0xFF388E3C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        final error = context.read<AuthProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login gagal: $error',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Navy header block
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.42,
              decoration: const BoxDecoration(
                color: kNavy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Stack(
                children: [
                  // Diagonal gold accent bottom-right
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(36),
                      ),
                      child: CustomPaint(
                        size: const Size(180, 130),
                        painter: _DiagonalAccentPainter(),
                      ),
                    ),
                  ),
                  // Subtle circle decoration
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kGold.withOpacity(0.08),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── HEADER ──
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.36,
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8),

                                // Logo text (swap with Image.asset if logo file exists)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // BMI stylized letters
                                    RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'B',
                                            style: TextStyle(color: kGold),
                                          ),
                                          TextSpan(
                                            text: 'M',
                                            style:
                                            TextStyle(color: Colors.white),
                                          ),
                                          TextSpan(
                                            text: 'I',
                                            style: TextStyle(color: kGold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      width: 1,
                                      height: 28,
                                      color: Colors.white24,
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'BUMI MENARA',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white70,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'INTERNUSA',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: kGold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                const Text(
                                  'Sistem Maintenance\nMesin',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.25,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 2.5,
                                      decoration: BoxDecoration(
                                        color: kGold,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Portal Login Teknisi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white54,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── FORM CARD ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: kNavy.withOpacity(0.12),
                                  blurRadius: 40,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card header
                                Row(
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: kGold,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Masuk ke Akun',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: kTextDark,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Username
                                _buildLabel('Username'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _usernameController,
                                  hintText: 'Masukkan username Anda',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),

                                const SizedBox(height: 18),

                                // Password
                                _buildLabel('Password'),
                                const SizedBox(height: 8),
                                _buildPasswordField(),

                                const SizedBox(height: 28),

                                // Login button
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, _) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: authProvider.isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kNavy,
                                          disabledBackgroundColor:
                                          kNavy.withOpacity(0.5),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: authProvider.isLoading
                                            ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child:
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                            AlwaysStoppedAnimation<
                                                Color>(Colors.white),
                                          ),
                                        )
                                            : Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Masuk',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: kGold,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Demo credential
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kNavy.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: kNavy.withOpacity(0.08),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 13,
                                        color: kNavy.withOpacity(0.35),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Demo: ',
                                        style: TextStyle(
                                            fontSize: 11, color: kTextMuted),
                                      ),
                                      const Text(
                                        'teknisi',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: kNavy,
                                        ),
                                      ),
                                      Text(
                                        ' / ',
                                        style: TextStyle(
                                            fontSize: 11, color: kTextMuted),
                                      ),
                                      const Text(
                                        '123456',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: kNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Footer
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              '© 2025 PT Bumi Menara Internusa',
                              style: TextStyle(
                                fontSize: 10,
                                color: kTextMuted.withOpacity(0.5),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: kTextDark,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: kTextDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
        const TextStyle(color: kTextMuted, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: kTextMuted, size: 18),
        filled: true,
        fillColor: kBg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kNavy, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(
        color: kTextDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Masukkan password Anda',
        hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: kTextMuted,
          size: 18,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: kTextMuted,
            size: 18,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: kBg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kNavy, width: 1.5),
        ),
      ),
    );
  }
}

class _DiagonalAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9A84C).withOpacity(0.22);
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DiagonalAccentPainter old) => false;
}