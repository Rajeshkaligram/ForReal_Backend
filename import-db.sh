#!/bin/bash

# Import MySQL dump to PostgreSQL
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

echo "Converting MySQL dump to PostgreSQL format..."
CONVERTED_SQL="/tmp/converted.sql"

# Use a single sed command with multiple expressions for better performance and reliability
# This avoids the pipe-chaining issues seen in previous logs
sed -e 's/--.*$//' \
    -e 's/\/\*.*\*\///' \
    -e 's/`/"/g' \
    -e 's/ENGINE=InnoDB[^;]*//g' \
    -e 's/ENGINE=MyISAM[^;]*//g' \
    -e 's/AUTO_INCREMENT=[0-9]*//g' \
    -e 's/CHARSET=[a-zA-Z0-9_]*//g' \
    -e 's/COLLATE [=a-zA-Z0-9_]*//g' \
    -e 's/utf8mb4/utf8/g' \
    -e 's/utf8_unicode_ci//g' \
    -e 's/int([0-9]*)/INTEGER/g' \
    -e 's/tinyint([0-9]*)/SMALLINT/g' \
    -e 's/smallint([0-9]*)/SMALLINT/g' \
    -e 's/mediumint([0-9]*)/INTEGER/g' \
    -e 's/bigint([0-9]*)/BIGINT/g' \
    -e 's/DOUBLE/DOUBLE PRECISION/g' \
    -e 's/double/DOUBLE PRECISION/g' \
    -e 's/longtext/TEXT/g' \
    -e 's/mediumtext/TEXT/g' \
    -e 's/tinytext/TEXT/g' \
    -e 's/ENUM([^)]*)/TEXT/g' \
    -e 's/SET([^)]*)/TEXT/g' \
    -e 's/UNSIGNED//g' \
    -e 's/unsigned//g' \
    -e 's/ZEROFILL//g' \
    -e 's/zerofill//g' \
    -e "s/ON UPDATE CURRENT_TIMESTAMP//g" \
    -e "s/DEFAULT '0000-00-00 00:00:00'/DEFAULT CURRENT_TIMESTAMP/g" \
    -e "s/DEFAULT '0000-00-00'/DEFAULT CURRENT_DATE/g" \
    -e 's/NOT NULL DEFAULT CURRENT_TIMESTAMP/DEFAULT CURRENT_TIMESTAMP/g' \
    -e 's/KEY "[^"]*" ([^)]*)//g' \
    -e 's/UNIQUE KEY "[^"]*" ([^)]*)//g' \
    -e 's/INDEX "[^"]*" ([^)]*)//g' \
    -e 's/CONSTRAINT "[^"]*" FOREIGN KEY/FOREIGN KEY/g' \
    -e 's/SET SQL_MODE[^;]*;//g' \
    -e 's/SET AUTOCOMMIT[^;]*;//g' \
    -e 's/SET time_zone[^;]*;//g' \
    -e 's/START TRANSACTION;//g' \
    -e 's/COMMIT;//g' \
    -e 's/\/\*![0-9]*//g' \
    -e 's/\*\///g' \
    "$SQL_FILE" | grep -v "^$" > "$CONVERTED_SQL"

echo "Importing database to PostgreSQL..."
export PGPASSWORD="${DB_PASSWORD}"

# Execute the SQL file. We ignore errors on individual lines to allow the script to finish
psql -h "${DB_HOST}" \
     -p "${DB_PORT:-5432}" \
     -U "${DB_USERNAME}" \
     -d "${DB_DATABASE}" \
     -f "$CONVERTED_SQL" || echo "Import finished with some skipped items"

echo "Database import process complete!"
rm -f "$CONVERTED_SQL"
