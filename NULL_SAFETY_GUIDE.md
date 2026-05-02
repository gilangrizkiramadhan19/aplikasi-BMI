# Flutter Null Safety Guide - Schedule Model

## Ringkasan Perbaikan

Aplikasi mengalami error `type 'Null' is not a subtype of type 'String'` karena model `Schedule` tidak menangani nilai null dengan baik dari API response. Dokumentasi ini menjelaskan cara memperbaiki dan best practice untuk null safety di Flutter.

---

## Masalah yang Ditemukan

### Response API dari Backend
```json
[
  {
    "id": 142,
    "maintenance_item": "CEK KONDISI KOMPRESOR & FREON",
    "machine_name": "COLD STORAGE 01",
    "location": "RUANG PENDINGIN UTAMA",
    "status": "OPEN",
    "technician__username": null,        // ❌ Null value
    "completed_at": null,                // ❌ Null value
    "keterangan": "",                    // ⚠️ Empty string
    "material_used": ""                  // ⚠️ Empty string
  }
]
```

### Error Terjadi Karena
1. **Force Unwrap Tanpa Null Check**: `json['field'] as String` akan crash jika value null
2. **Parsing DateTime Tanpa Validasi**: `DateTime.parse(null)` akan error
3. **UI Display Tanpa Null Check**: Menampilkan null value langsung akan error

---

## Solusi yang Diterapkan

### 1. Model dengan Nullable Fields

```dart
class Schedule {
  // Required fields (tidak bisa null)
  final int id;
  final String maintenanceItem;
  final String machineName;
  final String location;
  final String status;

  // Optional fields (bisa null)
  final int? technicianId;                    // int atau null
  final String? technicianUsername;           // String atau null
  
  // String dengan default value empty string
  final String keterangan;                    // Tidak null, default ''
  final String materialUsed;                  // Tidak null, default ''
  
  // DateTime optional
  final DateTime? scheduledDate;              // DateTime atau null
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Schedule({
    required this.id,
    required this.maintenanceItem,
    required this.machineName,
    required this.location,
    required this.status,
    this.technicianId,                        // Optional parameter
    this.technicianUsername,
    this.keterangan = '',                     // Default value
    this.materialUsed = '',                   // Default value
    this.scheduledDate,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });
}
```

### 2. Safe JSON Parsing dengan Helper Methods

```dart
/// Contoh API response yang tidak aman (lama)
factory Schedule.fromJson(Map<String, dynamic> json) {
  return Schedule(
    id: json['id'] as int,                    // ❌ Crash jika null
    maintenanceItem: json['maintenance_item'] as String,  // ❌ Crash jika null
    status: json['status'] as String,
    // ...
  );
}

/// Perbaikan: Safe parsing dengan default values
factory Schedule.fromJson(Map<String, dynamic> json) {
  try {
    return Schedule(
      id: json['id'] as int? ?? 0,                        // ✅ Default 0 jika null
      maintenanceItem: json['maintenance_item'] as String? ?? 'Unknown Item',  // ✅ Default jika null
      location: json['location'] as String? ?? 'Unknown Location',
      status: json['status'] as String? ?? 'OPEN',
      
      // Field bisa null
      technicianUsername: _parseString(json['technician__username']),  // ✅ Null-safe
      
      // Field yang selalu String (tidak null)
      keterangan: _parseString(json['keterangan']) ?? '',  // ✅ Default empty string
      materialUsed: _parseString(json['material_used']) ?? '',
      
      // DateTime parsing aman
      scheduledDate: _parseDateTime(json['scheduled_date']),  // ✅ Return null jika invalid
      createdAt: _parseDateTime(json['created_at']),
      // ...
    );
  } catch (e) {
    print('[v0] ERROR parsing Schedule JSON: $e');
    return Schedule(
      id: json['id'] as int? ?? 0,
      maintenanceItem: 'Error Loading Item',
      machineName: 'Unknown',
      location: 'Unknown',
      status: 'OPEN',
    );
  }
}

/// Helper untuk parsing String dengan aman
static String? _parseString(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;  // Return null jika kosong atau bukan String
}

/// Helper untuk parsing DateTime dengan aman
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
```

### 3. Utility Methods untuk UI

```dart
/// Helper untuk menampilkan nama teknisi
String getTechnicianDisplay() {
  return technicianUsername?.isNotEmpty ?? false 
      ? technicianUsername! 
      : 'Unassigned';
}

/// Getter untuk status
bool get isCompleted => status == 'RESOLVED' && completedAt != null;
bool get isInProgress => status == 'IN_PROGRESS';
bool get isOpen => status == 'OPEN';
```

### 4. UI Display Aman dari Null Value

#### ❌ TIDAK AMAN (Lama)
```dart
Text(
  schedule.scheduledDate.toString(),  // ❌ Crash jika null
),

Text(
  schedule.keterangan!,               // ❌ Force unwrap, crash jika null
),

if (schedule.materialUsed != null && schedule.materialUsed!.isNotEmpty)
  Text(schedule.materialUsed!),       // ❌ Double null check + force unwrap
```

#### ✅ AMAN (Diperbaiki)
```dart
// Cek null sebelum gunakan
if (schedule.scheduledDate != null)
  Text(
    DateFormat('dd MMM yyyy', 'id_ID')
        .format(schedule.scheduledDate!),  // ✅ Safe unwrap setelah null check
  ),

// String dengan default value (tidak bisa null)
Text(
  schedule.keterangan.isNotEmpty 
      ? schedule.keterangan 
      : 'Tidak ada keterangan',  // ✅ Default text jika kosong
),

// Conditional rendering
if (schedule.materialUsed.isNotEmpty)  // ✅ Simple null-safe check
  Text(schedule.materialUsed),
```

---

## Best Practices Null Safety di Flutter

### 1. Pilih Type yang Tepat
```dart
// ✅ Jika field bisa null
final String? optionalName;

// ✅ Jika field selalu ada tapi bisa kosong
final String name = '';

// ✅ Jika field required
final String requiredName;
```

### 2. Handle Null dengan Operator `??`
```dart
// Default value jika null
final name = user.name ?? 'Anonymous';

// Chaining multiple defaults
final status = json['status'] ?? 'UNKNOWN' ?? 'DEFAULT';
```

### 3. Conditional Rendering
```dart
// ✅ Render hanya jika tidak null
if (schedule.technicianUsername != null)
  Text(schedule.technicianUsername!),

// ✅ Render dengan fallback
Text(
  schedule.technicianUsername ?? 'Unassigned'
),
```

### 4. Safe Unwrap
```dart
// ❌ Dangerous
final date = schedule.scheduledDate;
Text(date.toString());  // Crash jika null

// ✅ Safe dengan if
if (schedule.scheduledDate != null) {
  Text(schedule.scheduledDate!.toString());
}

// ✅ Safe dengan ?.
Text(schedule.scheduledDate?.toString() ?? 'No date'),
```

### 5. Try-Catch untuk JSON Parsing
```dart
try {
  final data = jsonDecode(response.body);
  final schedule = Schedule.fromJson(data);
  return schedule;
} catch (e) {
  print('[v0] ERROR: $e');
  return Schedule.empty();  // Return default object
}
```

---

## Testing Null Safety

### Test Case 1: API Response dengan Null Values
```dart
void testScheduleWithNullValues() {
  final json = {
    'id': 142,
    'maintenance_item': 'CEK KOMPRESOR',
    'machine_name': 'COLD STORAGE 01',
    'location': 'RUANG PENDINGIN',
    'status': 'OPEN',
    'technician__username': null,  // Null
    'completed_at': null,          // Null
    'keterangan': '',              // Empty
    'material_used': '',           // Empty
  };

  final schedule = Schedule.fromJson(json);
  
  expect(schedule.id, 142);
  expect(schedule.technicianUsername, null);      // ✅ null-safe
  expect(schedule.keterangan, '');                // ✅ Safe default
  expect(schedule.scheduledDate, null);           // ✅ Optional date
}
```

### Test Case 2: API Response Lengkap
```dart
void testScheduleWithCompleteData() {
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
  };

  final schedule = Schedule.fromJson(json);
  
  expect(schedule.technicianUsername, 'John Doe');  // ✅ Dari API
  expect(schedule.keterangan, 'Sudah dicek, semua normal');
  expect(schedule.isInProgress, true);              // ✅ Helper method
}
```

---

## Checklist Null Safety Implementation

- [x] Model fields menggunakan `?` untuk optional values
- [x] Non-nullable fields memiliki default value
- [x] `fromJson()` menggunakan `??` operator untuk fallback
- [x] Helper methods untuk parsing (String, DateTime)
- [x] Try-catch di `fromJson()` untuk error handling
- [x] UI menggunakan `if (value != null)` sebelum display
- [x] Utility methods seperti `getTechnicianDisplay()`
- [x] Getter methods untuk status checks
- [x] Proper debug logging dengan `[v0]` prefix

---

## Migrasi dari Kode Lama

Jika Anda memiliki kode lama yang menggunakan force unwrap, ikuti langkah ini:

### Step 1: Identifikasi Force Unwrap
```bash
# Cari semua force unwrap di project
grep -r "!\\." lib/

# Hasil:
# lib/screens/preventive_maintenance_screen.dart:408:                    schedule.keterangan!,
# lib/screens/preventive_maintenance_screen.dart:431:                    schedule.materialUsed!,
```

### Step 2: Replace dengan Null-Safe Code
```dart
// Dari:
Text(schedule.keterangan!),

// Ke:
Text(
  schedule.keterangan.isNotEmpty 
      ? schedule.keterangan 
      : 'Tidak ada keterangan',
),
```

### Step 3: Update Model Definition
```dart
// Dari:
final String? keterangan;  // Bisa null

// Ke:
final String keterangan;   // Selalu String, bisa empty
```

---

## Contoh Lengkap Penggunaan

### Model
```dart
class Schedule {
  final int id;
  final String maintenanceItem;
  final String? technicianUsername;  // Optional
  final String keterangan;           // Default ''
  
  Schedule({
    required this.id,
    required this.maintenanceItem,
    this.technicianUsername,
    this.keterangan = '',
  });
  
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int? ?? 0,
      maintenanceItem: json['maintenance_item'] as String? ?? 'Unknown',
      technicianUsername: json['technician_username'] as String?,
      keterangan: (json['keterangan'] as String?)?.isNotEmpty ?? false
          ? json['keterangan'] as String
          : '',
    );
  }
}
```

### Provider
```dart
class ScheduleProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];

  Future<void> fetchSchedules() async {
    try {
      final data = await api.getSchedules();
      _schedules = data
          .map((json) => Schedule.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      print('[v0] ERROR: $e');
      _schedules = [];  // Empty list jika error
    }
  }
}
```

### UI
```dart
class ScheduleWidget extends StatelessWidget {
  final Schedule schedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(schedule.maintenanceItem),
        if (schedule.technicianUsername != null)
          Text('Teknisi: ${schedule.technicianUsername}'),
        if (schedule.keterangan.isNotEmpty)
          Text('Keterangan: ${schedule.keterangan}'),
      ],
    );
  }
}
```

---

## Resources

- [Dart Null Safety Documentation](https://dart.dev/null-safety)
- [Flutter Best Practices](https://flutter.dev/docs/testing/best-practices)
- [Effective Dart: Design](https://dart.dev/guides/language/effective-dart/design)

---

**Last Updated:** 2 May 2026  
**Status:** ✅ Implemented and Tested
