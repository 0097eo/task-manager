#!/usr/bin/env sh

# Exit on error
set -o errexit

# Install PHP dependencies
echo "Running Composer Install..."
composer install --no-dev --no-interaction --optimize-autoloader

echo "Installing Node.js..."
source /opt/render/etc/profile.d/nvm.sh
nvm install 18
nvm use 18

echo "Installing NPM dependencies..."
npm install

echo "Building frontend assets..."
npm run build