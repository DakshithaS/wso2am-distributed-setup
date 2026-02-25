#!/bin/bash

# Script to update TOML files with database configuration from .env
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TOML_DIR="$BASE_DIR/conf/toml"

# Load environment variables from .env file in root directory
if [[ -f "$BASE_DIR/.env" ]]; then
    echo "Loading database configuration from .env file..."
    source "$BASE_DIR/.env"
else
    echo "Error: .env file not found in root directory!"
    exit 1
fi

# Function to update database configuration in TOML files
update_toml_db_config() {
    local toml_file=$1
    local db_type=$2  # 'apim', 'shared', or 'both'
    
    if [[ ! -f "$toml_file" ]]; then
        echo "Warning: $toml_file not found, skipping..."
        return
    fi
    
    echo "Updating database config in $(basename "$toml_file")..."
    
    # Create a temporary file
    local temp_file=$(mktemp)
    
    # Update APIM database configuration if needed
    if [[ "$db_type" == "apim" || "$db_type" == "both" ]]; then
        # Update APIM database URL, username, and password
        awk -v port="$MYSQL_PORT" -v dbname="$APIM_DB_NAME" -v user="$APIM_DB_USER" -v pass="$APIM_DB_PASSWORD" '
        /^\[database\.apim_db\]/ { in_apim_db = 1 }
        /^\[/ && !/^\[database\.apim_db\]/ { in_apim_db = 0 }
        in_apim_db && /^url = / { 
            gsub(/127\.0\.0\.1:[0-9]+\/[^?]*/, "127.0.0.1:" port "/" dbname)
            gsub(/localhost:[0-9]+\/[^?]*/, "localhost:" port "/" dbname)
            gsub(/WSO2AM_DB/, dbname)
        }
        in_apim_db && /^username = / { $0 = "username = \"" user "\"" }
        in_apim_db && /^password = / { $0 = "password = \"" pass "\"" }
        { print }
        ' "$toml_file" > "$temp_file"
        mv "$temp_file" "$toml_file"
    fi
    
    # Update Shared database configuration
    if [[ "$db_type" == "shared" || "$db_type" == "both" ]]; then
        # Update Shared database URL, username, and password
        awk -v port="$MYSQL_PORT" -v dbname="$SHARED_DB_NAME" -v user="$SHARED_DB_USER" -v pass="$SHARED_DB_PASSWORD" '
        /^\[database\.shared_db\]/ { in_shared_db = 1 }
        /^\[/ && !/^\[database\.shared_db\]/ { in_shared_db = 0 }
        in_shared_db && /^url = / { 
            gsub(/127\.0\.0\.1:[0-9]+\/[^?]*/, "127.0.0.1:" port "/" dbname)
            gsub(/localhost:[0-9]+\/[^?]*/, "localhost:" port "/" dbname)
            gsub(/WSO2AM_SHARED_DB/, dbname)
        }
        in_shared_db && /^username = / { $0 = "username = \"" user "\"" }
        in_shared_db && /^password = / { $0 = "password = \"" pass "\"" }
        { print }
        ' "$toml_file" > "$temp_file"
        mv "$temp_file" "$toml_file"
    fi
    
    rm -f "$temp_file"
}

echo "Updating TOML files with database configuration..."
echo "MySQL Port: $MYSQL_PORT"
echo "APIM DB: $APIM_DB_NAME (user: $APIM_DB_USER)"
echo "Shared DB: $SHARED_DB_NAME (user: $SHARED_DB_USER)"
echo ""

# Update each TOML file with appropriate database configurations
update_toml_db_config "$TOML_DIR/cp_deployment.toml" "both"
update_toml_db_config "$TOML_DIR/tm_deployment.toml" "both"
update_toml_db_config "$TOML_DIR/gw_deployment.toml" "shared"

echo ""
echo "Database configuration update completed!"
echo ""
echo "Updated files:"
for toml_file in "$TOML_DIR"/*.toml; do
    if [[ -f "$toml_file.bak" ]]; then
        echo "  ✓ $(basename "$toml_file") (backup: $(basename "$toml_file").bak)"
    fi
done

echo ""
echo "To verify changes, you can check the database sections in the TOML files:"
echo "grep -A 5 '\[database\.' $TOML_DIR/*.toml"
