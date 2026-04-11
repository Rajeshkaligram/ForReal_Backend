FROM php:8.2-apache-bullseye

# Force cache invalidation - v4
ARG CACHE_BUST=4

WORKDIR /app

# Install dependencies (including MySQL client)
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip libpq-dev default-mysql-client \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Disable all MPM modules and enable only prefork
RUN a2dismod mpm_event mpm_worker mpm_itk || true \
    && a2enmod mpm_prefork \
    && a2enmod rewrite headers \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy app
COPY . .

# Install PHP deps
RUN composer install --ignore-platform-reqs --no-interaction --prefer-dist --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache \
    && chmod -R 755 /app/public \
    && chmod +x /app/start.sh /app/import-db.sh

# Set Laravel public folder with proper Apache 2.4 configuration
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# ✅ IMPORTANT: use start.sh
CMD ["/app/start.sh"]