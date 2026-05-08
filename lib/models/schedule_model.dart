class Schedule {
  final int id;
  final String maintenanceItem;
  final String machineName;
  final String location;
  final String status; // OPEN, IN_PROGRESS, RESOLVED
  final int? technicianId;
  final String? technicianUsername;
  final String keterangan;
  final String materialUsed;
  final DateTime? scheduledDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Schedule({
    required this.id,
    required this.maintenanceItem,
    required this.machineName,
    required this.location,
    required this.status,
    this.technicianId,
    this.technicianUsername,
    this.keterangan = '',
    this.materialUsed = '',
    this.scheduledDate,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  /// Parse JSON response from API with null-safety
  /// Handles missing or null fields gracefully
  factory Schedule.fromJson(Map<String, dynamic> json) {
    try {
      return Schedule(
        id: json['id'] as int? ?? 0,
        maintenanceItem: json['maintenance_item'] as String? ?? 'Unknown Item',
        machineName: json['machine_name'] as String? ?? 'Unknown Machine',
        location: json['location'] as String? ?? 'Unknown Location',
        status: json['status'] as String? ?? 'OPEN',
        technicianId: json['technician_id'] as int?,
        // Handle both null and empty string for username
        technicianUsername: _parseString(json['technician__username'] ?? json['technician_username']),
        // Handle null and empty string, default to empty string
        keterangan: _parseString(json['keterangan']) ?? '',
        materialUsed: _parseString(json['material_used']) ?? '',
        // Parse dates safely - can be null if not provided by API
        scheduledDate: _parseDateTime(json['scheduled_date']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
        completedAt: _parseDateTime(json['completed_at']),
      );
    } catch (e) {
      print('[v0] ERROR parsing Schedule JSON: $e');
      // Return a safe default Schedule object
      return Schedule(
        id: json['id'] as int? ?? 0,
        maintenanceItem: 'Error Loading Item',
        machineName: 'Unknown',
        location: 'Unknown',
        status: 'OPEN',
      );
    }
  }

  /// Helper to safely parse string values from JSON
  /// Converts null or empty strings to null
  static String? _parseString(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  /// Helper to safely parse DateTime values from JSON
  /// Returns null if parsing fails or value is null
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
    return null;
  }

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

  /// Get technician name or display "Unassigned"
  String getTechnicianDisplay() {
    return technicianUsername?.isNotEmpty ?? false 
        ? technicianUsername! 
        : 'Unassigned';
  }

  /// Check if task is completed
  bool get isCompleted => status == 'RESOLVED' && completedAt != null;

  /// Check if task is in progress
  bool get isInProgress => status == 'IN_PROGRESS';

  /// Check if task is open
  bool get isOpen => status == 'OPEN';
}
