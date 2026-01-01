#!/bin/bash

echo "🚀 Wave SaaS CRM - Deployment Script"
echo "====================================="
echo ""

# Check if GitHub URL is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide your GitHub repository URL"
    echo ""
    echo "Usage: ./deploy.sh https://github.com/YOUR_USERNAME/wave-saas-crm.git"
    echo ""
    echo "Steps to create GitHub repository:"
    echo "1. Go to https://github.com/new"
    echo "2. Name: wave-saas-crm"
    echo "3. Set to Private"
    echo "4. Click 'Create repository'"
    echo "5. Copy the repository URL and run this script again"
    exit 1
fi

REPO_URL=$1

echo "📦 Adding Git remote..."
git remote add origin $REPO_URL 2>/dev/null || git remote set-url origin $REPO_URL

echo "✅ Checking Git status..."
git status

echo ""
echo "📝 Committing changes..."
git commit -m "Initial commit - Wave SaaS CRM with Docker for Coolify" 2>/dev/null || echo "Already committed"

echo ""
echo "🌐 Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Successfully pushed to GitHub!"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Go to your Coolify dashboard: http://72.62.130.146:8000"
echo "2. Create new project → Select Git Repository"
echo "3. Repository: $REPO_URL"
echo "4. Branch: main"
echo "5. Build Pack: Dockerfile"
echo "6. Add MySQL database and Redis"
echo "7. Set environment variables (see QUICK_START.md)"
echo "8. Click Deploy!"
echo ""
echo "📖 Full guide: COOLIFY_DEPLOYMENT.md"
