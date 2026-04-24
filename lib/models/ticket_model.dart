class Ticket {
  final int id;
  final String title;
  final String description;
  final String location;
  final String status;
  final int? reporter;
  final String? reporterName;
  final int? technician;
  final String? technicianName;
  final String? materialUsed;
  final String? photoProof;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    this.reporter,
    this.reporterName,
    this.technician,
    this.technicianName,
    this.materialUsed,
    this.photoProof,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      reporter: json['reporter'] as int?,
      reporterName: json['reporter_name'] as String?,
      technician: json['technician'] as int?,
      technicianName: json['technician_name'] as String?,
      materialUsed: json['material_used'] as String?,
      photoProof: json['photo_proof'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'status': status,
      'reporter': reporter,
      'reporter_name': reporterName,
      'technician': technician,
      'technician_name': technicianName,
      'material_used': materialUsed,
      'photo_proof': photoProof,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
