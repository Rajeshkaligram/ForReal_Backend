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

# Clear cache (skip if DB not configured)
php artisan config:clear --no-interaction 2>/dev/null || true

# Start Apache in the background so Render sees the port is open immediately
apache2-foreground &

# Run migrations and setup
if [ -n "${DB_HOST}" ] && [ "${DB_HOST}" != "mysql.railway.internal" ]; then
    echo "Running migrations..."
    php artisan migrate --force || true
    # Initialize Passport keys for API login.
    # SQL dump import is intentionally NOT done during app boot because
    # large dumps are unreliable via tinker/DB::unprepared and can crash startup.
    echo "Initializing Passport keys..."
    php artisan passport:install --force || true
fi

# Ensure permissions are correct
mkdir -p storage/framework/{sessions,views,cache}
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Keep the script alive
wait
