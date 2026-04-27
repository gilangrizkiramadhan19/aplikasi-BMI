# DEBUG GUIDE - Data Not Loading Issue

## Problem
Flutter app shows "Tidak ada tugas" (No tasks) ketika dibuka, tapi web dashboard sudah menampilkan data dengan benar.

## Root Cause Analysis

Ada 2 kemungkinan penyebab utama:

### 1. **Token Not Found (Most Common)**
- User belum login dengan benar
- Token tidak tersimpan di SharedPreferences
- Token sudah expired

### 2. **Authentication Issue**
- Token tidak valid
- API request di-reject oleh backend
- Header authentication tidak benar

## How to Debug

### Step 1: Check Console Logs
1. Open Flutter app di browser (F12 > Console)
2. Login dengan credentials yang benar
3. Lihat console output yang dimulai dengan `[v0]`
4. Catat output yang muncul

### Step 2: Look for Debug Messages

#### Success Case:
```
[v0] DEBUG: Attempting login for user: teknisi_listrik
[v0] DEBUG: Login response status: 200
[v0] DEBUG: Login successful! Token received: eyJ0eXAiOi...
[v0] DEBUG: TicketProvider.fetchTickets called with status: OPEN
[v0] DEBUG: Token from storage = EXISTS
[v0] DEBUG: Fetching from URL: https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/?status=OPEN
[v0] DEBUG: Using token: eyJ0eXAiOi...
[v0] DEBUG: Response status: 200
[v0] DEBUG: Successfully loaded 3 tickets
```

#### Failure Case - No Token:
```
[v0] DEBUG: TicketProvider.fetchTickets called with status: OPEN
[v0] ERROR: No token found in SharedPreferences
[v0] ERROR in getTickets: No token found - Please login first
```

#### Failure Case - Invalid Token:
```
[v0] DEBUG: Response status: 401
[v0] ERROR: Unauthorized - Token invalid or expired
```

### Step 3: Troubleshooting

**Problem: "No token found"**
- Solution: Login terlebih dahulu, pastikan login berhasil
- Check: Pastikan SharedPreferences tidak kosong

**Problem: Response status 401**
- Solution: Token sudah expired, login ulang
- Check: Pastikan backend server masih berjalan

**Problem: Response status 500**
- Solution: Backend server error
- Check: Cek terminal backend server untuk error log

**Problem: Timeout**
- Solution: Network issue atau server tidak merespons
- Check: Cek URL endpoint dan pastikan server berjalan

## Expected Output

### Home Screen (Dashboard):
```
[v0] DEBUG: fetchAllTicketsForStats called
[v0] DEBUG: Stats - Open: 1, InProgress: 1, Resolved: 1
```

### Ticket List Screen:
```
[v0] DEBUG: TicketProvider.fetchTickets called with status: OPEN
[v0] DEBUG: Successfully fetched 1 tickets
```

### Ticket Detail Screen:
```
[v0] DEBUG: Fetching ticket detail for ID: 1
[v0] DEBUG: Detail response status: 200
[v0] DEBUG: Successfully loaded ticket detail
```

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Tidak ada tugas" | Token not found | Login terlebih dahulu |
| Same message | Token expired | Logout dan login ulang |
| Timeout error | Network problem | Cek internet connection |
| 401 error | Invalid token | Clear storage dan login ulang |
| 500 error | Backend crash | Restart backend server |

## Steps to Verify

1. **Clear App Data:**
   - Go to device settings > Apps > BMI Maintenance > Clear Storage
   - Or use `adb shell pm clear com.example.bmi_maintenance`

2. **Restart App:**
   - Fully close the app
   - Restart Flutter app fresh

3. **Login Again:**
   - Use correct credentials from web dashboard
   - Watch console for `[v0]` debug messages

4. **Check Response:**
   - If you see "Successfully loaded X tickets", data fetch is working
   - If you see error message, follow troubleshooting steps

## Backend Endpoint Verification

To manually test if backend is working:

```bash
# Get token
curl -X POST https://upstate-unbaked-peso.ngrok-free.dev/api/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"teknisi_listrik","password":"your_password"}'

# Get tickets using token
curl -H "Authorization: Token YOUR_TOKEN_HERE" \
  https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/?status=OPEN
```

If backend responds correctly, issue is with Flutter app token handling.

## Contact Backend Team

If all steps pass but still no data:
- Share console output with backend team
- Provide the exact `[v0]` error messages
- They can check if there's an API issue on their side
