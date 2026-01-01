# Quick Start - Deploy to Coolify

Your Wave SaaS CRM is ready to deploy! Here's what to do:

## Current Location
```
/Users/macbookpro/mb-local-sandbox/thedevdojo-wave-fd851d8
```

## Step 1: Create GitHub Repository

1. Go to: https://github.com/new
2. Repository name: `wave-saas-crm`
3. Set to **Private**
4. **Don't** add README, .gitignore, or license
5. Click "Create repository"

You'll get a URL like:
```
https://github.com/YOUR_USERNAME/wave-saas-crm.git
```

## Step 2: Push Code to GitHub

Run these commands in your terminal:

```bash
cd /Users/macbookpro/mb-local-sandbox/thedevdojo-wave-fd851d8

# Add all files
git add .

# Commit
git commit -m "Initial commit - Wave SaaS CRM with Docker"

# Add your GitHub repository URL (replace with your actual URL)
git remote add origin https://github.com/YOUR_USERNAME/wave-saas-crm.git

# Push to GitHub
git push -u origin main
```

## Step 3: Deploy on Coolify

1. **Login to Coolify**: http://72.62.130.146:8000

2. **Create New Project**:
   - Click "Projects" → "Create New Project"
   - Name: Wave SaaS CRM

3. **Add Application**:
   - Source: Git Repository
   - Repository URL: `https://github.com/YOUR_USERNAME/wave-saas-crm.git`
   - Branch: `main`
   - Build Pack: `Dockerfile`
   - Server: `hotlist-core`

4. **Add Database** (MySQL):
   - In your project, click "Add Resource" → "MySQL 8.0"
   - Database: `wave`
   - Username: `wave`
   - Password: (generate secure password)
   - Save the credentials!

5. **Add Redis** (Optional but recommended):
   - Click "Add Resource" → "Redis"
   - Keep defaults

6. **Environment Variables**:
   Click on your app → Environment Variables → Add these:

   ```
   APP_NAME=Wave
   APP_ENV=production
   APP_DEBUG=false
   APP_KEY=base64:GENERATE_THIS_KEY
   APP_URL=https://your-domain.com
   
   DB_CONNECTION=mysql
   DB_HOST=mysql
   DB_PORT=3306
   DB_DATABASE=wave
   DB_USERNAME=wave
   DB_PASSWORD=YOUR_MYSQL_PASSWORD
   
   CACHE_STORE=redis
   QUEUE_CONNECTION=redis
   REDIS_HOST=redis
   
   SESSION_DRIVER=database
   SESSION_LIFETIME=9999
   ```

   To generate APP_KEY, run locally:
   ```bash
   /opt/homebrew/opt/php@8.2/bin/php artisan key:generate --show
   ```

7. **Deploy**:
   - Click "Deploy"
   - Wait for build to complete

8. **Post-Deployment** (run in Coolify terminal):
   ```bash
   php artisan migrate --force
   php artisan db:seed --force
   php artisan storage:link
   ```

## Step 4: Access Your Application

Your app will be available at the Coolify-provided URL or your custom domain.

**Default Login**:
- Email: `admin@admin.com`
- Password: `password`

**Change these immediately after first login!**

## Need Help?

- Full guide: `COOLIFY_DEPLOYMENT.md`
- Wave docs: https://devdojo.com/wave/docs
- Coolify docs: https://coolify.io/docs

## Your Server Info

- **Coolify URL**: http://72.62.130.146:8000
- **Server**: hotlist-core
- **IP**: 72.62.130.146
