#!/bin/bash

set -e

if [ -z "${PORT}" ]; then
  export PORT=8080
fi

echo "Using PORT: ${PORT}"

# Configure Apache to use Render PORT
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Clear cache (important)
php artisan config:clear || true
php artisan cache:clear || true

# Run migrations safely (skip if DB not configured)
if [ -n "${DB_HOST}" ] && [ "${DB_HOST}" != "mysql.railway.internal" ]; then
    php artisan migrate --force || true
fi

# Start Apache
apache2-foreground