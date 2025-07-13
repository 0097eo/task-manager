#!/usr/bin/env sh

# Exit on error
set -o errexit

echo "Running Composer Install..."
composer install --no-dev --no-interaction --optimize-autoloader

echo "Installing NPM dependencies..."
npm install

echo "Building frontend assets..."
npm run build