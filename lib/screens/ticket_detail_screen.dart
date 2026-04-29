import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ticket_provider.dart';
import 'complete_ticket_screen.dart';

// ── BMI Brand Colors ──────────────────────────────────────────────
class _BMI {
  static const blue = Color(0xFF1B3A7A);
  static const blueMid = Color(0xFF2550A7);
  static const blueLight = Color(0xFFEBF1FF);
  static const gold = Color(0xFFC9920A);
  static const goldMid = Color(0xFFE4A80E);
  static const goldLight = Color(0xFFFDF6E3);
  static const goldPale = Color(0xFFFFF8E7);
  static const textDark = Color(0xFF1A1A2E);
  static const textMid = Color(0xFF4A5568);
  static const textLight = Color(0xFF718096);
  static const bg = Color(0xFFF4F6FB);
  static const border = Color(0xFFE2E8F0);
}

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const TicketDetailScreen({
    Key? key,
    required this.ticketId,
  }) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().fetchTicketDetail(widget.ticketId);
    });
  }

  // ── Confirmation Dialog ───────────────────────────────────────────
  void _showConfirmationDialog(
      BuildContext context,
      String title,
      String message,
      VoidCallback onConfirm,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _BMI.goldLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.help_outline, color: _BMI.gold, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _BMI.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: _BMI.textMid,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: _BMI.textLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _BMI.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text(
              'Konfirmasi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Helpers ────────────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return const Color(0xFFE53935);
      case 'IN_PROGRESS':
        return _BMI.gold;
      case 'RESOLVED':
        return const Color(0xFF43A047);
      case 'CLOSED':
        return const Color(0xFF616161);
      default:
        return const Color(0xFF757575);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'OPEN':
        return 'Menunggu';
      case 'IN_PROGRESS':
        return 'Diproses';
      case 'RESOLVED':
        return 'Selesai';
      case 'CLOSED':
        return 'Selesai (Arsip)';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OPEN':
        return Icons.assignment_outlined;
      case 'IN_PROGRESS':
        return Icons.build_outlined;
      case 'RESOLVED':
        return Icons.check_circle_outline;
      case 'CLOSED':
        return Icons.archive_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // ── Photo Section ─────────────────────────────────────────────────
  Widget _buildPhotoSection(String? photoProof) {
    if (photoProof == null || photoProof.isEmpty) {
      return Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_BMI.blueLight, Color(0xFFF8FAFF)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _BMI.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 40, color: _BMI.blue.withOpacity(0.3)),
            const SizedBox(height: 8),
            Text(
              'Belum ada foto bukti perbaikan',
              style: TextStyle(
                fontSize: 13,
                color: _BMI.blue.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    String imageUrl = photoProof;
    if (!photoProof.startsWith('http')) {
      imageUrl = 'https://upstate-unbaked-peso.ngrok-free.dev$photoProof';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        headers: const {'ngrok-skip-browser-warning': 'true'},
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 220,
            color: _BMI.blueLight,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: _BMI.blue,
                strokeWidth: 3,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: _BMI.blueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined,
                    size: 40, color: _BMI.blue.withOpacity(0.3)),
                const SizedBox(height: 8),
                const Text(
                  'Gagal memuat foto',
                  style: TextStyle(fontSize: 13, color: _BMI.textLight),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    imageUrl,
                    style: TextStyle(
                        fontSize: 10, color: _BMI.textLight.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BMI.bg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_BMI.blue, _BMI.blueMid],
            ),
          ),
        ),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _BMI.goldMid,
                  _BMI.gold,
                  _BMI.goldMid,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, _) {
          // ── Loading ─────────────────────────────────────────────
          if (ticketProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_BMI.blue),
                strokeWidth: 3,
              ),
            );
          }

          // ── Not Found ───────────────────────────────────────────
          if (ticketProvider.selectedTicket == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tugas Tidak Ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _BMI.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tugas yang Anda cari tidak dapat dimuat',
                    style: TextStyle(fontSize: 13, color: _BMI.textLight),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Kembali'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _BMI.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Main Content ────────────────────────────────────────
          final ticket = ticketProvider.selectedTicket!;
          final dateFormat = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
          final statusColor = _getStatusColor(ticket.status);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status Header ─────────────────────────────────
                _StatusHeader(
                  status: ticket.status,
                  title: ticket.title,
                  statusColor: statusColor,
                  statusLabel: _getStatusLabel(ticket.status),
                  statusIcon: _getStatusIcon(ticket.status),
                ),

                // ── Detail Content ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Informasi Tugas
                      const _SectionLabel(label: 'Informasi Tugas'),
                      const SizedBox(height: 8),
                      _BMIDetailCard(
                        icon: Icons.location_on_outlined,
                        title: 'Lokasi',
                        content: ticket.location,
                        iconColor: _BMI.blue,
                      ),
                      const SizedBox(height: 8),
                      _BMIDetailCard(
                        icon: Icons.description_outlined,
                        title: 'Deskripsi',
                        content: ticket.description,
                        iconColor: _BMI.blue,
                      ),
                      const SizedBox(height: 8),
                      _BMIDetailCard(
                        icon: Icons.person_outline,
                        title: 'Pelapor',
                        content: ticket.reporterName ?? '-',
                        iconColor: _BMI.gold,
                      ),
                      const SizedBox(height: 8),
                      _BMIDetailCard(
                        icon: Icons.engineering_outlined,
                        title: 'Teknisi',
                        content: ticket.technicianName ?? '-',
                        iconColor: _BMI.gold,
                      ),

                      if (ticket.materialUsed != null &&
                          ticket.materialUsed!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _BMIDetailCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Material Digunakan',
                          content: ticket.materialUsed!,
                          iconColor: _BMI.blue,
                        ),
                      ],

                      // Section: Waktu
                      const SizedBox(height: 16),
                      const _SectionLabel(label: 'Waktu'),
                      const SizedBox(height: 8),
                      _BMIDetailCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Dibuat',
                        content: dateFormat.format(ticket.createdAt),
                        iconColor: _BMI.blue,
                      ),
                      const SizedBox(height: 8),
                      _BMIDetailCard(
                        icon: Icons.update_outlined,
                        title: 'Diperbarui',
                        content: dateFormat.format(ticket.updatedAt),
                        iconColor: _BMI.gold,
                      ),

                      // Section: Foto Bukti
                      const SizedBox(height: 16),
                      const _SectionLabel(label: 'Foto Bukti Perbaikan'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _BMI.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            _buildPhotoSection(ticket.photoProof),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              color: _BMI.blueLight,
                              child: Text(
                                ticket.photoProof != null &&
                                    ticket.photoProof!.isNotEmpty
                                    ? 'Foto bukti tersedia'
                                    : 'Upload foto setelah perbaikan selesai',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _BMI.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Action Buttons ──────────────────────────
                      const SizedBox(height: 24),
                      if (ticket.status == 'OPEN') ...[
                        _InfoBanner(
                          icon: Icons.info_outline,
                          message: 'Ambil tugas ini untuk mulai mengerjakannya',
                          color: _BMI.gold,
                          bgColor: _BMI.goldLight,
                          borderColor: _BMI.gold.withOpacity(0.25),
                        ),
                        const SizedBox(height: 12),
                        _BMIButton(
                          label: 'Ambil Tugas',
                          icon: Icons.assignment_turned_in_outlined,
                          color: _BMI.gold,
                          shadowColor: _BMI.gold.withOpacity(0.3),
                          isLoading: ticketProvider.isLoading,
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              'Ambil Tugas',
                              'Apakah Anda yakin ingin mengambil tugas ini?',
                                  () async {
                                Navigator.pop(context);
                                final success =
                                await ticketProvider.updateTicketStatus(
                                  ticket.id,
                                  'IN_PROGRESS',
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Tugas berhasil diambil'
                                          : 'Error: ${ticketProvider.error}',
                                    ),
                                    backgroundColor: success
                                        ? const Color(0xFF43A047)
                                        : const Color(0xFFE53935),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ] else if (ticket.status == 'IN_PROGRESS') ...[
                        _InfoBanner(
                          icon: Icons.info_outline,
                          message:
                          'Upload foto bukti perbaikan untuk menyelesaikan tugas',
                          color: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFECFDF5),
                          borderColor:
                          const Color(0xFF16A34A).withOpacity(0.25),
                        ),
                        const SizedBox(height: 12),
                        _BMIButton(
                          label: 'Selesaikan Tugas',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF16A34A),
                          shadowColor:
                          const Color(0xFF16A34A).withOpacity(0.3),
                          isLoading: ticketProvider.isLoading,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CompleteTicketScreen(ticketId: ticket.id),
                              ),
                            );
                          },
                        ),
                      ] else if (ticket.status == 'RESOLVED') ...[
                        _InfoBanner(
                          icon: Icons.check_circle_outline,
                          message: 'Tugas telah selesai dan menunggu validasi',
                          color: const Color(0xFF616161),
                          bgColor: const Color(0xFFF5F5F5),
                          borderColor:
                          const Color(0xFF616161).withOpacity(0.2),
                        ),
                      ] else if (ticket.status == 'CLOSED') ...[
                        _InfoBanner(
                          icon: Icons.archive_outlined,
                          message:
                          'Tugas ini sudah ditutup dan tersimpan dalam riwayat',
                          color: const Color(0xFF64748B),
                          bgColor: const Color(0xFFF8FAFC),
                          borderColor:
                          const Color(0xFF64748B).withOpacity(0.2),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Status header card di bawah AppBar
class _StatusHeader extends StatelessWidget {
  final String status;
  final String title;
  final Color statusColor;
  final String statusLabel;
  final IconData statusIcon;

  const _StatusHeader({
    required this.status,
    required this.title,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: _BMI.goldPale,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _BMI.gold.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + badge row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_BMI.gold, _BMI.goldMid],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                Icon(statusIcon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _BMI.textDark,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Label section dengan garis gold
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _BMI.gold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _BMI.gold.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Detail card row dengan ikon berwarna
class _BMIDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color iconColor;

  const _BMIDetailCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGold = iconColor == _BMI.gold;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _BMI.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isGold
                  ? _BMI.gold.withOpacity(0.1)
                  : _BMI.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _BMI.textLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _BMI.textDark,
                    height: 1.4,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Info banner (orange/green/gray tip box)
class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _InfoBanner({
    required this.icon,
    required this.message,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button utama (Ambil / Selesaikan)
class _BMIButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final bool isLoading;
  final VoidCallback onPressed;

  const _BMIButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.shadowColor,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon, size: 19),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: shadowColor,
        ),
      ),
    );
  }
}