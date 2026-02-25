#!/bin/bash

# Simple MySQL database setup for WSO2 API Manager
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables from .env file in root directory
if [[ -f "$BASE_DIR/.env" ]]; then
    source "$BASE_DIR/.env"
else
    echo "Warning: .env file not found in root directory. Using default values."
    MYSQL_PORT="3326"
    MYSQL_ROOT_PASSWORD="my-secret"
    APIM_DB_NAME="apim_db320"
    SHARED_DB_NAME="shared_db320"
    APIM_DB_USER="apimadmin"
    APIM_DB_PASSWORD="apimadmin123"
    SHARED_DB_USER="sharedadmin"
    SHARED_DB_PASSWORD="sharedadmin123"
fi

# Database configuration
MYSQL_HOST="127.0.0.1"

echo "Setting up MySQL databases for WSO2 API Manager..."

# Create databases and users
mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
DROP DATABASE IF EXISTS $APIM_DB_NAME;
DROP DATABASE IF EXISTS $SHARED_DB_NAME;
CREATE DATABASE $APIM_DB_NAME CHARACTER SET latin1;
CREATE DATABASE $SHARED_DB_NAME CHARACTER SET latin1;

DROP USER IF EXISTS '$APIM_DB_USER'@'%';
DROP USER IF EXISTS '$SHARED_DB_USER'@'%';
CREATE USER '$APIM_DB_USER'@'%' IDENTIFIED BY '$APIM_DB_PASSWORD';
CREATE USER '$SHARED_DB_USER'@'%' IDENTIFIED BY '$SHARED_DB_PASSWORD';

GRANT ALL PRIVILEGES ON $APIM_DB_NAME.* TO '$APIM_DB_USER'@'%';
GRANT ALL PRIVILEGES ON $SHARED_DB_NAME.* TO '$SHARED_DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Find WSO2AM installation for DB scripts
SOURCE_DIR=""
for dir in "$BASE_DIR"/wso2am-*; do
    if [ -d "$dir" ] && [ -f "$dir/bin/api-manager.sh" ]; then
        SOURCE_DIR="$dir"
        break
    fi
done

if [ -n "$SOURCE_DIR" ]; then
    echo "Initializing database schemas..."
    
    # Initialize APIM database
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$APIM_DB_USER" -p"$APIM_DB_PASSWORD" "$APIM_DB_NAME" < "$SOURCE_DIR/dbscripts/apimgt/mysql.sql"
    
    # Initialize Shared database
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$SHARED_DB_USER" -p"$SHARED_DB_PASSWORD" "$SHARED_DB_NAME" < "$SOURCE_DIR/dbscripts/mysql.sql"
    
    echo "Database setup complete!"
    echo "APIM DB: $APIM_DB_NAME (user: $APIM_DB_USER)"
    echo "Shared DB: $SHARED_DB_NAME (user: $SHARED_DB_USER)"
else
    echo "Warning: WSO2AM installation not found. Databases created but not initialized."
fi
