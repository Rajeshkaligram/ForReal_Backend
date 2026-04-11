#!/bin/bash

set -e

if [ -z "${PORT}" ]; then
  export PORT=10000
fi

echo "Using PORT: ${PORT}"

# Configure Apache to use Render PORT
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Clear cache (skip if DB not configured)
php artisan config:clear --no-interaction 2>/dev/null || true

# Set the SSL CA path for TiDB Cloud (Standard for Debian/Ubuntu)
if [ -z "${MYSQL_ATTR_SSL_CA}" ]; then
    export MYSQL_ATTR_SSL_CA="/etc/ssl/certs/ca-certificates.crt"
fi

# Run migrations and setup
if [ -n "${DB_HOST}" ] && [ "${DB_HOST}" != "mysql.railway.internal" ]; then
    echo "Running migrations..."
    php artisan migrate --force || true

    # Check for our big SQL import file
    if [ -f "db_rentasuit_php_final.sql" ] || [ -f "db_rentasuit_php_final.sql.bak" ]; then
        if [ -f "db_rentasuit_php_final.sql" ]; then
            echo "Found db_rentasuit_php_final.sql. Starting automatic import..."
            php artisan tinker --execute="DB::unprepared(file_get_contents('db_rentasuit_php_final.sql'));"
            echo "Import complete! Moving file to prevent re-import."
            mv db_rentasuit_php_final.sql db_rentasuit_php_final.sql.bak
        fi
        
        # Initialize Passport for API login
        echo "Initializing Passport keys..."
        php artisan passport:install --force || true
    fi
fi

# Ensure permissions are correct
mkdir -p storage/framework/{sessions,views,cache}
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# Start Apache
apache2-foreground