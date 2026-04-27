#!/bin/bash

# CORS Configuration Commands for Django Backend
# Run these commands in your Django project directory

echo "=== Django CORS Configuration ==="
echo ""

# Step 1: Install django-cors-headers
echo "Step 1: Installing django-cors-headers..."
pip install django-cors-headers

echo ""
echo "Step 2: Update your settings.py with:"
echo ""
echo "--- Add to INSTALLED_APPS ---"
cat << 'EOF'
INSTALLED_APPS = [
    'corsheaders',  # Add this line
    'rest_framework',
    'django.contrib.admin',
    # ... rest of your apps
]
EOF

echo ""
echo "--- Add to MIDDLEWARE (FIRST position) ---"
cat << 'EOF'
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Add this FIRST
    'django.middleware.common.CommonMiddleware',
    'django.middleware.security.SecurityMiddleware',
    # ... rest of middleware
]
EOF

echo ""
echo "--- Add at bottom of settings.py ---"
cat << 'EOF'
# CORS Configuration for Flutter Web App
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5025",
    "http://localhost:3000",
    "http://127.0.0.1:5025",
    "http://127.0.0.1:3000",
    "https://upstate-unbaked-peso.ngrok-free.dev",  # Replace with your ngrok URL
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
EOF

echo ""
echo "Step 3: Restart Django server"
echo "$ Ctrl+C  # Stop current server"
echo "$ python manage.py runserver"

echo ""
echo "=== Testing Commands ==="
echo ""

echo "Test 1: Check CORS headers (OPTIONS request)"
echo "$ curl -i -X OPTIONS http://localhost:8000/api/tickets/ \\"
echo "  -H 'Origin: http://localhost:5025' \\"
echo "  -H 'Access-Control-Request-Method: GET'"

echo ""
echo "Test 2: Fetch tickets with authentication"
echo "$ curl -X GET http://localhost:8000/api/tickets/?status=OPEN \\"
echo "  -H 'Authorization: Token YOUR_TOKEN_HERE' \\"
echo "  -H 'Accept: application/json'"

echo ""
echo "Test 3: Test with ngrok (if using ngrok)"
echo "$ curl -X GET https://YOUR_NGROK_URL/api/tickets/?status=OPEN \\"
echo "  -H 'Authorization: Token YOUR_TOKEN_HERE' \\"
echo "  -H 'Accept: application/json'"

echo ""
echo "=== Expected Response Headers ==="
cat << 'EOF'
Access-Control-Allow-Origin: http://localhost:5025
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: authorization, content-type, accept
Access-Control-Allow-Credentials: true
EOF

echo ""
echo "=== After Configuration ==="
echo "1. Django is restarted"
echo "2. CORS headers are present in responses"
echo "3. Flutter app will show task list"
echo "4. Error will change from:"
echo "   [v0] ERROR in getTickets: ClientException: Failed to fetch"
echo "   to:"
echo "   [v0] DEBUG: Successfully loaded X tickets"

echo ""
echo "Done! Notify frontend team that CORS is configured."
