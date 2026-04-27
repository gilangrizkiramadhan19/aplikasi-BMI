# CORS Configuration Guide

## Problem
Flutter Web app mendapat error: `ClientException: Failed to fetch`
- Login works ✓ (POST request)
- Fetch tickets fails ✗ (GET request blocked by CORS)

## Root Cause
Browser blocking cross-origin requests karena backend belum send proper CORS headers.

## Solution - Django Backend Configuration

### 1. Install django-cors-headers
```bash
pip install django-cors-headers
```

### 2. Update settings.py

Add to INSTALLED_APPS:
```python
INSTALLED_APPS = [
    ...
    'corsheaders',
    ...
]
```

Add middleware at TOP of MIDDLEWARE list:
```python
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Add this FIRST
    'django.middleware.common.CommonMiddleware',
    ...
]
```

Add CORS configuration:
```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5025",
    "http://localhost:3000",
    "http://127.0.0.1:5025",
    "http://127.0.0.1:3000",
    "https://upstate-unbaked-peso.ngrok-free.dev",  # Add ngrok URL
]

CORS_ALLOW_METHODS = [
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'OPTIONS',
]

CORS_ALLOW_HEADERS = [
    'authorization',
    'content-type',
    'accept',
]
```

### 3. For Development with ngrok
If using ngrok, also allow the ngrok domain:
```python
CORS_ALLOWED_ORIGINS = [
    "*",  # Allow all for development only!
]
```

**WARNING:** `"*"` is for development ONLY. Use specific domains for production.

## Testing CORS Configuration

### Test 1: Check CORS headers with curl
```bash
curl -i -X OPTIONS https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/ \
  -H "Origin: http://localhost:5025" \
  -H "Access-Control-Request-Method: GET"
```

Expected response headers:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: authorization, content-type, accept
```

### Test 2: Fetch with authentication
```bash
curl -X GET https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/?status=OPEN \
  -H "Authorization: Token YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

Should return 200 with ticket data.

### Test 3: Test from browser console
```javascript
fetch('https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/?status=OPEN', {
  method: 'GET',
  headers: {
    'Authorization': 'Token YOUR_TOKEN_HERE',
    'Accept': 'application/json',
  }
})
.then(r => r.json())
.then(data => console.log(data))
.catch(err => console.log('CORS Error:', err));
```

## Expected Headers in Response

Your API should return these headers:
```
Access-Control-Allow-Origin: http://localhost:5025
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type, Accept
```

## Endpoints that need CORS

1. `GET /api/tickets/` - Get all tickets
2. `GET /api/tickets/{id}/` - Get ticket detail
3. `PATCH /api/tickets/{id}/` - Update ticket status & upload photo
4. `POST /api/login/` - Login (usually works)

## After Configuration

1. Restart Django development server
2. Test with curl commands above
3. Re-run Flutter app (hot reload)
4. Check console for success messages instead of CORS errors

## Flutter App Error Messages

When CORS is properly configured, you should see:
```
[v0] DEBUG: Successfully loaded 3 tickets
```

Instead of:
```
[v0] ERROR in getTickets: ClientException: Failed to fetch
```

## References

- [django-cors-headers documentation](https://github.com/adamchainz/django-cors-headers)
- [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [ngrok with CORS](https://ngrok.com/docs/http/webhooks/incoming-webhooks/#browser-requests)

---

**Status:** After fixing backend CORS, Flutter app will fetch tickets successfully ✓
