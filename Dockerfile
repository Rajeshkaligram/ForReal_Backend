FROM php:8.2-apache

WORKDIR /app

# Install system dependencies and Node.js
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy package files
COPY package*.json ./

# Install npm dependencies
RUN npm install --legacy-peer-deps
RUN npm install sass-loader@^12.1.0 --save-dev --legacy-peer-deps

# Copy Laravel application
COPY . .

# Install PHP dependencies
RUN composer install --ignore-platform-reqs --no-interaction --prefer-dist --optimize-autoloader

# Build assets
RUN npm run prod

# Set permissions
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# Expose port
EXPOSE 8080

# Start command
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
