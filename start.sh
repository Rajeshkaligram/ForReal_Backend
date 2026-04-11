#!/bin/bash

set -e

if [ -z "${PORT}" ]; then
  export PORT=10000
fi

echo "Using PORT: ${PORT}"

# Set the SSL CA path for TiDB Cloud (Standard for Debian/Ubuntu)
# Must be exported before Apache starts so the web process inherits it.
if [ -z "${MYSQL_ATTR_SSL_CA}" ]; then
    export MYSQL_ATTR_SSL_CA="/etc/ssl/certs/ca-certificates.crt"
fi

# Configure Apache to use Render PORT
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Laravel boot cleanup
php artisan optimize:clear --no-interaction 2>/dev/null || true
php artisan config:clear --no-interaction 2>/dev/null || true
php artisan route:clear --no-interaction 2>/dev/null || true
php artisan cache:clear --no-interaction 2>/dev/null || true

# Start Apache in the background so Render sees the port is open immediately
apache2-foreground &

# Run migrations and Passport setup
if [ -n "${DB_HOST}" ] && [ "${DB_HOST}" != "mysql.railway.internal" ]; then
    echo "Running database migrations..."
    php artisan migrate --force || true

    echo "Generating Passport keys..."
    php artisan passport:keys --force || true

    echo "Ensuring Personal Access Client exists..."
    php artisan passport:client --personal --name="ForReal Personal Access Client" --no-interaction || true
fi

php artisan config:cache --no-interaction 2>/dev/null || true

# Ensure permissions are correct
mkdir -p storage/framework/{sessions,views,cache}
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Keep the script alive
wait
