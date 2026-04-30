class Schedule {
  final int id;
  final String maintenanceItem;
  final String machineName;
  final String location;
  final String status; // OPEN, IN_PROGRESS, RESOLVED
  final int? technicianId;
  final String? technicianUsername;
  final String? keterangan;
  final String? materialUsed;
  final DateTime scheduledDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.maintenanceItem,
    required this.machineName,
    required this.location,
    required this.status,
    this.technicianId,
    this.technicianUsername,
    this.keterangan,
    this.materialUsed,
    required this.scheduledDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      maintenanceItem: json['maintenance_item'] as String,
      machineName: json['machine_name'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      technicianId: json['technician_id'] as int?,
      technicianUsername: json['technician_username'] as String?,
      keterangan: json['keterangan'] as String?,
      materialUsed: json['material_used'] as String?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
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
      'scheduled_date': scheduledDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
