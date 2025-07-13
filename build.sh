# exit on error
set -o errexit

# Build the frontend assets
npm install
npm run build

# Run database migrations
php artisan migrate --force