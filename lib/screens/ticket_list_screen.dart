import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ticket_provider.dart';
import 'ticket_detail_screen.dart';

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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return const Color(0xFFEF4444);
      case 'IN_PROGRESS':
        return const Color(0xFFF97316);
      case 'RESOLVED':
        return const Color(0xFF10B981);
      case 'CLOSED':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF9CA3AF);
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
        return Icons.assignment;
      case 'IN_PROGRESS':
        return Icons.build;
      case 'RESOLVED':
        return Icons.check_circle;
      case 'CLOSED':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF2563EB),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lokasi, judul, atau deskripsi...',
                prefixIcon: const Icon(Icons.search_outlined, color: Color(0xFF9CA3AF), size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
              ),
              style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Filter Tabs with Better Design
          Container(
            color: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Consumer<TicketProvider>(
                builder: (context, ticketProvider, _) {
                  final statuses = [
                    {'key': 'OPEN', 'label': 'Menunggu'},
                    {'key': 'IN_PROGRESS', 'label': 'Diproses'},
                    {'key': 'RESOLVED', 'label': 'Selesai'},
                    {'key': 'CLOSED', 'label': 'Arsip'}
                  ];
                  return Row(
                    children: statuses.map((statusMap) {
                      final status = statusMap['key'] as String;
                      final label = statusMap['label'] as String;
                      final isSelected = _selectedFilter == status;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: FilterChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedFilter = status);
                            ticketProvider.setSelectedStatus(status);
                            ticketProvider.fetchTickets(status: status);
                          },
                          backgroundColor: Colors.white.withOpacity(0.12),
                          selectedColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          // Ticket List
          Expanded(
            child: Consumer<TicketProvider>(
              builder: (context, ticketProvider, _) {
                final allTickets = ticketProvider.tickets;
                final searchQuery = _searchController.text.toLowerCase();
                final filteredTickets = allTickets
                    .where((ticket) =>
                        ticket.title.toLowerCase().contains(searchQuery) ||
                        ticket.location.toLowerCase().contains(searchQuery) ||
                        ticket.description.toLowerCase().contains(searchQuery))
                    .toList();

                if (ticketProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1565C0),
                      ),
                      strokeWidth: 3,
                    ),
                  );
                }

                if (filteredTickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: const Color(0xFF2563EB).withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Tidak ada tugas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada tugas pada kategori ini',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ticketProvider.fetchTickets(
                      status: _selectedFilter,
                    );
                  },
                  color: const Color(0xFF2563EB),
                  strokeWidth: 2.5,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

                      return _TicketCard(
                        key: ValueKey(ticket.id),
                        ticket: ticket,
                        statusColor: _getStatusColor(ticket.status),
                        statusLabel: _getStatusLabel(ticket.status),
                        statusIcon: _getStatusIcon(ticket.status),
                        dateString: dateFormat.format(ticket.createdAt),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TicketDetailScreen(ticketId: ticket.id),
                            ),
                          );
                        },
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

class _TicketCard extends StatelessWidget {
  final dynamic ticket;
  final Color statusColor;
  final String statusLabel;
  final IconData statusIcon;
  final String dateString;
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      shadowColor: Colors.black.withOpacity(0.04),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Icon Circle
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withOpacity(0.12),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: statusColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ticket.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
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
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Divider
              Divider(
                height: 1,
                color: Colors.grey.withOpacity(0.15),
              ),

              const SizedBox(height: 12),

              // Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pelapor',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ticket.reporterName ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tanggal',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dateString,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Lihat Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    elevation: 0,
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
