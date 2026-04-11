#!/bin/bash

# Import MySQL dump to MySQL
set -e

echo "Starting database import..."

if [ -z "${DB_HOST}" ]; then
    echo "DB_HOST not set, skipping database import"
    exit 0
fi

SQL_FILE="/app/db_rentasuit_php.sql"
if [ ! -f "$SQL_FILE" ]; then
    echo "SQL file not found: $SQL_FILE"
    exit 0
fi

echo "Importing database to MySQL..."
export MYSQL_PWD="${DB_PASSWORD}"

# Execute the SQL file using mysql client
mysql -h "${DB_HOST}" \
     -P "${DB_PORT:-3306}" \
     -u "${DB_USERNAME}" \
     "${DB_DATABASE}" < "$SQL_FILE"

echo "Database import process complete!"
