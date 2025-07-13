#!/bin/sh

# Exit on any error
set -e

# === THE FIX IS HERE ===
# Use `sed` to dynamically set the listen port in the Nginx config.
# This replaces the placeholder 'listen 80;' with the port Render provides.
sed -i -e 's/listen 80;/listen '\"\$PORT\"';/' /etc/nginx/nginx.conf
# ========================

# Clear any cached configuration from the build stage.
echo "Clearing config cache..."
php artisan config:clear

# Run database migrations
echo "Running migrations..."
php artisan migrate --force

# Start the main services (PHP-FPM and Nginx) using Supervisor
echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisord.conf