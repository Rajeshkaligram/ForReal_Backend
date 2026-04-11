#!/bin/bash

set -e

if [ -z "${PORT}" ]; then
  export PORT=8080
fi

echo "Using PORT: ${PORT}"

# Configure Nginx to use Railway/Render PORT
sed -i "s/listen 8080;/listen ${PORT};/" /etc/nginx/sites-available/default

# Clear cache (skip if DB not configured)
php artisan config:clear --no-interaction 2>/dev/null || true

# IMPORTANT: Database is already imported to Railway manually.
# We skip the import and migration here to avoid "Table already exists" errors.

# Start Supervisor (which will start Nginx and PHP-FPM)
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf