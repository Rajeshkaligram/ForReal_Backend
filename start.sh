#!/bin/bash

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
