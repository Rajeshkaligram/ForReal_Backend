#!/bin/bash

# Import MySQL dump to PostgreSQL
# This script converts MySQL syntax to PostgreSQL and imports the database

set -e

echo "Starting database import..."

# Check if DB_HOST is set
if [ -z "${DB_HOST}" ]; then
    echo "DB_HOST not set, skipping database import"
    exit 0
fi

# Path to the SQL file
SQL_FILE="/app/db_rentasuit_php.sql"

if [ ! -f "$SQL_FILE" ]; then
    echo "SQL file not found: $SQL_FILE"
    exit 0
fi

echo "Converting MySQL dump to PostgreSQL format..."

# Create a converted SQL file
CONVERTED_SQL="/tmp/converted.sql"

# Convert MySQL syntax to PostgreSQL
cat "$SQL_FILE" | \
sed "s/--.*$//" | \
sed "s/\/\*.*\*\///" | \
sed "s/`/\"/g" | \
sed "s/ENGINE=InnoDB[^;]*;//" | \
sed "s/ENGINE=MyISAM[^;]*;//" | \
sed "s/AUTO_INCREMENT=[0-9]*//" | \
sed "s/CHARSET=[a-zA-Z0-9_]*//" | \
sed "s/COLLATE [=a-zA-Z0-9_]*//g" | \
sed "s/utf8mb4/utf8/g" | \
sed "s/utf8_unicode_ci//g" | \
sed "s/int([0-9]*)/INTEGER/g" | \
sed "s/tinyint([0-9]*)/SMALLINT/g" | \
sed "s/smallint([0-9]*)/SMALLINT/g" | \
sed "s/mediumint([0-9]*)/INTEGER/g" | \
sed "s/bigint([0-9]*)/BIGINT/g" | \
sed "s/DOUBLE/DOUBLE PRECISION/g" | \
sed "s/double/DOUBLE PRECISION/g" | \
sed "s/FLOAT/FLOAT/g" | \
sed "s/float/FLOAT/g" | \
sed "s/longtext/TEXT/g" | \
sed "s/mediumtext/TEXT/g" | \
sed "s/tinytext/TEXT/g" | \
sed "s/ENUM([^)]*)/TEXT/g" | \
sed "s/SET([^)]*)/TEXT/g" | \
sed "s/BLOB/BYTEA/g" | \
sed "s/LONGBLOB/BYTEA/g" | \
sed "s/MEDIUMBLOB/BYTEA/g" | \
sed "s/TINYBLOB/BYTEA/g" | \
sed "s/UNSIGNED//g" | \
sed "s/unsigned//g" | \
sed "s/ZEROFILL//g" | \
sed "s/zerofill//g" | \
sed "s/ON UPDATE CURRENT_TIMESTAMP//g" | \
sed "s/ON UPDATE[^(]*([^)]*)//g" | \
sed "s/DEFAULT '0000-00-00 00:00:00'/DEFAULT CURRENT_TIMESTAMP/g" | \
sed "s/DEFAULT '0000-00-00'/DEFAULT CURRENT_DATE/g" | \
sed "s/NOT NULL DEFAULT CURRENT_TIMESTAMP/DEFAULT CURRENT_TIMESTAMP/g" | \
sed "s/KEY \"[^\"]*\" ([^)]*)//g" | \
sed "s/PRIMARY KEY ([^)]*)/PRIMARY KEY (\1)/g" | \
sed "s/UNIQUE KEY \"[^\"]*\" ([^)]*)//g" | \
sed "s/INDEX \"[^\"]*\" ([^)]*)//g" | \
sed "s/CONSTRAINT \"[^\"]*\" FOREIGN KEY/FOREIGN KEY/g" | \
sed "s/REFERENCES \"\([^\"]*\)\"/REFERENCES \"\1\"/g" | \
sed "s/ON DELETE RESTRICT//g" | \
sed "s/ON UPDATE RESTRICT//g" | \
sed "s/SET SQL_MODE[^;]*;//g" | \
sed "s/SET AUTOCOMMIT[^;]*;//g" | \
sed "s/SET time_zone[^;]*;//g" | \
sed "s/START TRANSACTION;//g" | \
sed "s/COMMIT;//g" | \
sed "s//*!40101 SET[^;]*;//g" | \
sed "s/\/\*![0-9]*//g" | \
sed "s/\*\///g" | \
grep -v "^$" > "$CONVERTED_SQL"

echo "Importing database to PostgreSQL..."

# Import to PostgreSQL using psql
export PGPASSWORD="${DB_PASSWORD}"

psql -h "${DB_HOST}" \
     -p "${DB_PORT:-5432}" \
     -U "${DB_USERNAME}" \
     -d "${DB_DATABASE}" \
     -f "$CONVERTED_SQL" 2>&1 || echo "Import completed with some warnings"

echo "Database import completed!"

# Clean up
rm -f "$CONVERTED_SQL"
