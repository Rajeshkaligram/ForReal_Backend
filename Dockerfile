FROM node:18-alpine AS node

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install npm dependencies
RUN npm install --legacy-peer-deps

# Install additional Laravel Mix dependencies
RUN npm install sass-loader@^12.1.0 --save-dev --legacy-peer-deps

# Copy Laravel application
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
