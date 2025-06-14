#!/bin/bash

# MySQL Database Initialization Script for WSO2 API Manager
# This script runs automatically when the MySQL container starts

set -e

echo "Starting WSO2 API Manager database initialization..."

# Wait for MySQL to be ready
until mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; do
    echo "Waiting for MySQL to be ready..."
    sleep 2
done

echo "MySQL is ready. Creating databases and users..."

# Create databases
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
CREATE DATABASE IF NOT EXISTS WSO2AM_DB CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE DATABASE IF NOT EXISTS WSO2AM_STATS_DB CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE DATABASE IF NOT EXISTS WSO2SHARED_DB CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE DATABASE IF NOT EXISTS WSO2_MB_STORE_DB CHARACTER SET utf8 COLLATE utf8_unicode_ci;
"

# Create users and grant permissions
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
CREATE USER IF NOT EXISTS 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
GRANT ALL PRIVILEGES ON WSO2AM_DB.* TO 'wso2carbon'@'%';
GRANT ALL PRIVILEGES ON WSO2AM_STATS_DB.* TO 'wso2carbon'@'%';
GRANT ALL PRIVILEGES ON WSO2SHARED_DB.* TO 'wso2carbon'@'%';
GRANT ALL PRIVILEGES ON WSO2_MB_STORE_DB.* TO 'wso2carbon'@'%';
FLUSH PRIVILEGES;
"

echo "Databases and users created successfully."

# Initialize API Manager database schema
if [ -f "/home/dbScripts/apimgt/mysql.sql" ]; then
    echo "Initializing WSO2AM_DB schema..."
    mysql -u wso2carbon -pwso2carbon WSO2AM_DB < /home/dbScripts/apimgt/mysql.sql
    echo "WSO2AM_DB schema initialized successfully."
else
    echo "Warning: /home/dbScripts/apimgt/mysql.sql not found. Skipping API Manager schema initialization."
fi

# Initialize shared database schema
if [ -f "/home/dbScripts/mysql.sql" ]; then
    echo "Initializing WSO2SHARED_DB schema..."
    mysql -u wso2carbon -pwso2carbon WSO2SHARED_DB < /home/dbScripts/mysql.sql
    echo "WSO2SHARED_DB schema initialized successfully."
else
    echo "Warning: /home/dbScripts/mysql.sql not found. Skipping shared database schema initialization."
fi

# Initialize message broker database schema
if [ -f "/home/dbScripts/mb-store/mysql.sql" ]; then
    echo "Initializing WSO2_MB_STORE_DB schema..."
    mysql -u wso2carbon -pwso2carbon WSO2_MB_STORE_DB < /home/dbScripts/mb-store/mysql.sql
    echo "WSO2_MB_STORE_DB schema initialized successfully."
else
    echo "Warning: /home/dbScripts/mb-store/mysql.sql not found. Skipping message broker schema initialization."
fi

# Create initialization complete flag
touch /var/lib/mysql/initialization-complete.flag

echo "WSO2 API Manager database initialization completed successfully!"
