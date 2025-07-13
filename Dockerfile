# =================================================================
# STAGE 1: The "Builder"
#
# This stage installs all tools (PHP, Composer, Node.js)
# and builds all assets.
# =================================================================
FROM php:8.2-fpm-alpine AS builder

# Set working directory
WORKDIR /app

# Install system dependencies
# This includes PHP dependencies, Node.js, and Git
RUN apk add --no-cache \
    curl \
    git \
    libzip-dev \
    zip \
    libpng-dev \
    jpeg-dev \
    freetype-dev \
    oniguruma-dev \
    postgresql-dev \
    nodejs \
    npm

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring exif pcntl bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy all application files to the builder stage
COPY . .

# Install Composer dependencies
RUN composer install --no-dev --no-interaction --optimize-autoloader

# Install NPM dependencies
RUN npm install

# Generate the Ziggy route file (This will now work because PHP is present)
RUN php artisan ziggy:generate

# Build the frontend assets for production
RUN npm run build


# =================================================================
# STAGE 2: The Final Production Image
#
# This stage is a clean, lightweight image. We copy only the
# necessary files from the "builder" stage into it.
# =================================================================
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install ONLY the necessary runtime dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    # We only need the client libraries, not the -dev packages
    postgresql-libs 

# Install only necessary PHP extensions
RUN docker-php-ext-install pdo pdo_pgsql

# Copy configs and entrypoint script
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisord.conf
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy the vendor directory from the builder stage
COPY --from=builder /app/vendor ./vendor

# Copy the built frontend assets from the builder stage
COPY --from=builder /app/public/build ./public/build

# Copy the rest of the application code
COPY . .

# Set correct permissions for storage and cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Run our entrypoint script
CMD ["/usr/local/bin/entrypoint.sh"]