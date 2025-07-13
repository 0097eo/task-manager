#!/bin/sh

# Exit on any error
set -e

# Clear any cached configuration from the build stage.
echo "Clearing config cache..."
php artisan config:clear

# Run database migrations
echo "Running migrations..."
php artisan migrate --force

# Start the main services (PHP-FPM and Nginx) using Supervisor
echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisord.conf