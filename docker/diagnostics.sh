#!/bin/sh
# Docker Container Diagnostics Script for Wave SaaS CRM
# Run this inside the Coolify terminal to diagnose issues

echo "=== Docker Container Diagnostics ==="
echo ""

echo "1. Checking Supervisor Status..."
supervisorctl status
echo ""

echo "2. Checking if Nginx is listening on port 80..."
netstat -tuln | grep :80 || echo "ERROR: Nginx is NOT listening on port 80"
echo ""

echo "3. Testing internal web server response..."
curl -I http://localhost:80 2>&1
echo ""

echo "4. Checking PHP-FPM process..."
ps aux | grep php-fpm | grep -v grep || echo "ERROR: PHP-FPM not running"
echo ""

echo "5. Checking Nginx process..."
ps aux | grep nginx | grep -v grep || echo "ERROR: Nginx not running"
echo ""

echo "6. Checking Nginx error logs (last 20 lines)..."
tail -n 20 /var/log/nginx/error.log 2>/dev/null || echo "No Nginx error log found"
echo ""

echo "7. Checking PHP-FPM error logs (last 20 lines)..."
tail -n 20 /var/log/php-fpm.err.log 2>/dev/null || echo "No PHP-FPM error log found"
echo ""

echo "8. Checking Laravel logs (last 20 lines)..."
tail -n 20 /var/www/html/storage/logs/laravel.log 2>/dev/null || echo "No Laravel log found yet"
echo ""

echo "9. Checking file permissions..."
ls -ld /var/www/html/storage /var/www/html/bootstrap/cache
echo ""

echo "10. Checking if .env file exists..."
if [ -f /var/www/html/.env ]; then
    echo ".env file exists"
    echo "APP_ENV: $(grep APP_ENV /var/www/html/.env)"
    echo "APP_DEBUG: $(grep APP_DEBUG /var/www/html/.env)"
    echo "APP_URL: $(grep APP_URL /var/www/html/.env)"
else
    echo "ERROR: .env file NOT found!"
fi
echo ""

echo "11. Testing PHP configuration..."
php -v
php -m | grep -E '(pdo_mysql|pdo_pgsql|intl|gd|zip)' || echo "WARNING: Some PHP extensions may be missing"
echo ""

echo "=== Diagnostics Complete ==="
