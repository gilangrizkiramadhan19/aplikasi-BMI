# Photo Display Issue - Debugging Guide

## Problem
Flutter app shows "Gagal memuat foto" but web dashboard displays photos correctly.

## Root Causes to Check

### 1. Photo URL Format
The `photo_proof` field from API should contain a valid URL.

**Check if URL is:**
- Full URL: `https://upstate-unbaked-peso.ngrok-free.dev/media/...`
- Or relative URL: `/media/photos/...`

**What web does:** Converts relative URL to full URL automatically

**What Flutter needs:** Check the exact format in API response

### 2. Missing ngrok Header
Image.network() must include ngrok header for browser-based requests.

**Fixed in latest version:**
```dart
Image.network(
  ticket.photoProof!,
  headers: const {
    'ngrok-skip-browser-warning': 'true',
  },
)
```

### 3. URL Construction Issues
If `photo_proof` is relative URL like `/media/photos/123.jpg`, it needs to be converted to full URL.

**Solution:**
```dart
String getFullPhotoUrl(String photoProof) {
  if (photoProof.startsWith('http')) {
    return photoProof;
  }
  return 'https://upstate-unbaked-peso.ngrok-free.dev$photoProof';
}
```

### 4. Missing Token Authentication
If photo URL requires authentication, need to add token header.

**Solution:**
```dart
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('token');

Image.network(
  ticket.photoProof!,
  headers: {
    'ngrok-skip-browser-warning': 'true',
    if (token != null) 'Authorization': 'Token $token',
  },
)
```

## How to Debug

### Step 1: Check API Response
Look at console logs for the exact `photo_proof` value:
```
[v0] DEBUG: Response body: {"photo_proof":"https://..."}
```

### Step 2: Test URL in Browser
Copy the `photo_proof` URL and open in browser directly to see if it loads.

### Step 3: Check Error Message
When "Gagal memuat foto" appears, the error message should show the attempted URL.

## Expected Behavior After Fix

1. Photo loads with ngrok header
2. Loading spinner appears while downloading
3. Photo displays or shows detailed error if URL is wrong
4. Error message includes URL being attempted

## Files Modified
- `lib/screens/ticket_detail_screen.dart`
  - Added ngrok header to Image.network()
  - Added loading indicator
  - Enhanced error message to show attempted URL

## Next Steps
1. Reload Flutter app
2. Navigate to ticket with photo
3. Check console for photo URL
4. Verify photo loads
5. If still not working, check the displayed URL format
