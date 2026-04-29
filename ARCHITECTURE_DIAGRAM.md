# 📊 Architecture Diagram - Ticket Status Filtering

## Current Flow (After Frontend Fix)

```
┌─────────────────────────────────────────────────────────────────────┐
│                     FLUTTER APP (Mobile/Web)                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ ticket_list_screen.dart                                     │   │
│  │ ─────────────────────────────────────────                   │   │
│  │  [Menunggu] [Diproses] [Selesai] [Arsip]  ← UI Tabs         │   │
│  │                                             │               │   │
│  │  └─ Click "Menunggu" ──┐                   │               │   │
│  │  └─ Click "Diproses" ──┤                   ▼               │   │
│  │  └─ Click "Selesai"  ──┼──> TicketProvider.fetchTickets()  │   │
│  │  └─ Click "Arsip"    ──┘                   │               │   │
│  │                                             │               │   │
│  └──────────────────────────────────────────────┼───────────────┘   │
│                                                 │                     │
│  ┌──────────────────────────────────────────────▼──────────────────┐ │
│  │ ticket_provider.dart                                            │ │
│  │ ──────────────────────                                          │ │
│  │ Future<void> fetchTickets({String status}) {                   │ │
│  │   var tickets = await ApiService.getTickets(status: status);   │ │
│  │   notifyListeners();                                            │ │
│  │ }                                                               │ │
│  │                                                                 │ │
│  │ Example calls:                                                  │ │
│  │ - fetchTickets(status: "OPEN")         → ?status=OPEN         │ │
│  │ - fetchTickets(status: "IN_PROGRESS")  → ?status=IN_PROGRESS  │ │
│  │ - fetchTickets(status: "RESOLVED")     → ?status=RESOLVED     │ │
│  │ - fetchTickets(status: "CLOSED")       → ?status=CLOSED       │ │
│  │                                                                 │ │
│  └────────────────────────────┬──────────────────────────────────┘ │
│                               │                                     │
│  ┌────────────────────────────▼──────────────────────────────────┐ │
│  │ api_service.dart                                              │ │
│  │ ───────────────                                               │ │
│  │ static Future<List<Ticket>> getTickets({String status}) {     │ │
│  │   var url = '$baseUrl/api/tickets/';                          │ │
│  │   if (status != null) {                                       │ │
│  │     url += '?status=$status';  ← ADD QUERY PARAM              │ │
│  │   }                                                            │ │
│  │   var response = http.get(url, headers: headers);             │ │
│  │   return response.body;                                        │ │
│  │ }                                                              │ │
│  │                                                                 │ │
│  │ ✅ Already Implemented                                          │ │
│  │                                                                 │ │
│  └────────────────────────────┬──────────────────────────────────┘ │
│                               │                                     │
└───────────────────────────────┼─────────────────────────────────────┘
                                │
                HTTP Request    │
              GET + Token Auth  │
                                ▼
        ┌──────────────────────────────────────┐
        │   BACKEND (Django REST API)          │
        ├──────────────────────────────────────┤
        │                                      │
        │  GET /api/tickets/?status=OPEN      │ ← Currently returns 4 tickets
        │  GET /api/tickets/?status=IN_PROGRESS│ ← Currently returns 4 tickets
        │  GET /api/tickets/?status=RESOLVED   │ ← Currently returns 4 tickets
        │  GET /api/tickets/?status=CLOSED     │ ← Currently returns 4 tickets
        │                                      │
        │  ❌ PROBLEM: Not filtering properly   │
        │                                      │
        └──────────────────────────────────────┘


```

---

## What Frontend Expects (After Backend Fix)

```
Frontend Sends:                     Backend Should Return:
────────────────                    ──────────────────────

GET /api/tickets/?status=OPEN
                                    ✅ 2-3 tickets
                                    - All OPEN (tidak ditugaskan)
                                    - Ready untuk diambil teknisi manapun

GET /api/tickets/?status=IN_PROGRESS
                                    ✅ 1-2 tickets
                                    - Only IN_PROGRESS tickets
                                    - Assigned to logged-in technician only
                                    - Yang sedang dikerjakan

GET /api/tickets/?status=RESOLVED
                                    ✅ 0-1 tickets
                                    - Only RESOLVED tickets
                                    - Owned by logged-in technician
                                    - Yang sudah selesai

GET /api/tickets/?status=CLOSED
                                    ✅ 0-1 tickets
                                    - Only CLOSED tickets
                                    - Owned by logged-in technician
                                    - Yang sudah di-archive
```

---

## Status Lifecycle

```
┌──────────┐
│   OPEN   │  ← Tiket baru, belum ditugaskan ke siapapun
│(Menunggu)│   Teknisi manapun bisa lihat & ambil
└────┬─────┘
     │ Teknisi klik "Ambil Tugas" + UPDATE status
     │
     ▼
┌──────────────────┐
│  IN_PROGRESS     │  ← Teknisi sedang ngerjakan
│ (Diproses)       │   Hanya teknisi yang ambil yang bisa lihat
└────┬─────────────┘
     │ Teknisi upload foto bukti + selesaikan
     │
     ▼
┌──────────────────┐
│  RESOLVED        │  ← Tugas selesai, menunggu approval
│ (Selesai)        │   History teknisi
└────┬─────────────┘
     │ Admin approve atau archive
     │
     ▼
┌──────────────────┐
│   CLOSED         │  ← Tugas di-archive, riwayat
│  (Arsip)         │   History teknisi, untuk laporan
└──────────────────┘


Navigation di UI:
┌──────────┐   ┌──────────────┐   ┌──────────┐   ┌──────────┐
│Menunggu  │──▶│Diproses      │──▶│Selesai   │──▶│Arsip     │
│[OPEN]    │   │[IN_PROGRESS] │   │[RESOLVED]│   │[CLOSED]  │
└──────────┘   └──────────────┘   └──────────┘   └──────────┘
```

---

## File Structure

```
lib/
├── screens/
│   ├── ticket_list_screen.dart      ← UI dengan tabs (Menunggu/Diproses/Selesai/Arsip)
│   ├── ticket_detail_screen.dart    ← Detail ticket + foto bukti
│   ├── complete_ticket_screen.dart  ← Upload foto bukti (FIXED: Image.memory for web)
│   └── ...
│
├── providers/
│   └── ticket_provider.dart         ← State management (fetchTickets with status)
│
├── services/
│   └── api_service.dart             ← API calls dengan query params
│
└── models/
    └── ticket_model.dart            ← Ticket data model
```

---

## Key Functions

### 1. Frontend - Fetch dengan Status Filter
```dart
// ticket_provider.dart
Future<void> fetchTickets({String status}) async {
  _tickets = await ApiService.getTickets(status: status);
  notifyListeners();
}

// Dipanggil dari:
// - fetchTickets(status: 'OPEN')
// - fetchTickets(status: 'IN_PROGRESS')
// - fetchTickets(status: 'RESOLVED')
// - fetchTickets(status: 'CLOSED')
```

### 2. API Service - Build URL dengan Query Param
```dart
// api_service.dart
static Future<List<Ticket>> getTickets({String status}) async {
  String url = '$baseUrl/api/tickets/';
  if (status != null) {
    url += '?status=$status';  ← Query param added
  }
  // GET /api/tickets/?status=IN_PROGRESS
  return http.get(url, headers: _getHeaders(token: token));
}
```

### 3. Backend - Filter berdasarkan Status & User
```python
# views.py (Django) - NEEDS FIX
class TicketViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        status = self.request.query_params.get('status')
        
        if status == 'OPEN':
            # Semua tiket yang belum ditugaskan
            return Ticket.objects.filter(status='OPEN')
        
        elif status == 'IN_PROGRESS':
            # Hanya tiket yang teknisinya = user yang login
            return Ticket.objects.filter(
                status='IN_PROGRESS',
                technician=self.request.user
            )
        
        elif status in ['RESOLVED', 'CLOSED']:
            # Hanya history milik teknisi yang login
            return Ticket.objects.filter(
                status=status,
                technician=self.request.user
            )
        
        return Ticket.objects.all()
```

---

## Image Upload Flow (FIXED)

```
Complete Ticket Screen
      │
      ▼
┌──────────────────────┐
│ Image Picker Dialog  │
│ ┌─ Take Photo       │
│ └─ Choose from      │
│   Gallery           │
└────────┬─────────────┘
         │
         ▼
    ┌────────────────────────────┐
    │ Preview Image (FIXED)      │
    │                            │
    │ Desktop/Web:               │
    │ └─ Image.memory()  ✅      │
    │                            │
    │ Mobile (Android/iOS):      │
    │ └─ Image.file()    ✅      │
    │                            │
    │ (kIsWeb ? memory : file)   │
    └────────────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │ Upload + Send to API  │
         │                       │
         │ POST /api/tickets/    │
         │       {id}/           │
         │ multipart/form-data:  │
         │ - status: RESOLVED    │
         │ - photo_proof: file   │
         │ - material_used: text │
         └───────────────────────┘
```

---

## Testing Endpoints (Use Postman/Insomnia)

```bash
# Test 1: Get OPEN tickets (semua orang bisa ambil)
GET /api/tickets/?status=OPEN
Authorization: Token YOUR_TOKEN
Expected: List of unassigned tickets

# Test 2: Get IN_PROGRESS tickets (hanya milik teknisi yang login)
GET /api/tickets/?status=IN_PROGRESS
Authorization: Token YOUR_TOKEN
Expected: List of tickets assigned to you in progress

# Test 3: Get RESOLVED tickets (history yang sudah selesai)
GET /api/tickets/?status=RESOLVED
Authorization: Token YOUR_TOKEN
Expected: List of your completed tickets

# Test 4: Get CLOSED tickets (archive)
GET /api/tickets/?status=CLOSED
Authorization: Token YOUR_TOKEN
Expected: List of your archived tickets
```

---

**Status:** 
- Frontend Image Upload: ✅ FIXED
- Frontend Status Filtering: ✅ READY
- Backend Status Filtering: ⏳ NEEDS IMPLEMENTATION
