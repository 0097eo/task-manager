# =================================================================
# STAGE 1: The "Builder"
# =================================================================
FROM php:8.2-fpm-alpine AS builder

WORKDIR /app

# Install all build-time dependencies
RUN apk add --no-cache \
    curl git libzip-dev zip libpng-dev jpeg-dev freetype-dev \
    oniguruma-dev postgresql-dev nodejs npm

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring exif pcntl bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy all application files
COPY . .

# Install dependencies
RUN composer install --no-dev --no-interaction --optimize-autoloader
RUN npm install

# Generate Ziggy routes and build assets
RUN php artisan ziggy:generate
RUN npm run build


# =================================================================
# STAGE 2: The Final Production Image
# =================================================================
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Install runtime dependencies
RUN apk add --no-cache \
    nginx supervisor postgresql-libs libzip libpng jpeg freetype oniguruma

# Install build dependencies, compile extensions, then remove them
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS postgresql-dev libzip-dev libpng-dev jpeg-dev freetype-dev oniguruma-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring exif pcntl bcmath gd \
    && apk del .build-deps

# Copy configs and entrypoint script
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy built application files from the builder stage
COPY --from=builder /app/vendor ./vendor
COPY --from=builder /app/public ./public
COPY --from=builder /app/bootstrap ./bootstrap
COPY --from=builder /app/config ./config
COPY --from=builder /app/database ./database
COPY --from=builder /app/resources ./resources
COPY --from=builder /app/routes ./routes
COPY --from=builder /app/storage ./storage
COPY --from=builder /app/app ./app
COPY --from=builder /app/composer.json ./composer.json
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/artisan ./artisan

# Create dedicated directories for Nginx and PHP-FPM to use for their run files.
RUN mkdir -p /var/run/nginx && chown -R www-data:www-data /var/run/nginx
RUN mkdir -p /var/run/php && chown -R www-data:www-data /var/run/php

# Set permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
# ========================

EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]