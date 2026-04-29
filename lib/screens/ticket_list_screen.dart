import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ticket_provider.dart';
import 'ticket_detail_screen.dart';

// ── BMI Brand Colors ──────────────────────────────────────────────
class _BMI {
  static const blue      = Color(0xFF1B3A7A);
  static const blueMid   = Color(0xFF2550A7);
  static const blueLight = Color(0xFFEBF1FF);
  static const gold      = Color(0xFFC9920A);
  static const goldMid   = Color(0xFFE4A80E);
  static const goldLight = Color(0xFFFDF6E3);
  static const goldPale  = Color(0xFFFFF8E7);
  static const textDark  = Color(0xFF1A1A2E);
  static const textMid   = Color(0xFF4A5568);
  static const textLight = Color(0xFF718096);
  static const bg        = Color(0xFFF4F6FB);
  static const border    = Color(0xFFE2E8F0);
}

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({Key? key}) : super(key: key);

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late TextEditingController _searchController;
  String _selectedFilter = 'OPEN';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().fetchTickets(status: 'OPEN');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Status Helpers ────────────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':        return const Color(0xFFE53935);
      case 'IN_PROGRESS': return _BMI.gold;
      case 'RESOLVED':    return const Color(0xFF43A047);
      case 'CLOSED':      return const Color(0xFF616161);
      default:            return const Color(0xFF757575);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'OPEN':        return 'Menunggu';
      case 'IN_PROGRESS': return 'Diproses';
      case 'RESOLVED':    return 'Selesai';
      case 'CLOSED':      return 'Selesai (Arsip)';
      default:            return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OPEN':        return Icons.assignment_outlined;
      case 'IN_PROGRESS': return Icons.build_outlined;
      case 'RESOLVED':    return Icons.check_circle_outline;
      case 'CLOSED':      return Icons.archive_outlined;
      default:            return Icons.help_outline;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BMI.bg,

      // ── AppBar ──────────────────────────────────────────────────
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
          'Lihat Tugas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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

      body: Column(
        children: [
          // ── Search + Filter header ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_BMI.blue, _BMI.blueMid],
              ),
            ),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _BMI.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari lokasi, judul, atau deskripsi...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: _BMI.textLight.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: _BMI.blue.withOpacity(0.5),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                // Filter chips
                Consumer<TicketProvider>(
                  builder: (context, ticketProvider, _) {
                    final statuses = [
                      {'key': 'OPEN',        'label': 'Menunggu'},
                      {'key': 'IN_PROGRESS', 'label': 'Diproses'},
                      {'key': 'RESOLVED',    'label': 'Selesai'},
                      {'key': 'CLOSED',      'label': 'Arsip'},
                    ];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                      child: Row(
                        children: statuses.map((s) {
                          final key      = s['key']!;
                          final label    = s['label']!;
                          final isActive = _selectedFilter == key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedFilter = key);
                                ticketProvider.setSelectedStatus(key);
                                ticketProvider.fetchTickets(status: key);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? _BMI.gold
                                      : Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isActive
                                        ? _BMI.gold
                                        : Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.8),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Ticket List ─────────────────────────────────────────
          Expanded(
            child: Consumer<TicketProvider>(
              builder: (context, ticketProvider, _) {
                final allTickets   = ticketProvider.tickets;
                final searchQuery  = _searchController.text.toLowerCase();
                final filtered     = allTickets.where((t) =>
                t.title.toLowerCase().contains(searchQuery) ||
                    t.location.toLowerCase().contains(searchQuery) ||
                    t.description.toLowerCase().contains(searchQuery),
                ).toList();

                // Loading
                if (ticketProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(_BMI.blue),
                      strokeWidth: 3,
                    ),
                  );
                }

                // Empty state
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _BMI.blueLight,
                          ),
                          child: Icon(
                            Icons.inbox_outlined,
                            size: 52,
                            color: _BMI.blue.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Tidak ada tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _BMI.textMid,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Belum ada tugas pada kategori ini',
                          style: TextStyle(
                            fontSize: 13,
                            color: _BMI.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // List
                return RefreshIndicator(
                  onRefresh: () async {
                    await ticketProvider.fetchTickets(
                        status: _selectedFilter);
                  },
                  color: _BMI.blue,
                  strokeWidth: 2.5,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ticket     = filtered[index];
                      final dateFormat =
                      DateFormat('dd MMM yyyy', 'id_ID');
                      return _TicketCard(
                        ticket:      ticket,
                        statusColor: _getStatusColor(ticket.status),
                        statusLabel: _getStatusLabel(ticket.status),
                        statusIcon:  _getStatusIcon(ticket.status),
                        dateString:  dateFormat.format(ticket.createdAt),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketDetailScreen(ticketId: ticket.id),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket Card
// ─────────────────────────────────────────────────────────────────────────────
class _TicketCard extends StatelessWidget {
  final dynamic      ticket;
  final Color        statusColor;
  final String       statusLabel;
  final IconData     statusIcon;
  final String       dateString;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
    required this.dateString,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _BMI.border),
        // Subtle left accent stripe via boxShadow trick — no shadow, just border
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // ── Gold top accent line ──────────────────────────────
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _BMI.blue.withOpacity(0.6),
                    _BMI.gold,
                    _BMI.goldMid,
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ──────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status icon box
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(statusIcon,
                            color: statusColor, size: 19),
                      ),
                      const SizedBox(width: 11),

                      // Title + location
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _BMI.textDark,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: _BMI.gold,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    ticket.location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _BMI.textLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
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
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Divider ─────────────────────────────────────
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _BMI.gold.withOpacity(0.3),
                          _BMI.border,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 11),

                  // ── Meta row ────────────────────────────────────
                  Row(
                    children: [
                      // Pelapor
                      Expanded(
                        child: _MetaChip(
                          icon: Icons.person_outline,
                          label: 'Pelapor',
                          value: ticket.reporterName ?? '-',
                          iconColor: _BMI.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tanggal
                      Expanded(
                        child: _MetaChip(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tanggal',
                          value: dateString,
                          iconColor: _BMI.gold,
                          alignRight: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Detail Button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16),
                      label: const Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _BMI.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Meta chip (pelapor / tanggal) ─────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    iconColor;
  final bool     alignRight;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: alignRight
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!alignRight) ...[
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: _BMI.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (alignRight) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 12, color: iconColor),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: _BMI.textDark,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.end : TextAlign.start,
        ),
      ],
    );
  }
}