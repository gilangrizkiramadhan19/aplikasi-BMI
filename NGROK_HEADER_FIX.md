# Ngrok Header Fix - API Service Update

## Problem
Tim mobile (Flutter app) tidak mengirimkan ngrok header di semua API requests, hanya di login function. Ini menyebabkan beberapa request (GET, PATCH) diblokir oleh ngrok tunnel.

## Solution
Menambahkan `ngrok-skip-browser-warning: true` header ke SEMUA HTTP requests menggunakan helper method yang konsisten.

## Perubahan yang Dilakukan

### 1. Helper Method untuk Headers Konsisten
```dart
static Map<String, String> _getHeaders({String? token}) {
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',  // <-- NGROK HEADER
  };
  
  if (token != null) {
    headers['Authorization'] = 'Token $token';
  }
  
  return headers;
}
```

### 2. Semua Methods Menggunakan Helper
Diupdate 6 methods:
- ✅ `login()` - POST request
- ✅ `getTickets()` - GET request
- ✅ `getTicketDetail()` - GET request
- ✅ `updateStatus()` - PATCH request
- ✅ `uploadPhoto()` - PATCH request (multipart)
- ✅ `createTicket()` - POST request

### 3. Contoh Penggunaan

**Before:**
```dart
final response = await http.get(
  Uri.parse(url),
  headers: {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
).timeout(...);
```

**After:**
```dart
final response = await http.get(
  Uri.parse(url),
  headers: _getHeaders(token: token),
).timeout(...);
```

**Untuk Multipart (uploadPhoto):**
```dart
request.headers['Authorization'] = 'Token $token';
request.headers['ngrok-skip-browser-warning'] = 'true';
```

## Headers yang Dikirim Sekarang

### Untuk Request Tanpa Token (Login)
```
Content-Type: application/json
Accept: application/json
ngrok-skip-browser-warning: true
```

### Untuk Request Dengan Token (GET, POST, PATCH)
```
Content-Type: application/json
Accept: application/json
Authorization: Token <token>
ngrok-skip-browser-warning: true
```

## Hasil
✅ Semua API requests sekarang dilengkapi ngrok header
✅ Login tetap berfungsi
✅ GET requests (fetch tasks) sekarang berfungsi
✅ PATCH requests (update status, upload photo) sekarang berfungsi

## Testing
1. Login dengan credentials yang benar
2. Buka DevTools (F12 > Console)
3. Lihat debug output `[v0] DEBUG:` 
4. Dashboard harus menampilkan task counts
5. Lihat Tugas harus menampilkan list of tasks

## File yang Dimodifikasi
- `lib/services/api_service.dart` - Menambahkan helper method dan update semua requests
