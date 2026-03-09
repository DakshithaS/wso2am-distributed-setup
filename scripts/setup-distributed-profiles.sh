#!/bin/bash

# WSO2 API Manager distributed profiles setup script
# Requires extracted and updated WSO2 APIM pack in root directory
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Validate WSO2AM extracted directory exists
echo "🔍 Validating WSO2 APIM installation..."

SOURCE_DIR=""
for dir in "$BASE_DIR"/wso2am-4.*; do
    if [ -d "$dir" ] && [ -f "$dir/bin/api-manager.sh" ]; then
        SOURCE_DIR="$dir"
        echo "✅ Found WSO2 APIM at: $(basename "$dir")"
        break
    fi
done

if [ -z "$SOURCE_DIR" ]; then
    echo "❌ Error: WSO2 API Manager directory not found!"
    echo "Place extracted WSO2 APIM folder (wso2am-4.x.0/) in project root"
    exit 1
fi

COMPONENTS_DIR="$BASE_DIR/components"
PROFILES=("cp" "tm-1" "tm-2" "tm-3" "gw-1" "gw-2")

# Setup MySQL connector
setup_mysql_connector() {
    local target_dir="$1"
    local mysql_source="$BASE_DIR/conf/mysql-connector-j-9.2.0.jar"
    local target_lib_dir="$target_dir/repository/components/lib"
    
    if [ -f "$mysql_source" ]; then
        mkdir -p "$target_lib_dir"
        cp "$mysql_source" "$target_lib_dir/"
        rm -f "$target_dir/repository/components/dropins/mysql"*
        echo "MySQL connector setup complete"
    fi
}

# Main setup
echo "Setting up WSO2 API Manager distributed profiles..."
mkdir -p "$COMPONENTS_DIR"

for i in "${!PROFILES[@]}"; do
    profile="${PROFILES[i]}"
    target_dir="$COMPONENTS_DIR/wso2am-$profile"
    
    echo "Creating profile: $profile"
    
    # Copy source to target
    if [ -d "$target_dir" ]; then
        rm -rf "$target_dir"
    fi
    mkdir -p "$target_dir"
    cp -r "$SOURCE_DIR"/* "$target_dir"/
    
    # Setup MySQL connector
    setup_mysql_connector "$target_dir"
    
    # Configure profile
    cd "$target_dir"
    chmod +x bin/profileSetup.sh
    case "$profile" in
        "cp") sh bin/profileSetup.sh -Dprofile=control-plane ;;
        "tm-1"|"tm-2"|"tm-3") sh bin/profileSetup.sh -Dprofile=traffic-manager ;;
        "gw-1"|"gw-2") sh bin/profileSetup.sh -Dprofile=gateway-worker ;;
    esac
    
    # Replace deployment.toml if custom config exists
    toml_file=""
    case "$profile" in
        "cp") toml_file="cp_deployment.toml" ;;
        "tm-1") toml_file="tm_deployment.toml" ;;
        "tm-2") toml_file="tm-2_deployment.toml" ;;
        "tm-3") toml_file="tm-3_deployment.toml" ;;
        "gw-1") toml_file="gw_deployment.toml" ;;
        "gw-2") toml_file="gw-2_deployment.toml" ;;
    esac
    toml_source="$BASE_DIR/conf/toml/$toml_file"
    if [ -f "$toml_source" ]; then
        cp "$toml_source" "$target_dir/repository/conf/deployment.toml"
        echo "Custom deployment.toml applied"
    fi
done

echo "Setup complete! All profiles created in: $COMPONENTS_DIR"
