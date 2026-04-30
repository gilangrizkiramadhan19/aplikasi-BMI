import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/schedule_provider.dart';
import 'ticket_list_screen.dart';
import 'preventive_maintenance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Brand Colors — same as LoginScreen
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().fetchAllTicketsForStats();
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFD32F2F),
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Keluar dari Akun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda yakin ingin logout dari sistem?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: kTextMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: kBorder),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: kTextDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sesuaikan dengan getter yang ada di AuthProvider kamu.
    // Contoh alternatif: context.watch<AuthProvider>().currentUser?.name ?? 'Teknisi'
    const username = 'Teknisi';

    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── SLIVER APP BAR ──
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: kNavy,
                elevation: 0,
                centerTitle: false,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: () {
                      context.read<TicketProvider>().fetchAllTicketsForStats();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Data berhasil diperbarui',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          backgroundColor: const Color(0xFF388E3C),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onPressed: _showLogoutDialog,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Diagonal gold accent
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CustomPaint(
                          size: const Size(180, 140),
                          painter: _DiagonalAccentPainter(),
                        ),
                      ),
                      // Decorative circles
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.04),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: -10,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kGold.withOpacity(0.08),
                          ),
                        ),
                      ),
                      // Content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo bar
                              Row(
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'B',
                                          style: TextStyle(color: kGold),
                                        ),
                                        TextSpan(
                                          text: 'M',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        TextSpan(
                                          text: 'I',
                                          style: TextStyle(color: kGold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 1,
                                    height: 18,
                                    color: Colors.white24,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Maintenance',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white60,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Greeting
                              Text(
                                'Halo, $username 👋',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Dashboard Teknisi',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: kGold,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  const Text(
                                    'Ringkasan tiket hari ini',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── BODY CONTENT ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── STATS ──
                      Consumer<TicketProvider>(
                        builder: (context, ticketProvider, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(label: 'Status Tiket'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatCard(
                                      title: 'Menunggu',
                                      count: ticketProvider.openCount,
                                      accentColor: const Color(0xFFE53935),
                                      bgColor: const Color(0xFFFFF5F5),
                                      icon: Icons.pending_actions_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatCard(
                                      title: 'Diproses',
                                      count: ticketProvider.inProgressCount,
                                      accentColor: const Color(0xFFF57C00),
                                      bgColor: const Color(0xFFFFF8EE),
                                      icon: Icons.build_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatCard(
                                      title: 'Selesai',
                                      count: ticketProvider.resolvedCount,
                                      accentColor: const Color(0xFF2E7D32),
                                      bgColor: const Color(0xFFF1FAF1),
                                      icon: Icons.check_circle_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── MENU ──
                      _SectionLabel(label: 'Menu'),
                      const SizedBox(height: 12),

                      _MenuCard(
                        title: 'Lihat Tugas',
                        description: 'Lihat daftar tiket maintenance',
                        icon: Icons.list_alt_rounded,
                        iconBg: kNavy.withOpacity(0.08),
                        iconColor: kNavy,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TicketListScreen()),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _MenuCard(
                        title: 'Perawatan Rutin',
                        description: 'Jadwal preventive maintenance',
                        icon: Icons.schedule_rounded,
                        iconBg: const Color(0xFF1565C0).withOpacity(0.08),
                        iconColor: const Color(0xFF1565C0),
                        onTap: () {
                          context.read<ScheduleProvider>().fetchSchedulesByMonth(
                            DateTime.now().month,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PreventiveMaintenanceScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Footer
                      Center(
                        child: Text(
                          '© 2025 PT Bumi Menara Internusa',
                          style: TextStyle(
                            fontSize: 10,
                            color: kTextMuted.withOpacity(0.5),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SECTION LABEL ──
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFC9A84C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2140),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ── STAT CARD ──
class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color accentColor;
  final Color bgColor;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.accentColor,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: accentColor, size: 17),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: accentColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E96AE),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── MENU CARD ──
class _MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7F0), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2140),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E96AE),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFBDBDBD),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── DIAGONAL GOLD ACCENT ──
class _DiagonalAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC9A84C).withOpacity(0.20);
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
