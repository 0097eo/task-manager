#!/bin/sh

# Exit on any error
set -e

# Set HTTPS environment variables for Laravel
export FORCE_HTTPS=true
export APP_URL="https://${RENDER_EXTERNAL_HOSTNAME:-localhost}"

# Create a new config file to tell Nginx which port to listen on.
echo "Creating Nginx listen.conf"
echo "listen ${PORT};" > /etc/nginx/listen.conf

# Clear any cached configuration from the build stage.
echo "Clearing config cache..."
php artisan config:clear

# Cache the config for better performance
echo "Caching config..."
php artisan config:cache

# Run database migrations
echo "Running migrations..."
php artisan migrate --force

# Start the main services (PHP-FPM and Nginx) using Supervisor
echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisord.conf