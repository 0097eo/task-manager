#!/usr/bin/env bash

# Exit on error
set -o errexit

# Install PHP dependencies
composer install --no-dev --no-interaction --optimize-autoloader

# Install a specific version of Node.js and npm
# Render's default Node can be old. This ensures we have a modern version.
source /opt/render/etc/profile.d/nvm.sh
nvm install 18
nvm use 18

# Install frontend dependencies and build assets
npm install
npm run build