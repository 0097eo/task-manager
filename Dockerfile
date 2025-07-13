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

# Install runtime dependencies for PHP and Nginx
# === THE FIX IS HERE: We install -dev, compile, then remove it ===
RUN apk add --no-cache \
    nginx \
    supervisor \
    # We need postgresql-dev to COMPILE the extension
    postgresql-dev \
    # We only need the client libs at RUNTIME
    postgresql-libs \
    # Other runtime libs for extensions
    libzip libpng jpeg freetype oniguruma \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring exif pcntl bcmath gd \
    # Now, remove the -dev packages to keep the image small
    && apk del postgresql-dev

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

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]