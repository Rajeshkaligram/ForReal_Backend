#!/bin/bash

set -e

if [ -z "${PORT}" ]; then
  export PORT=8080
fi

echo "Using PORT: ${PORT}"

# Configure Apache to use Railway/Render PORT
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Clear cache (skip if DB not configured)
php artisan config:clear --no-interaction 2>/dev/null || true

# IMPORTANT: Database is already imported to Railway manually.
# We skip the import and migration here to avoid "Table already exists" errors.

# Start Apache
apache2-foreground