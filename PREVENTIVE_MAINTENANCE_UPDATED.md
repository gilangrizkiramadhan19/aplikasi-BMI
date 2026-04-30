# Fitur Preventive Maintenance (Perawatan Rutin) - Updated Documentation

## Overview
Fitur Preventive Maintenance yang sudah disesuaikan dengan endpoint dan requirement terbaru dari backend.

## Update Summary (vs. Versi Sebelumnya)

### 1. API Endpoint Update
- **Old:** `GET /api/preventive-maintenance/?year=2026&month=4`
- **New:** `GET /api/schedules/month/4/`
- **Change:** Year parameter dihapus (hardcoded 2026 di backend), endpoint path berubah

### 2. Schedule Model Update
#### Field Changes:
```dart
// REMOVED:
- int? technicianId
- DateTime scheduledDate
- DateTime createdAt
- DateTime updatedAt

// ADDED/CHANGED:
- technician__username (nullable, sesuai API response)
- completedAt (nullable DateTime)

// UPDATED:
- keterangan dan materialUsed sudah di-handle sebagai nullable string
```

#### JSON Parsing:
```dart
// Field name change dari 'technician_username' → 'technician__username' (double underscore)
technicianUsername: json['technician__username'] as String?
```

### 3. Submit Report - 2 Bukti Foto Support
#### Before:
- Support 1 bukti foto
- Field: `photo` (single)

#### After:
- **Support 2 bukti foto** (wajib upload dua-duanya)
- Field: `photo_1` dan `photo_2`
- UI Labels: "Bukti Foto Sebelum" dan "Bukti Foto Sesudah"
- Validasi: Kedua foto harus ada sebelum submit

#### Implementation:
```dart
// API Call baru dengan 2 file parameters
submitScheduleReport(
  scheduleId,
  filePath1,      // Photo 1 path
  filePath2,      // Photo 2 path
  keterangan,
  materialUsed,
  fileBytes1,     // Compressed bytes 1
  fileBytes2,     // Compressed bytes 2
)
```

### 4. Auto Image Compression
- Kedua bukti foto otomatis dikompres 70-80% lebih kecil
- Format: JPEG quality 75%, max 1920x1920px
- Info kompresi ditampilkan untuk setiap foto

## File Changes

### Modified Files:
1. **`lib/models/schedule_model.dart`**
   - Updated fields untuk match API response
   - Removed: technicianId, scheduledDate, createdAt, updatedAt
   - Added: completedAt
   - Changed: technician__username parsing

2. **`lib/services/api_service.dart`**
   - Updated `getSchedulesByMonth()`: hanya parameter month (int)
   - Updated `takeScheduleTask()`: endpoint path `/api/schedules/{id}/`
   - Updated `submitScheduleReport()`: support 2 files (photo_1, photo_2)

3. **`lib/providers/schedule_provider.dart`**
   - Updated method signatures untuk match API changes
   - Updated `submitReport()`: accept 2 file paths + bytes

4. **`lib/screens/preventive_maintenance_screen.dart`**
   - Updated `_loadSchedules()` call: hanya pass month parameter

5. **`lib/screens/submit_pm_report_screen.dart`**
   - **Complete rewrite** untuk support 2 bukti foto
   - Dual photo upload UI dengan compression info
   - New method: `_buildPhotoSection()` untuk render masing-masing foto
   - Validation: Kedua foto wajib ada

6. **`lib/screens/home_screen.dart`**
   - Updated PM menu onTap: hanya pass month parameter

7. **`lib/main.dart`**
   - ScheduleProvider sudah registered di MultiProvider

## API Response Example (Fixed)

### GET /api/schedules/month/4/

```json
[
  {
    "id": 142,
    "maintenance_item": "CEK KONDISI KOMPRESOR & FREON",
    "machine_name": "COLD STORAGE 01",
    "location": "RUANG PENDINGIN UTAMA",
    "status": "OPEN",
    "technician__username": null,
    "completed_at": null,
    "keterangan": "",
    "material_used": ""
  },
  {
    "id": 145,
    "maintenance_item": "PERAWATAN BAK CHILLER 02",
    "machine_name": "INSTALASI_CHILLING 02",
    "location": "RUANG PASTURISASI",
    "status": "RESOLVED",
    "technician__username": "teknisi_budi",
    "completed_at": "2026-04-30T10:00:00Z",
    "keterangan": "Sudah dibersihkan, kotoran lumpur diangkat semua.",
    "material_used": "Sabun pembersih khusus"
  }
]
```

## User Flow

### 1. Lihat Jadwal (OPEN Status)
- Home > Menu "Perawatan Rutin"
- Select bulan (default current month)
- List schedules tampil dengan status badges

### 2. Terima Jadwal
- Schedule status: OPEN
- Button "Terima Tugas" → status berubah jadi IN_PROGRESS
- Auto-refresh list

### 3. Submit Laporan (IN_PROGRESS Status)
- Button "Submit Laporan" → navigate ke SubmitPmReportScreen
- **Upload 2 bukti foto:**
  - Foto 1: "Bukti Foto Sebelum" (sebelum maintenance)
  - Foto 2: "Bukti Foto Sesudah" (setelah maintenance)
  - Auto-compress masing-masing foto
  - Show compression info
- Input Keterangan Pekerjaan (required)
- Input Material yang Digunakan (optional)
- Submit → status berubah jadi RESOLVED

### 4. Lihat Detail (RESOLVED Status)
- Schedule tampil read-only
- Show keterangan & material_used
- Show technician__username yang mengerjakan

## Nullable Field Handling

Semua field yang bisa null sudah di-handle dengan safe checks:
- `technician__username` - Show "Belum ada teknisi" jika null
- `completed_at` - Hanya tampil jika tidak null
- `keterangan` - Default empty string jika null
- `material_used` - Default empty string jika null

## Testing Checklist

- [ ] Fetch schedules bulan April berhasil
- [ ] Month navigation (prev/next) berfungsi
- [ ] Take task mengubah status OPEN → IN_PROGRESS
- [ ] Submit laporan dengan 2 foto berhasil
- [ ] Image compression info tampil dengan benar
- [ ] Validasi: tidak bisa submit jika 1 foto kosong
- [ ] Status RESOLVED schedule tampil read-only
- [ ] Tech nama tampil untuk IN_PROGRESS & RESOLVED tasks

## Notes

- Year hardcoded ke 2026 di backend, tidak perlu di-pass dari frontend
- Wajib upload 2 bukti foto untuk lengkap dokumentasi
- Image compression otomatis, user tinggal lihat info saja
- Semua field dari API response sudah di-handle sesuai data type nullable-nya
