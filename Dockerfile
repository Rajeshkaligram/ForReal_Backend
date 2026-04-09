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

# Configure Apache
RUN a2dismod mpm_event && a2enmod mpm_prefork
RUN a2enmod rewrite
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/app\/public/g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/<Directory \/var\/www\/>/<Directory \/app\/public>/g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/sites-available/000-default.conf

RUN chmod +x /app/start.sh

# Expose port
EXPOSE 3000

# Set environment
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2

# Start Apache
CMD ["apache2-foreground"]
