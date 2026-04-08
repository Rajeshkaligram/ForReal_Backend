FROM php:8.2-apache

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Laravel application (includes pre-compiled assets)
COPY . .

# Install PHP dependencies
RUN composer install --ignore-platform-reqs --no-interaction --prefer-dist --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# Expose port
EXPOSE 8080

# Start command
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
