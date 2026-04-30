class Schedule {
  final int id;
  final String maintenanceItem;
  final String machineName;
  final String location;
  final String status; // OPEN, IN_PROGRESS, RESOLVED
  final String? technicianUsername;
  final String? keterangan;
  final String? materialUsed;
  final DateTime? completedAt;

  Schedule({
    required this.id,
    required this.maintenanceItem,
    required this.machineName,
    required this.location,
    required this.status,
    this.technicianUsername,
    this.keterangan,
    this.materialUsed,
    this.completedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      maintenanceItem: json['maintenance_item'] as String,
      machineName: json['machine_name'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      technicianUsername: json['technician__username'] as String?,
      keterangan: json['keterangan'] as String?,
      materialUsed: json['material_used'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maintenance_item': maintenanceItem,
      'machine_name': machineName,
      'location': location,
      'status': status,
      'technician__username': technicianUsername,
      'keterangan': keterangan,
      'material_used': materialUsed,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
