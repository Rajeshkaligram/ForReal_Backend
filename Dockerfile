FROM php:8.2-apache

WORKDIR /app

# Install dependencies (including PostgreSQL driver)
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip libpq-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

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

# Copy start script
RUN chmod +x /app/start.sh

# ✅ IMPORTANT: use start.sh
CMD ["/app/start.sh"]