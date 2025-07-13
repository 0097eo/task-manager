
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Generate the Ziggy route file
RUN php artisan ziggy:generate

# Build the assets for production
RUN npm run build

# Start from our clean PHP image
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apk add --no-cache \
    postgresql-dev \
    nginx \
    supervisor \
    curl \
    git \
    libzip-dev \
    zip \
    libpng-dev \
    jpeg-dev \
    freetype-dev \
    oniguruma-dev

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring exif pcntl bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Composer files and install PHP dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --optimize-autoloader

# Copy the rest of the application code
COPY . .

# Copy only the compiled assets from the "builder" stage
COPY --from=builder /app/public/build ./public/build

# Copy configs and entrypoint script
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set correct permissions for storage and cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Run our entrypoint script
CMD ["/usr/local/bin/entrypoint.sh"]