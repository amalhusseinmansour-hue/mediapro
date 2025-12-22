#!/bin/bash
# PWA Testing Script

echo "🧪 PWA Testing Script"
echo "===================="
echo ""

# Check if server is running
echo "📡 Checking server..."
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000

if [ $? -eq 0 ]; then
    echo "✅ Server is running"
else
    echo "❌ Server is not running"
    echo "Start server with: flutter run -d web"
    exit 1
fi

echo ""
echo "📋 Testing PWA Requirements..."
echo ""

# Test manifest.json
echo "1️⃣  Testing manifest.json..."
manifest=$(curl -s http://localhost:3000/manifest.json)
if echo "$manifest" | grep -q "name"; then
    echo "   ✅ manifest.json is served correctly"
    echo "   $manifest" | head -c 100
    echo "   ..."
else
    echo "   ❌ manifest.json not found or invalid"
fi

echo ""

# Test Service Worker
echo "2️⃣  Testing Service Worker (sw.js)..."
sw=$(curl -s http://localhost:3000/sw.js)
if echo "$sw" | grep -q "Service Worker"; then
    echo "   ✅ sw.js is served correctly"
    echo "   File size: $(echo "$sw" | wc -c) bytes"
else
    echo "   ❌ sw.js not found or invalid"
fi

echo ""

# Test icons
echo "3️⃣  Testing App Icons..."
for size in 192 512; do
    status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/icons/Icon-${size}.png)
    if [ "$status" = "200" ]; then
        echo "   ✅ Icon-${size}.png (HTTP $status)"
    else
        echo "   ⚠️  Icon-${size}.png (HTTP $status)"
    fi
done

echo ""

# Test index.html
echo "4️⃣  Testing index.html..."
html=$(curl -s http://localhost:3000/)
if echo "$html" | grep -q "manifest.json"; then
    echo "   ✅ manifest link found in index.html"
fi
if echo "$html" | grep -q "theme-color"; then
    echo "   ✅ theme-color meta tag found"
fi
if echo "$html" | grep -q "pwa-setup.js"; then
    echo "   ✅ pwa-setup.js included"
fi

echo ""
echo "📊 PWA Audit using Lighthouse..."
echo ""

# Install and run Lighthouse if available
if command -v lighthouse &> /dev/null; then
    echo "🔍 Running Lighthouse audit..."
    lighthouse http://localhost:3000 --view --output json > pwa-audit-results.json
    echo "✅ Lighthouse results saved to pwa-audit-results.json"
else
    echo "ℹ️  Lighthouse not installed"
    echo "Install with: npm install -g lighthouse"
    echo "Then run: lighthouse http://localhost:3000"
fi

echo ""
echo "✅ PWA Testing Complete!"
echo ""
echo "📱 Manual Tests to Perform:"
echo "  1. Open app in Chrome/Edge"
echo "  2. Wait for install prompt"
echo "  3. Click 'Install App' button"
echo "  4. Check if app appears on home screen"
echo "  5. Open Developer Tools (F12)"
echo "  6. Go to Application > Service Workers"
echo "  7. Go to Application > Storage to check cache"
echo "  8. Test offline mode (Network > Offline)"
echo "  9. Refresh page and verify it still works"
echo ""
