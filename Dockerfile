FROM php:8.2-apache

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy app
COPY . .

# Install PHP deps
RUN composer install --ignore-platform-reqs --no-interaction --prefer-dist --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# ✅ REMOVE MPM LINES (IMPORTANT)
# ❌ DO NOT TOUCH MPM

# Enable rewrite
RUN a2enmod rewrite

# Set Laravel public folder
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/app\/public/g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/<Directory \/var\/www\/>/<Directory \/app\/public>/g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/sites-available/000-default.conf

# Copy start script
RUN chmod +x /app/start.sh

# ✅ IMPORTANT: use start.sh
CMD ["/app/start.sh"]