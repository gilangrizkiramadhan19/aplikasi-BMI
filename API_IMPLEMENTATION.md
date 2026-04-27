# 📡 API Implementation Guide - BMI Maintenance

Dokumentasi implementasi API untuk fitur **Terima Tugas** dan **Submit Tugas**.

---

## 🔹 1. AKSI: Terima Tugas (Accept Task)

**Kondisi:** Teknisi mengambil tugas dari status **OPEN → IN_PROGRESS**

**Endpoint:**
```
PATCH /api/tickets/{id}/
```

**Headers:**
```
Authorization: Token <token_teknisi>
Content-Type: application/json
```

**Request Body:**
```json
{
  "status": "IN_PROGRESS"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "title": "Perbaikan BMI Unit A",
  "status": "IN_PROGRESS",
  "technician": 2,
  ...
}
```

**Implementation (Flutter):**
```dart
// Di api_service.dart - updateStatus()
await http.patch(
  Uri.parse('$baseUrl/api/tickets/$ticketId/'),
  headers: {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({'status': 'IN_PROGRESS'}),
);
```

**Usage (dari ticket_detail_screen.dart):**
```dart
final success = await ticketProvider.updateTicketStatus(ticket.id, 'IN_PROGRESS');
if (success) {
  // Tampilkan success snackbar
}
```

---

## 🔹 2. AKSI: Submit Tugas (Complete Task with Photo)

**Kondisi:** Teknisi menyelesaikan pekerjaan + upload bukti foto

**Endpoint:**
```
PATCH /api/tickets/{id}/
```

**Headers:**
```
Authorization: Token <token_teknisi>
```

⚠️ **PENTING:** Jangan set `Content-Type` manual. Biarkan Flutter mengatur otomatis ke `multipart/form-data`.

**Request Body (Multipart Form-Data):**

| Field         | Tipe   | Required | Keterangan                    |
| ------------- | ------ | -------- | ----------------------------- |
| status        | String | Ya       | Harus "RESOLVED"              |
| photo_proof   | File   | Ya       | File gambar hasil perbaikan   |
| material_used | String | Tidak    | Deskripsi material digunakan  |

**Response (200 OK):**
```json
{
  "id": 1,
  "title": "Perbaikan BMI Unit A",
  "status": "RESOLVED",
  "photo_proof": "/media/tickets/1/photo.jpg",
  "material_used": "Ganti bearing, oli mesin",
  ...
}
```

**Implementation (Flutter):**
```dart
// Di api_service.dart - uploadPhoto()
final request = http.MultipartRequest(
  'PATCH', // ⚠️ PATCH, bukan POST
  Uri.parse('$baseUrl/api/tickets/$ticketId/'),
);

request.headers['Authorization'] = 'Token $token';
// Jangan set Content-Type!

request.fields['status'] = 'RESOLVED';
if (materialUsed != null && materialUsed.isNotEmpty) {
  request.fields['material_used'] = materialUsed;
}

request.files.add(
  await http.MultipartFile.fromPath('photo_proof', filePath),
);

final response = await request.send();
if (response.statusCode != 200) {
  throw Exception('Failed: ${response.statusCode}');
}
```

**Usage (dari complete_ticket_screen.dart):**
```dart
final success = await ticketProvider.completeTicket(
  ticket.id,
  imagePath,
  descriptionText,
);

if (success) {
  // Navigasi ke home dan tampilkan success message
  Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
}
```

---

## 🔄 Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                  TICKET WORKFLOW                         │
└─────────────────────────────────────────────────────────┘

1. OPEN (Menunggu)
   └─> User tap "Ambil Tugas"
       └─> Dialog Konfirmasi
           └─> PATCH /api/tickets/{id}/ 
               Body: {"status": "IN_PROGRESS"}
               └─> Status berubah → IN_PROGRESS
                   └─> Refresh list + show success snackbar

2. IN_PROGRESS (Diproses)
   └─> User tap "Selesaikan Tugas"
       └─> Navigate ke Complete Screen
           └─> User upload foto + deskripsi
               └─> User tap "Selesaikan dan Simpan"
                   └─> PATCH /api/tickets/{id}/ 
                       Body: Multipart
                       - status: "RESOLVED"
                       - photo_proof: <file>
                       - material_used: <text>
                       └─> Status berubah → RESOLVED
                           └─> Refresh + Navigate ke home
                               └─> Show success snackbar

3. RESOLVED (Selesai)
   └─> Menunggu validasi admin
       └─> Admin bisa close → CLOSED

4. CLOSED (Arsip)
   └─> Tersimpan dalam history
```

---

## ✅ Error Handling

**Status Code Responses:**

| Code | Meaning | Action |
| ---- | ------- | ------ |
| 200  | Success | Lanjut ke next step |
| 201  | Created | Lanjut ke next step |
| 400  | Bad Request | Tampilkan error message dari response |
| 401  | Unauthorized | Token expired/invalid, ke login screen |
| 404  | Not Found | Ticket tidak ditemukan |
| 500  | Server Error | Tampilkan generic error message |

**Error Handling Implementation:**
```dart
try {
  await ApiService.updateStatus(ticketId, 'IN_PROGRESS');
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: ${e.toString()}'),
      backgroundColor: Color(0xFFE53935),
    ),
  );
}
```

---

## 🔐 Authentication

Semua request harus include token di header:
```
Authorization: Token <token_user>
```

Token didapat dari login dan disimpan di `SharedPreferences`:
```dart
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('token'); // Retrieve token
```

---

## 📊 Testing Endpoint

### Test 1: Terima Tugas
```bash
curl -X PATCH https://<url-ngrok>/api/tickets/1/ \
  -H "Authorization: Token <token>" \
  -H "Content-Type: application/json" \
  -d '{"status":"IN_PROGRESS"}'
```

### Test 2: Submit Tugas dengan Photo
```bash
curl -X PATCH https://<url-ngrok>/api/tickets/1/ \
  -H "Authorization: Token <token>" \
  -F "status=RESOLVED" \
  -F "material_used=Ganti bearing" \
  -F "photo_proof=@/path/to/photo.jpg"
```

---

## 🚀 Summary

| Feature | Method | Endpoint | Body Type |
| ------- | ------ | -------- | --------- |
| Ambil Tugas | PATCH | `/api/tickets/{id}/` | JSON |
| Selesaikan Tugas | PATCH | `/api/tickets/{id}/` | Multipart |

**Key Points:**
✅ Gunakan endpoint yang sama untuk kedua aksi  
✅ Bedakan dengan method dan payload  
✅ Untuk multipart, jangan set Content-Type manual  
✅ Selalu include Authorization header  
✅ Handle error dengan graceful  
✅ Refresh state setelah API call berhasil
