# Use a standard PHP-FPM image as a base
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies needed for Laravel & Nginx
# === THE FIX IS IN THIS SECTION ===
RUN apk add --no-cache \
    # For Laravel to connect to PostgreSQL
    postgresql-dev \
    # For Nginx web server and process management
    nginx \
    supervisor \
    # For Composer and Git
    curl \
    git \
    # For common PHP extensions
    libzip-dev \
    zip \
    libpng-dev \
jpeg-dev \
    freetype-dev \
    oniguruma-dev

# Install PHP extensions
# This command will now succeed because postgresql-dev is installed
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring exif pcntl bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Nginx and Supervisor configuration files
COPY .docker/nginx.conf /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisord.conf

# Copy the entrypoint script
COPY .docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy the application code
COPY . .

# Set correct permissions for storage and cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80 to the outside
EXPOSE 80

# Run the entrypoint script as the main command
CMD ["/usr/local/bin/entrypoint.sh"]