# Troubleshooting CORS Error

## Error Message
```
[v0] ERROR in getTickets: ClientException: Failed to fetch, uri=https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/?status=OPEN
```

## What This Means
- Your browser is blocking the request
- Backend did NOT send proper CORS headers
- This happens with cross-origin requests (different domain)

## Quick Fix Checklist

### Step 1: Verify Backend is Running
```bash
# Test login endpoint (this works for you)
curl -X POST https://upstate-unbaked-peso.ngrok-free.dev/api/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "teknik_listrik", "password": "YOUR_PASSWORD"}'
```
✓ Should return 200 with token

### Step 2: Check if CORS Headers Exist
```bash
# This should show CORS headers
curl -i -X OPTIONS https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/
```

Look for:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PATCH, DELETE
Access-Control-Allow-Headers: Authorization, Content-Type
```

If you DON'T see these headers, backend needs CORS configuration.

### Step 3: Install django-cors-headers

In your Django project:
```bash
# 1. Install package
pip install django-cors-headers

# 2. Edit settings.py
# Add 'corsheaders' to INSTALLED_APPS
# Add 'corsheaders.middleware.CorsMiddleware' to MIDDLEWARE (FIRST)

# 3. Add CORS config to settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5025",
    "http://localhost:3000",
    "https://upstate-unbaked-peso.ngrok-free.dev",
]

# 4. Restart Django
python manage.py runserver
```

### Step 4: Verify Fix
```bash
# Test with auth header
curl -X GET https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/?status=OPEN \
  -H "Authorization: Token YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

Should return JSON with ticket list.

### Step 5: Test in Flutter App
1. Hot reload the app
2. Login again
3. Check console - should show:
   ```
   [v0] DEBUG: Successfully loaded X tickets
   ```

## Still Getting Error?

### Check 1: Is ngrok tunnel active?
```bash
# If using ngrok
ngrok http 8000
# Should show your URL like: https://xxxx-xxxx.ngrok-free.dev
```

### Check 2: Is Django accessible?
```bash
# Direct test to Django
curl http://localhost:8000/api/tickets/ \
  -H "Authorization: Token YOUR_TOKEN_HERE"
```
✓ Should work locally

### Check 3: CORS Middleware Order
In `settings.py`, `CorsMiddleware` must be FIRST in MIDDLEWARE list:
```python
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # MUST BE FIRST
    'django.middleware.common.CommonMiddleware',
    ...
]
```

### Check 4: Restart Everything
```bash
# Kill and restart Django
Ctrl+C
python manage.py runserver

# Hot reload Flutter app
Press 'r' in terminal
```

## Browser Console Debugging

1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Try action in Flutter app
4. Look for request to `/api/tickets/`
5. Click on it, check:
   - Status: Should be 200 (not 0 or error)
   - Response headers should have `Access-Control-Allow-Origin`
   - Response tab should show ticket JSON data

## Final Test

If everything is fixed:
```
[v0] DEBUG: fetchAllTicketsForStats called
[v0] DEBUG: Token from storage = EXISTS
[v0] DEBUG: Fetching from URL: https://upstate-unbaked-peso.ngrok-free.dev/api/tickets/?status=OPEN
[v0] DEBUG: Using token: 02dd1a46f3...
[v0] DEBUG: Response status: 200
[v0] DEBUG: Successfully loaded 1 tickets
```

Then app will show tasks in dashboard!

## Contact Backend Team

Send them this message:
> "Flutter web app needs CORS headers. Install django-cors-headers and allow requests from browser origins. See CORS_CONFIGURATION.md for details."

---

**Time to fix:** 5 minutes  
**Files to change:** `settings.py` in Django project  
**Restart needed:** Yes, restart Django server
