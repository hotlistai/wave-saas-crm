#!/bin/sh
set -e

echo "Starting Wave SaaS CRM initialization..."

# Ensure required directories exist with proper permissions
mkdir -p /var/run /var/log/nginx /var/log/supervisor
chmod 777 /var/run

# Ensure Laravel directories are writable
mkdir -p /var/www/html/storage/logs \
         /var/www/html/storage/framework/cache \
         /var/www/html/storage/framework/sessions \
         /var/www/html/storage/framework/views \
         /var/www/html/bootstrap/cache

chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Wait a moment for any filesystem operations to complete
sleep 1

echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
