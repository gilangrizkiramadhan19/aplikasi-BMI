import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule_model.dart';
import 'submit_pm_report_screen.dart';

class PreventiveMaintenanceScreen extends StatefulWidget {
  const PreventiveMaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<PreventiveMaintenanceScreen> createState() =>
      _PreventiveMaintenanceScreenState();
}

class _PreventiveMaintenanceScreenState
    extends State<PreventiveMaintenanceScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadSchedules();
  }

  void _loadSchedules() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().fetchSchedulesByMonth(
            _selectedDate.year,
            _selectedDate.month,
          );
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      _loadSchedules();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      _loadSchedules();
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _loadSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perawatan Rutin'),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Month Selector
              Container(
                color: const Color(0xFF1565C0).withOpacity(0.05),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _previousMonth,
                          color: const Color(0xFF1565C0),
                        ),
                        Column(
                          children: [
                            Text(
                              DateFormat('MMMM yyyy', 'id_ID')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${provider.schedules.length} jadwal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextMonth,
                          color: const Color(0xFF1565C0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _goToToday,
                        icon: const Icon(Icons.today),
                        label: const Text('Hari Ini'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF1565C0),
                            width: 1.5,
                          ),
                          foregroundColor: const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1565C0),
                          ),
                        ),
                      )
                    : provider.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Color(0xFFE53935),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${provider.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFFE53935)),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadSchedules,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Coba Lagi'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : provider.schedules.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.schedule_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada jadwal untuk bulan ini',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: provider.schedules.length,
                                itemBuilder: (context, index) {
                                  final schedule = provider.schedules[index];
                                  final statusInfo =
                                      provider.getStatusInfo(schedule.status);

                                  return ScheduleCard(
                                    schedule: schedule,
                                    statusInfo: statusInfo,
                                    onTapAction: () =>
                                        _handleScheduleAction(schedule),
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleScheduleAction(Schedule schedule) {
    final statusInfo =
        context.read<ScheduleProvider>().getStatusInfo(schedule.status);

    if (schedule.status.toUpperCase() == 'OPEN') {
      // Status OPEN -> Tawarkan "Terima Tugas"
      _showTakeTaskDialog(schedule);
    } else if (schedule.status.toUpperCase() == 'IN_PROGRESS') {
      // Status IN_PROGRESS -> Cek apakah user adalah teknisi yang ditugaskan
      _showProgressDialog(schedule);
    } else if (schedule.status.toUpperCase() == 'RESOLVED') {
      // Status RESOLVED -> Lihat detail
      _showResolvedDialog(schedule);
    }
  }

  void _showTakeTaskDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terima Tugas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perawatan: ${schedule.maintenanceItem}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi: ${schedule.location}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Terima tugas ini untuk mulai mengerjakan?',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _takeTask(schedule.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
            ),
            child: const Text('Terima'),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(Schedule schedule) {
    final isAssignedToMe = false; // TODO: Check current user
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jadwal Sedang Dikerjakan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perawatan: ${schedule.maintenanceItem}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Teknisi: ${schedule.technicianUsername ?? 'Belum ditugaskan'}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi: ${schedule.location}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            if (!isAssignedToMe)
              Text(
                'Jadwal ini sedang dikerjakan oleh teknisi lain',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                'Klik tombol di bawah untuk menyelesaikan tugas',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (isAssignedToMe)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _goToSubmitReport(schedule);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
              ),
              child: const Text('Selesaikan'),
            ),
        ],
      ),
    );
  }

  void _showResolvedDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Penyelesaian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perawatan: ${schedule.maintenanceItem}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Teknisi: ${schedule.technicianUsername ?? '-'}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi: ${schedule.location}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            if (schedule.keterangan != null && schedule.keterangan!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Keterangan:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.keterangan!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            if (schedule.materialUsed != null && schedule.materialUsed!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Material Digunakan:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.materialUsed!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _takeTask(int scheduleId) async {
    try {
      await context.read<ScheduleProvider>().takeTask(scheduleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil diterima'),
          backgroundColor: Color(0xFF43A047),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    }
  }

  void _goToSubmitReport(Schedule schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitPmReportScreen(schedule: schedule),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final Map<String, dynamic> statusInfo;
  final VoidCallback onTapAction;

  const ScheduleCard({
    Key? key,
    required this.schedule,
    required this.statusInfo,
    required this.onTapAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header dengan status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusInfo['bgColor'],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.maintenanceItem,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.machineName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo['color'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusInfo['label'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          schedule.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy', 'id_ID')
                            .format(schedule.scheduledDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  if (schedule.technicianUsername != null &&
                      schedule.technicianUsername!.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              schedule.technicianUsername!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Action button
            if (statusInfo['canTake'] || schedule.status.toUpperCase() == 'IN_PROGRESS')
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTapAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusInfo['canTake']
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF43A047),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      statusInfo['canTake'] ? 'Terima Tugas' : 'Lihat Detail',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
