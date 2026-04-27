# 🔥 API Quick Reference - BMI Maintenance

## 🎯 2 Main Actions

### 1️⃣ TERIMA TUGAS (Accept Task)

```
PATCH /api/tickets/{id}/

Header:
  Authorization: Token <token>
  Content-Type: application/json

Body:
  {
    "status": "IN_PROGRESS"
  }

Response: 200 OK
```

**Flutter Code:**
```dart
await ApiService.updateStatus(ticketId, 'IN_PROGRESS');
```

**Location:** `ticket_detail_screen.dart` → tap "Ambil Tugas"

---

### 2️⃣ SELESAIKAN TUGAS (Complete Task)

```
PATCH /api/tickets/{id}/

Header:
  Authorization: Token <token>
  (NO Content-Type - let Flutter set to multipart/form-data)

Body: Multipart Form-Data
  - status: "RESOLVED" (required)
  - photo_proof: <binary file> (required)
  - material_used: <text> (optional)

Response: 200 OK
```

**Flutter Code:**
```dart
await ApiService.uploadPhoto(ticketId, filePath, materialUsed);
```

**Location:** `complete_ticket_screen.dart` → tap "Selesaikan dan Simpan"

---

## 🎨 Color Codes

| Status | Warna | Hex |
| ------ | ----- | --- |
| OPEN | 🔴 Red | #E53935 |
| IN_PROGRESS | 🟠 Orange | #F57C00 |
| RESOLVED | 🟢 Green | #43A047 |
| CLOSED | ⚪ Gray | #616161 |

---

## 📝 Status Flow

```
OPEN (Menunggu)
  ↓ [Ambil Tugas]
IN_PROGRESS (Diproses)
  ↓ [Selesaikan Tugas + Upload Foto]
RESOLVED (Selesai)
  ↓ [Admin Action]
CLOSED (Arsip)
```

---

## ⚡ Key Points

✅ Both actions use **same endpoint** `/api/tickets/{id}/`  
✅ Both use **PATCH method**  
✅ Accept Task: **JSON** body  
✅ Complete Task: **Multipart** form-data  
✅ Always include **Authorization** header  
✅ Check **status code 200**  

---

## 🐛 Common Errors

| Error | Cause | Fix |
| ----- | ----- | --- |
| 401 | Token invalid/expired | Re-login |
| 400 | Invalid body format | Check JSON/Multipart |
| 404 | Ticket not found | Check ticket ID |
| 500 | Server error | Contact backend |

---

## 📱 UI Screens

| Screen | Action | Endpoint |
| ------ | ------ | -------- |
| `ticket_detail_screen.dart` | "Ambil Tugas" | PATCH /api/tickets/{id}/ |
| `complete_ticket_screen.dart` | "Selesaikan dan Simpan" | PATCH /api/tickets/{id}/ |

---

**Done!** ✨ Sesuai dengan API guidelines dari backend team
