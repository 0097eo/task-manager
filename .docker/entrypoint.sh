#!/bin/sh

# Exit on any error
set -e

# === DEBUGGING: Print key environment variables to the log ===
echo "--- App Environment ---"
echo "APP_ENV is: $APP_ENV"
echo "DATABASE_URL is: $DATABASE_URL" # This will show if the variable is empty
echo "DB_CONNECTION is: $DB_CONNECTION"
echo "-----------------------"

# Clear all possible caches to be absolutely sure
echo "Clearing all caches..."
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Run database migrations
echo "Running migrations..."
php artisan migrate --force

# Start the main services (PHP-FPM and Nginx) using Supervisor
echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisord.conf