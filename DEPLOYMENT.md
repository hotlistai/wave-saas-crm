# Deployment & Troubleshooting Guide

## Overview

This Wave SaaS CRM application is containerized using Docker and designed to run on Coolify. The container uses Supervisor to manage multiple processes:

- **Nginx** - Web server (port 80)
- **PHP-FPM** - PHP processor
- **Queue Workers** - Laravel queue processing (2 workers)
- **Scheduler** - Laravel task scheduler

## Recent Fixes

### What Was Fixed

1. **Nginx PID File Location** - Changed from `/run/nginx.pid` to `/var/run/nginx.pid` for better compatibility
2. **Process Startup Priority** - Added priority settings to ensure PHP-FPM starts before Nginx
3. **Startup Delays** - Added `startsecs=5` for Nginx to give it time to bind to port 80
4. **Directory Permissions** - Ensured all required directories exist with proper permissions
5. **Startup Script** - Created a dedicated startup script for proper initialization

### Why Was It Failing?

The "No Available Server" error occurred because:

1. **Health Check Timing** - Coolify's health check was running before Nginx had time to fully start
2. **Startup Race Condition** - Nginx was trying to start at the same time as PHP-FPM
3. **Missing Directories** - Some log and PID directories didn't exist on first run

## Deployment Instructions

### 1. Build and Deploy

In Coolify, trigger a new deployment. The build process will:

1. Build the Docker image with all fixes
2. Install PHP and Node dependencies
3. Build frontend assets
4. Set up Supervisor configuration
5. Start all services via the startup script

### 2. Wait for Startup (60-90 seconds)

The container needs time to:
- Initialize all directories
- Start PHP-FPM
- Start Nginx (waits 5 seconds for PHP-FPM)
- Start queue workers and scheduler

### 3. Verify Deployment

Visit your site at `https://clients.hotlistai.com` in a private/incognito window.

## Troubleshooting

### Running Diagnostics

If you see "No Available Server" after 2 minutes:

1. **Open Coolify Terminal** - Click the Terminal tab for your application
2. **Run the diagnostic script**:
   ```bash
   sh /var/www/html/docker/diagnostics.sh
   ```

This will check:
- Supervisor status
- Nginx listening on port 80
- PHP-FPM process
- Error logs
- File permissions
- Environment configuration
- PHP extensions

### Manual Checks

#### Check Container Status
```bash
docker ps
```
Look for your container ID and ensure status shows "Up".

#### Check Internal Web Server
```bash
curl -I http://localhost:80
```
Should return HTTP 200 or 302 response.

#### Check Supervisor Status
```bash
supervisorctl status
```
All processes should show `RUNNING`.

#### View Real-Time Logs

**Nginx Errors:**
```bash
tail -f /var/log/nginx/error.log
```

**PHP-FPM Errors:**
```bash
tail -f /var/log/php-fpm.err.log
```

**Laravel Application Logs:**
```bash
tail -f /var/www/html/storage/logs/laravel.log
```

**Supervisor Logs:**
```bash
tail -f /var/log/supervisor/supervisord.log
```

#### Restart Services

If a service is stuck:

```bash
# Restart all services
supervisorctl restart all

# Restart specific service
supervisorctl restart nginx
supervisorctl restart php-fpm
supervisorctl restart queue-worker:*
```

### Common Issues

#### 502 Bad Gateway
**Cause:** PHP-FPM not responding
**Fix:**
```bash
supervisorctl restart php-fpm
supervisorctl restart nginx
```

#### 403 Forbidden
**Cause:** File permissions
**Fix:**
```bash
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache
```

#### Blank Page / 500 Error
**Cause:** Laravel configuration issue
**Check:**
```bash
# Verify .env file exists
cat /var/www/html/.env

# Check Laravel logs
tail -n 50 /var/www/html/storage/logs/laravel.log

# Clear and rebuild cache
cd /var/www/html
php artisan config:clear
php artisan cache:clear
php artisan view:clear
```

#### Queue Jobs Not Processing
**Cause:** Queue worker crashed
**Fix:**
```bash
supervisorctl restart queue-worker:*
```

## Environment Variables

Ensure these are set in Coolify:

### Required
- `APP_KEY` - Laravel application key
- `APP_URL` - Your application URL (e.g., https://clients.hotlistai.com)
- `DB_*` - Database connection settings
- `MAIL_*` - Email configuration

### Optional
- `APP_DEBUG=false` - Disable debug mode in production
- `APP_ENV=production` - Set environment to production
- `LOG_CHANNEL=stack` - Logging configuration

## Health Check Configuration

**Recommended Coolify Health Check Settings:**

- **Type:** HTTP
- **Path:** `/`
- **Port:** `80`
- **Interval:** `30s`
- **Timeout:** `10s`
- **Start Period:** `90s` ← Important! Gives container time to start
- **Retries:** `3`

Or disable health checks if issues persist.

## Performance Tuning

### PHP-FPM
Edit `docker/supervisord.conf` to adjust PHP-FPM workers if needed.

### Queue Workers
Currently configured with 2 workers. Adjust in `docker/supervisord.conf`:
```ini
numprocs=2  # Increase for more concurrent job processing
```

### Nginx
Currently configured for optimal small-to-medium traffic. Adjust in `docker/nginx.conf`:
```nginx
worker_connections 1024;  # Increase for high traffic
```

## Support

If issues persist after following this guide:

1. Collect diagnostic output: `sh /var/www/html/docker/diagnostics.sh > diagnostics.txt`
2. Export all relevant logs
3. Check Coolify deployment logs
4. Verify environment variables are set correctly

## Files Modified

- `Dockerfile` - Main container configuration
- `docker/nginx.conf` - Nginx web server configuration
- `docker/supervisord.conf` - Process management configuration
- `docker/startup.sh` - Container startup script (new)
- `docker/diagnostics.sh` - Troubleshooting script (new)
