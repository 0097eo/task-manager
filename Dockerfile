# =================================================================
# STAGE 1: The "Builder"
# This stage installs all tools and builds all assets.
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
# This is a clean, lightweight image with only necessary files.
# =================================================================
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Install runtime dependencies for PHP and Nginx
# === THE FIX IS HERE: Add image library -dev packages, then remove them ===
RUN apk add --no-cache \
    nginx \
    supervisor \
    # Dev packages needed to COMPILE extensions
    postgresql-dev \
    libzip-dev \
    oniguruma-dev \
    libpng-dev \
    jpeg-dev \
    freetype-dev \
    # Runtime libraries needed for extensions to RUN
    postgresql-libs \
    libzip libpng jpeg freetype oniguruma \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring exif pcntl bcmath gd \
    # Now, remove all -dev packages to keep the final image small
    && apk del postgresql-dev libzip-dev oniguruma-dev libpng-dev jpeg-dev freetype-dev

# Copy configs and entrypoint script
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy built application files from the builder stage
COPY --from=builder /app/vendor ./vendor
COPY --from=builder /app/public/build ./public/build
COPY --from=builder /app/artisan ./artisan
COPY --from=builder /app/bootstrap ./bootstrap
COPY --from=builder /app/config ./config
COPY --from=builder /app/database ./database
COPY --from=builder /app/public ./public
COPY --from=builder /app/resources ./resources
COPY --from=builder /app/routes ./routes
COPY --from=builder /app/storage ./storage
COPY --from=builder /app/composer.json ./composer.json
COPY --from=builder /app/package.json ./package.json

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]