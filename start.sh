#!/bin/bash

set -e

if [ -z "${PORT}" ]; then
  echo "PORT is not set; defaulting to 8080"
  export PORT=8080
fi

echo "Configuring Apache to listen on port ${PORT}"

# Replace default Apache listen port and vhost port (Railway provides $PORT)
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf || true
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf || true

# Wait for database to be ready
echo "Waiting for database connection..."
until php artisan db:show 2>/dev/null; do
    echo "Database is unavailable - sleeping"
    sleep 2
done

echo "Database is ready - running migrations"
php artisan migrate --force

echo "Starting Apache"
apache2-foreground
