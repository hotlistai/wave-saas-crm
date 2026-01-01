# Coolify Deployment Guide for Wave SaaS CRM

## Prerequisites
- Coolify server running at: http://72.62.130.146:8000
- Git repository (GitHub, GitLab, or Bitbucket)
- Domain name (optional, for production)

## Step 1: Push Code to Git Repository

1. Create a new repository on GitHub/GitLab/Bitbucket
2. Add the remote and push:

```bash
cd '/Users/macbookpro/Library/CloudStorage/GoogleDrive-info@buywithapple.com/My Drive/Old Downloads-Drive/Saas CRM'
git remote add origin YOUR_GIT_REPO_URL
git branch -M main
git commit -m "Initial commit - Wave SaaS CRM"
git push -u origin main
```

## Step 2: Deploy on Coolify

### Option A: Using Coolify Web Interface

1. Log into Coolify at: http://72.62.130.146:8000
2. Go to **Projects** → **Create New Project**
3. Select **Git Repository** as source
4. Configure the following:
   - **Repository URL**: Your Git repository URL
   - **Branch**: main
   - **Build Pack**: Dockerfile
   - **Server**: hotlist-core (72.62.130.146)

### Option B: Using Coolify CLI (if available)

```bash
coolify deploy \
  --git YOUR_GIT_REPO_URL \
  --branch main \
  --server hotlist-core \
  --dockerfile Dockerfile
```

## Step 3: Environment Variables

In Coolify, add these environment variables:

### Required Variables:
```
APP_NAME=Wave
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Database (use Coolify's database service)
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=wave
DB_USERNAME=wave
DB_PASSWORD=GENERATE_SECURE_PASSWORD

# Generate this key: php artisan key:generate --show
APP_KEY=base64:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Mail Configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_username
MAIL_PASSWORD=your_password
MAIL_FROM_ADDRESS=hello@yourdomain.com
MAIL_FROM_NAME="${APP_NAME}"

# Redis (optional, use Coolify's Redis service)
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

# Session
SESSION_DRIVER=database
SESSION_LIFETIME=9999

# Cache
CACHE_STORE=redis
QUEUE_CONNECTION=redis

# Stripe (for billing)
BILLING_PROVIDER=stripe
STRIPE_PUBLISHABLE_KEY=pk_live_XXXXX
STRIPE_SECRET_KEY=sk_live_XXXXX
STRIPE_WEBHOOK_SECRET=whsec_XXXXX
```

## Step 4: Add Database Service in Coolify

1. In your Coolify project, click **Add Resource**
2. Select **MySQL 8.0**
3. Configure:
   - **Database Name**: wave
   - **Username**: wave
   - **Password**: (generate secure password)
4. Note the internal hostname (usually `mysql`)

## Step 5: Add Redis Service (Optional)

1. Click **Add Resource** again
2. Select **Redis**
3. Keep default settings
4. Note the internal hostname (usually `redis`)

## Step 6: Post-Deployment Commands

After the first deployment, run these commands in Coolify's terminal:

```bash
# Generate application key (if not done)
php artisan key:generate

# Run database migrations
php artisan migrate --force

# Seed initial data
php artisan db:seed --force

# Create storage link
php artisan storage:link

# Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Step 7: Domain Configuration

1. In Coolify, go to your application settings
2. Add your domain under **Domains**
3. Enable **SSL/TLS** for HTTPS
4. Coolify will automatically handle SSL certificates via Let's Encrypt

## File Structure Created

```
Saas CRM/
├── Dockerfile                 # Main Docker configuration
├── docker-compose.yml        # Local development compose file
├── docker/
│   ├── nginx.conf           # Nginx web server config
│   └── supervisord.conf     # Supervisor for managing processes
├── .dockerignore            # Files to exclude from Docker builds
└── COOLIFY_DEPLOYMENT.md    # This file
```

## Important Notes

1. **Database**: The first deployment will fail if you try to run migrations before the database is created. Create the database service first.

2. **Storage**: Make sure to set up persistent volumes in Coolify for:
   - `/var/www/html/storage`
   - `/var/www/html/public/storage`

3. **Queue Workers**: The Docker setup includes queue workers via Supervisor, so no additional configuration needed.

4. **Scheduler**: The cron scheduler is also included in Supervisor configuration.

5. **File Uploads**: For production, consider using S3 or similar for file storage:
   ```
   FILESYSTEM_DISK=s3
   AWS_ACCESS_KEY_ID=your_key
   AWS_SECRET_ACCESS_KEY=your_secret
   AWS_DEFAULT_REGION=us-east-1
   AWS_BUCKET=your_bucket
   ```

## Troubleshooting

### Build Fails
- Check Coolify build logs
- Ensure Dockerfile paths are correct
- Verify all required files are committed to Git

### Application Errors
- Check application logs in Coolify
- Verify all environment variables are set
- Ensure database connection is working

### Permission Issues
- The Docker image sets correct permissions for storage and cache
- If issues persist, check Coolify volume permissions

## Accessing Your Application

After successful deployment:
- Default URL: `https://your-app-name.coolify-domain.com`
- Custom domain: Configure in Coolify settings
- Admin area: `/admin`
- Login: Create admin user via artisan command

## Creating Admin User

Run in Coolify terminal:
```bash
php artisan tinker
```

Then:
```php
$user = App\Models\User::create([
    'name' => 'Admin',
    'email' => 'admin@yourdomain.com',
    'password' => bcrypt('your-secure-password'),
]);
```

## Support

- Wave Documentation: https://devdojo.com/wave/docs
- Coolify Documentation: https://coolify.io/docs
- Server IP: 72.62.130.146
