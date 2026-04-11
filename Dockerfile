FROM php:8.2-apache

WORKDIR /app

# Install dependencies (including MySQL client)
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip libpq-dev default-mysql-client \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Disable mpm_event and enable mpm_prefork (fixes "More than one MPM loaded")
RUN a2dismod mpm_event || true && a2enmod mpm_prefork

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
    && chmod -R 755 /app/public

# ✅ REMOVE MPM LINES (IMPORTANT)
# ❌ DO NOT TOUCH MPM

# Enable required Apache modules
RUN a2enmod rewrite headers

# Set Laravel public folder with proper Apache 2.4 configuration
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Copy start script and import script
RUN chmod +x /app/start.sh /app/import-db.sh

# ✅ IMPORTANT: use start.sh
CMD ["/app/start.sh"]