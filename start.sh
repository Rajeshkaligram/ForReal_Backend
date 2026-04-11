#!/bin/bash

set -e

if [ -z "${PORT}" ]; then
  export PORT=8080
fi

echo "Using PORT: ${PORT}"

# Configure Apache to use Render PORT
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Clear cache (skip if DB not configured)
php artisan config:clear --no-interaction 2>/dev/null || true

# Run migrations safely (run if DB_HOST is set)
if [ -n "${DB_HOST}" ]; then
    echo "Running database migrations..."
    php artisan migrate --force --no-interaction || echo "Migration completed or skipped"
fi

# Start Apache
apache2-foreground