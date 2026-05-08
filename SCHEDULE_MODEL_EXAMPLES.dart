// ============================================================================
// SCHEDULE MODEL - COMPLETE IMPLEMENTATION WITH NULL SAFETY
// ============================================================================
// Ini file contoh lengkap yang bisa langsung digunakan atau dikopy
// File ini menunjukkan best practices untuk null safety di Flutter
// ============================================================================

import 'package:intl/intl.dart';

// ============================================================================
// 1. MODEL CLASS - dengan null safety yang benar
// ============================================================================

class Schedule {
  // ========== REQUIRED FIELDS (tidak bisa null) ==========
  final int id;
  final String maintenanceItem;      // Maintenance task (e.g., "CEK KOMPRESOR")
  final String machineName;           // Machine name (e.g., "COLD STORAGE 01")
  final String location;              // Location (e.g., "RUANG PENDINGIN")
  final String status;                // Status: OPEN, IN_PROGRESS, RESOLVED

  // ========== OPTIONAL FIELDS (bisa null) ==========
  final int? technicianId;            // ID teknisi yang ditugaskan
  final String? technicianUsername;   // Nama teknisi yang ditugaskan

  // ========== STRING FIELDS (tidak null, tapi bisa empty) ==========
  final String keterangan;            // Catatan pekerjaan (default '')
  final String materialUsed;          // Material yang digunakan (default '')

  // ========== DATETIME FIELDS (bisa null) ==========
  final DateTime? scheduledDate;      // Tanggal penjadwalan
  final DateTime? createdAt;          // Tanggal dibuat
  final DateTime? updatedAt;          // Tanggal update terakhir
  final DateTime? completedAt;        // Tanggal selesai

  // Constructor dengan null safety yang baik
  Schedule({
    required this.id,
    required this.maintenanceItem,
    required this.machineName,
    required this.location,
    required this.status,
    this.technicianId,
    this.technicianUsername,
    this.keterangan = '',              // Default value untuk string
    this.materialUsed = '',            // Default value untuk string
    this.scheduledDate,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  // ========== JSON PARSING - SAFE & ROBUST ==========
  /// Parse JSON dari API dengan null-safety
  /// Menangani:
  /// - Null values dari API
  /// - Empty strings
  /// - Missing fields
  /// - Invalid date formats
  factory Schedule.fromJson(Map<String, dynamic> json) {
    try {
      return Schedule(
        // Required fields dengan fallback default
        id: json['id'] as int? ?? 0,
        maintenanceItem: json['maintenance_item'] as String? ?? 'Unknown Item',
        machineName: json['machine_name'] as String? ?? 'Unknown Machine',
        location: json['location'] as String? ?? 'Unknown Location',
        status: json['status'] as String? ?? 'OPEN',

        // Optional fields yang bisa null
        technicianId: json['technician_id'] as int?,
        // Handle kedua format API (technician_username dan technician__username)
        technicianUsername: _parseString(
          json['technician__username'] ?? json['technician_username']
        ),

        // String fields dengan fallback ke empty string
        keterangan: _parseString(json['keterangan']) ?? '',
        materialUsed: _parseString(json['material_used']) ?? '',

        // DateTime fields - bisa null
        scheduledDate: _parseDateTime(json['scheduled_date']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
        completedAt: _parseDateTime(json['completed_at']),
      );
    } catch (e) {
      print('[v0] ERROR parsing Schedule JSON: $e');
      print('[v0] DEBUG JSON: $json');
      // Return safe default object
      return Schedule(
        id: json['id'] as int? ?? 0,
        maintenanceItem: 'Error Loading Item',
        machineName: 'Unknown',
        location: 'Unknown',
        status: 'OPEN',
      );
    }
  }

  // ========== HELPER METHODS - Static ==========
  /// Parse string value dengan aman
  /// Returns: string jika tidak null dan tidak kosong, null sebaliknya
  static String? _parseString(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value.trim();  // Trim whitespace
    }
    return null;
  }

  /// Parse DateTime dengan aman
  /// Returns: DateTime jika parsing berhasil, null sebaliknya
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('[v0] ERROR parsing datetime: $value - $e');
        return null;
      }
    }
    
    if (value is DateTime) {
      return value;
    }
    
    return null;
  }

  // ========== JSON SERIALIZATION ==========
  /// Convert object ke JSON (untuk POST/PATCH requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maintenance_item': maintenanceItem,
      'machine_name': machineName,
      'location': location,
      'status': status,
      'technician_id': technicianId,
      'technician_username': technicianUsername,
      'keterangan': keterangan,
      'material_used': materialUsed,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // ========== UTILITY METHODS - DISPLAY HELPERS ==========
  
  /// Get teknisi name atau "Unassigned"
  /// Berguna untuk display di UI
  String getTechnicianDisplay() {
    if (technicianUsername != null && technicianUsername!.isNotEmpty) {
      return technicianUsername!;
    }
    return 'Unassigned';
  }

  /// Format tanggal untuk display
  /// Returns: formatted string atau "No date"
  String getScheduledDateDisplay() {
    if (scheduledDate != null) {
      try {
        return DateFormat('dd MMM yyyy', 'id_ID').format(scheduledDate!);
      } catch (e) {
        print('[v0] ERROR formatting date: $e');
        return 'Invalid date';
      }
    }
    return 'No date';
  }

  /// Get keterangan atau default message
  String getKeteranganDisplay() {
    return keterangan.isNotEmpty ? keterangan : 'No notes';
  }

  /// Get material digunakan atau default message
  String getMaterialDisplay() {
    return materialUsed.isNotEmpty ? materialUsed : 'No materials';
  }

  // ========== STATUS CHECKS - BOOLEAN GETTERS ==========
  
  /// Apakah task sudah selesai?
  bool get isCompleted => status == 'RESOLVED' && completedAt != null;

  /// Apakah task sedang dikerjakan?
  bool get isInProgress => status == 'IN_PROGRESS';

  /// Apakah task baru dibuka (belum diambil)?
  bool get isOpen => status == 'OPEN';

  /// Apakah ada teknisi yang ditugaskan?
  bool get hasAssignedTechnician => 
    technicianUsername != null && technicianUsername!.isNotEmpty;

  /// Apakah ada keterangan?
  bool get hasKeterangan => keterangan.isNotEmpty;

  /// Apakah ada material yang digunakan?
  bool get hasMaterialUsed => materialUsed.isNotEmpty;

  // ========== COMPARISON ==========
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Schedule &&
    runtimeType == other.runtimeType &&
    id == other.id;

  @override
  int get hashCode => id.hashCode;

  // ========== STRING REPRESENTATION ==========
  
  @override
  String toString() {
    return 'Schedule(id: $id, item: $maintenanceItem, status: $status, technician: $technicianUsername)';
  }

  /// Debug string dengan semua informasi
  String toDebugString() {
    return '''
Schedule {
  id: $id
  maintenanceItem: $maintenanceItem
  machineName: $machineName
  location: $location
  status: $status
  technicianId: $technicianId
  technicianUsername: $technicianUsername
  keterangan: ${keterangan.isEmpty ? '(empty)' : keterangan}
  materialUsed: ${materialUsed.isEmpty ? '(empty)' : materialUsed}
  scheduledDate: $scheduledDate
  createdAt: $createdAt
  updatedAt: $updatedAt
  completedAt: $completedAt
}
    ''';
  }
}

// ============================================================================
// 2. CONTOH PENGGUNAAN - API SERVICE
// ============================================================================

class ScheduleApiService {
  static const String baseUrl = 'https://api.example.com';

  /// Fetch schedules dari API
  /// Mendemonstrasikan safe JSON parsing
  Future<List<Schedule>> getSchedulesByMonth(int year, int month) async {
    try {
      // Simulasi API call
      final response = '''[
        {
          "id": 142,
          "maintenance_item": "CEK KONDISI KOMPRESOR",
          "machine_name": "COLD STORAGE 01",
          "location": "RUANG PENDINGIN",
          "status": "OPEN",
          "technician_username": null,
          "completed_at": null,
          "keterangan": "",
          "material_used": ""
        }
      ]''';

      // Parse response
      final List<dynamic> jsonData = jsonDecode(response);
      
      // Map setiap item menjadi Schedule object
      // Jika ada error pada satu item, tidak akan crash aplikasi
      final schedules = <Schedule>[];
      for (final json in jsonData) {
        try {
          schedules.add(Schedule.fromJson(json as Map<String, dynamic>));
        } catch (e) {
          print('[v0] ERROR parsing schedule $json: $e');
          // Continue dengan item berikutnya
        }
      }

      print('[v0] DEBUG: Successfully loaded ${schedules.length} schedules');
      return schedules;
    } catch (e) {
      print('[v0] ERROR in getSchedulesByMonth: $e');
      return [];  // Return empty list jika error
    }
  }
}

// ============================================================================
// 3. CONTOH PENGGUNAAN - UI WIDGET
// ============================================================================

import 'package:flutter/material.dart';

class ScheduleDisplayWidget extends StatelessWidget {
  final Schedule schedule;

  const ScheduleDisplayWidget({
    required this.schedule,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== MAIN ITEM TITLE ==========
            Text(
              schedule.maintenanceItem,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // ========== MACHINE NAME ==========
            Text(
              'Machine: ${schedule.machineName}',
              style: TextStyle(color: Colors.grey[600]),
            ),

            // ========== LOCATION ==========
            Text(
              'Location: ${schedule.location}',
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 12),

            // ========== STATUS BADGE ==========
            _buildStatusBadge(),

            // ========== SCHEDULED DATE - CONDITIONAL ==========
            if (schedule.scheduledDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Scheduled: ${schedule.getScheduledDateDisplay()}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],

            // ========== TECHNICIAN - CONDITIONAL ==========
            if (schedule.hasAssignedTechnician) ...[
              const SizedBox(height: 8),
              Text(
                'Technician: ${schedule.technicianUsername}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],

            // ========== KETERANGAN - CONDITIONAL ==========
            if (schedule.hasKeterangan) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.keterangan,
                      style: TextStyle(color: Colors.amber[900]),
                    ),
                  ],
                ),
              ),
            ],

            // ========== MATERIAL USED - CONDITIONAL ==========
            if (schedule.hasMaterialUsed) ...[
              const SizedBox(height: 12),
              Text(
                'Materials: ${schedule.materialUsed}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build status badge dengan color yang sesuai
  Widget _buildStatusBadge() {
    Color backgroundColor;
    String label;

    if (schedule.isOpen) {
      backgroundColor = Colors.blue;
      label = 'OPEN';
    } else if (schedule.isInProgress) {
      backgroundColor = Colors.orange;
      label = 'IN PROGRESS';
    } else {
      backgroundColor = Colors.green;
      label = 'RESOLVED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ============================================================================
// 4. CONTOH PENGGUNAAN - LIST VIEW
// ============================================================================

class ScheduleListView extends StatelessWidget {
  final List<Schedule> schedules;

  const ScheduleListView({
    required this.schedules,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Center(
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
              'No schedules found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return ScheduleDisplayWidget(schedule: schedule);
      },
    );
  }
}

// ============================================================================
// 5. TESTING EXAMPLES
// ============================================================================

class ScheduleModelTests {
  /// Test 1: Parse JSON dengan null values
  static void testParseWithNullValues() {
    final json = {
      'id': 142,
      'maintenance_item': 'CEK KOMPRESOR',
      'machine_name': 'COLD STORAGE 01',
      'location': 'RUANG PENDINGIN',
      'status': 'OPEN',
      'technician__username': null,    // Null
      'completed_at': null,             // Null
      'keterangan': '',                 // Empty string
      'material_used': '',              // Empty string
      'scheduled_date': null,           // Missing date
    };

    final schedule = Schedule.fromJson(json);

    // Assertions
    assert(schedule.id == 142);
    assert(schedule.technicianUsername == null);  // ✅ Null-safe
    assert(schedule.keterangan == '');             // ✅ Safe default
    assert(schedule.materialUsed == '');           // ✅ Safe default
    assert(schedule.scheduledDate == null);        // ✅ Optional
    assert(schedule.getTechnicianDisplay() == 'Unassigned');  // ✅ Display helper

    print('✅ Test 1 PASSED: Parse with null values');
  }

  /// Test 2: Parse JSON dengan data lengkap
  static void testParseWithCompleteData() {
    final json = {
      'id': 142,
      'maintenance_item': 'CEK KOMPRESOR',
      'machine_name': 'COLD STORAGE 01',
      'location': 'RUANG PENDINGIN',
      'status': 'IN_PROGRESS',
      'technician__username': 'John Doe',
      'completed_at': null,
      'keterangan': 'Sudah dicek, semua normal',
      'material_used': 'Lubricant, Freon',
      'scheduled_date': '2026-05-15T10:00:00Z',
      'created_at': '2026-05-01T10:00:00Z',
    };

    final schedule = Schedule.fromJson(json);

    assert(schedule.technicianUsername == 'John Doe');
    assert(schedule.keterangan == 'Sudah dicek, semua normal');
    assert(schedule.materialUsed == 'Lubricant, Freon');
    assert(schedule.hasAssignedTechnician == true);
    assert(schedule.hasKeterangan == true);
    assert(schedule.hasMaterialUsed == true);
    assert(schedule.isInProgress == true);

    print('✅ Test 2 PASSED: Parse with complete data');
  }

  /// Run all tests
  static void runAllTests() {
    print('\n========== RUNNING SCHEDULE MODEL TESTS ==========\n');
    try {
      testParseWithNullValues();
      testParseWithCompleteData();
      print('\n========== ALL TESTS PASSED ✅ ==========\n');
    } catch (e) {
      print('\n❌ TEST FAILED: $e\n');
    }
  }
}

// ============================================================================
// 6. USAGE IN MAIN
// ============================================================================

/*
void main() {
  // Run tests
  ScheduleModelTests.runAllTests();

  // Start app
  runApp(const MyApp());
}
*/
