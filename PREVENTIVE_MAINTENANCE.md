# Fitur Preventive Maintenance (Perawatan Rutin)

## Ringkasan
Fitur Preventive Maintenance memungkinkan teknisi untuk melihat jadwal perawatan rutin mesin, menerima tugas, dan melaporkan hasil perawatan dengan dokumentasi foto dan catatan.

## Arsitektur Implementasi

### 1. Model Layer
**File:** `lib/models/schedule_model.dart`
- Class `Schedule` merepresentasikan data jadwal perawatan dari API
- Fields: id, maintenanceItem, machineName, location, status, technicianId, technicianUsername, keterangan, materialUsed, scheduledDate, createdAt, updatedAt
- Support JSON serialization dengan `fromJson()` dan `toJson()`

### 2. State Management
**File:** `lib/providers/schedule_provider.dart`
- Class `ScheduleProvider` extends `ChangeNotifier`
- Methods:
  - `fetchSchedulesByMonth(year, month)` - Fetch jadwal untuk bulan tertentu
  - `takeTask(scheduleId)` - Terima tugas (ubah status OPEN → IN_PROGRESS)
  - `submitReport(...)` - Submit laporan penyelesaian dengan foto dan catatan
  - `getStatusInfo(status)` - Helper untuk mendapatkan info badge status

**Status Workflow:**
```
OPEN → User klik "Terima Tugas" → IN_PROGRESS → User klik "Selesaikan" → RESOLVED
```

### 3. API Integration
**File:** `lib/services/api_service.dart` - Tambahan methods:
- `getSchedulesByMonth(year, month)` - GET `/api/schedules/month/{month_id}/` (Backend automatically filters for year 2026)
- `takeScheduleTask(scheduleId)` - PATCH `/api/schedules/{id}/` dengan `{"status": "IN_PROGRESS"}`
- `submitScheduleReport(...)` - PATCH `/api/schedules/{id}/` dengan Multipart Form Data

**Multipart Fields untuk Submit Report:**
- `status`: "RESOLVED"
- `keterangan`: Catatan perawatan (required)
- `material_used`: Material yang digunakan (optional)
- `photo`: Dokumentasi foto (required, di-compress otomatis)

### 4. UI Screens
#### A. PreventiveMaintenanceScreen
**File:** `lib/screens/preventive_maintenance_screen.dart`
- Month selector dengan navigasi prev/next
- List schedule dengan card-based UI
- Status badges dengan color coding:
  - OPEN (Orange) - Menunggu → Tombol "Terima Tugas"
  - IN_PROGRESS (Blue) - Sedang Dikerjakan → Tombol "Lihat Detail" atau "Selesaikan"
  - RESOLVED (Green) - Selesai → Tombol "Lihat Detail"
- Dialog action sesuai status

#### B. SubmitPmReportScreen
**File:** `lib/screens/submit_pm_report_screen.dart`
- Upload foto dengan automatic compression (70-80% lebih kecil)
- Loading indicator saat kompresi
- Compression info card menampilkan perbandingan ukuran
- Text fields:
  - Keterangan Pekerjaan (required) - Textarea
  - Material Digunakan (optional) - Textarea
- Submit button dengan loading state

### 5. Integration Points

#### Foto Compression
Menggunakan `lib/utils/image_compression.dart` (dari fitur sebelumnya):
- Max width/height: 1920px
- Quality JPEG: 75%
- Result: 70-80% lebih kecil ukuran file

#### Navigation
Dari Home Screen → Klik "Perawatan Rutin" → PreventiveMaintenanceScreen
- Automatic fetch schedule untuk bulan saat ini
- User bisa navigate ke bulan sebelumnya/sesudahnya

#### State Refresh
Setelah action (take task, submit report):
- Auto-refresh schedule list untuk bulan yang sama
- User langsung melihat perubahan status

## User Flow

### 1. Melihat Jadwal
1. User masuk ke Home Screen
2. Klik menu "Perawatan Rutin"
3. Lihat jadwal untuk bulan berjalan
4. Bisa navigasi ke bulan lain dengan tombol prev/next

### 2. Menerima Tugas
1. Klik schedule dengan status "OPEN"
2. Dialog konfirmasi "Terima Tugas"
3. Klik tombol "Terima"
4. Status berubah → "IN_PROGRESS"
5. Snackbar sukses muncul

### 3. Melaporkan Hasil
1. Jadwal sudah IN_PROGRESS
2. Klik schedule → Tampil dialog dengan opsi "Selesaikan"
3. Tekan "Selesaikan" → Navigasi ke SubmitPmReportScreen
4. Upload foto (auto-compressed)
5. Isi keterangan pekerjaan
6. Isi material (opsional)
7. Klik "Kirim Laporan"
8. Auto-refresh → Status jadi "RESOLVED"

### 4. Melihat Laporan Selesai
1. Klik schedule dengan status "RESOLVED"
2. Dialog tampil detail:
   - Maintenance item
   - Teknisi penugasan
   - Lokasi
   - Keterangan pekerjaan
   - Material yang digunakan (jika ada)

## Anti-Tabrakan (Conflict Prevention)

### Current Implementation
Fitur ini belum implement pengecekan user yang assigned. Future enhancement:
- Get current user dari `AuthProvider`
- Di PM Screen: `IN_PROGRESS` hanya bisa di-complete oleh teknisi yang ditugaskan
- Teknisi lain hanya bisa view read-only

### Placeholder Code
Di `preventive_maintenance_screen.dart`:
```dart
void _showProgressDialog(Schedule schedule) {
  final isAssignedToMe = false; // TODO: Check current user
  // ...
}
```

Untuk enable, ganti dengan:
```dart
final authProvider = context.read<AuthProvider>();
final currentUserId = authProvider.currentUser?.id;
final isAssignedToMe = schedule.technicianId == currentUserId;
```

## Testing Checklist

- [ ] Month selector navigation berfungsi
- [ ] Fetch schedule berhasil untuk bulan tertentu
- [ ] Take task mengubah status OPEN → IN_PROGRESS
- [ ] Photo compression bekerja (70-80% lebih kecil)
- [ ] Submit report membuat status IN_PROGRESS → RESOLVED
- [ ] List auto-refresh setelah action
- [ ] Dialog menampilkan info correct sesuai status
- [ ] Error handling untuk API failures
- [ ] Loading states tampil dengan proper

## Future Enhancements

1. **User Assignment Check** - Hanya assigned technician yang bisa complete task
2. **Photo Gallery** - View uploaded photos dari resolved reports
3. **Report History** - Archive/history jadwal yang sudah resolved
4. **Search/Filter** - Filter schedule by maintenance item, location, status
5. **Export Report** - Generate PDF report untuk technician sign-off
6. **Notification** - Push notification untuk jadwal deadline

## Dependency

- Provider (state management)
- http (API calls)
- shared_preferences (token storage)
- image_picker (select photo)
- image (compress photo)
- intl (date formatting)
- flutter/foundation (platform detection untuk web/mobile photo handling)
