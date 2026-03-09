#!/bin/bash

# Script to check status of WSO2 API Manager distributed profiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
COMPONENTS_DIR="$BASE_DIR/components"

# Profiles and their ports
PROFILES=("tm-1" "tm-2" "tm-3" "cp" "gw-1" "gw-2")
PROFILE_NAMES=("Traffic Manager 1" "Traffic Manager 2" "Traffic Manager 3" "Control Plane" "Gateway Worker 1" "Gateway Worker 2")

# Function to get ports for a profile
get_profile_ports() {
    case $1 in
        "tm-1") echo "9713" ;;
        "tm-2") echo "9714" ;;
        "tm-3") echo "9715" ;;
        "cp") echo "9443" ;;
        "gw-1") echo "8244" ;;
        "gw-2") echo "8248" ;;
        *) echo "" ;;
    esac
}

echo "📊 WSO2 API Manager Distributed Profiles Status"
echo "=============================================="

running_count=0
for i in "${!PROFILES[@]}"; do
    profile="${PROFILES[i]}"
    profile_name="${PROFILE_NAMES[i]}"
    profile_dir="$COMPONENTS_DIR/wso2am-$profile"
    pid_file="$profile_dir/$profile.pid"
    ports=$(get_profile_ports $profile)
    
    echo ""
    echo "🔹 $profile_name:"
    
    # Check PID file
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "   📍 Process: Running (PID: $pid)"
        else
            echo "   📍 Process: Not running (stale PID file)"
        fi
    else
        echo "   📍 Process: No PID file"
    fi
    
    # Check ports
    service_running=false
    for port in $ports; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "   🌐 Port $port: ✅ Active"
            service_running=true
        else
            echo "   🌐 Port $port: ❌ Not listening"
        fi
    done
    
    if [ "$service_running" = true ]; then
        running_count=$((running_count + 1))
    fi
done

echo ""
echo "=============================================="
if [ $running_count -eq 0 ]; then
    echo "🚫 No services are currently running"
    echo ""
    echo "💡 To start services: scripts/start-distributed-profiles.sh"
elif [ $running_count -eq 6 ]; then
    echo "✅ All $running_count services are running"
    echo ""
    echo "🌐 Service URLs:"
    echo "   • Traffic Manager 1: https://localhost:9713/carbon"
    echo "   • Traffic Manager 2: https://localhost:9714/carbon"
    echo "   • Traffic Manager 3: https://localhost:9715/carbon"
    echo "   • Control Plane:     https://localhost:9443/carbon"
    echo "   • Gateway Worker 1:  https://localhost:8244 (HTTPS)"
    echo "   • Gateway Worker 2:  https://localhost:8248 (HTTPS)"
else
    echo "⚠️  $running_count out of 6 services are running"
    echo ""
    echo "💡 To stop services: scripts/stop-distributed-profiles.sh"
    echo "💡 To start services: scripts/start-distributed-profiles.sh"
fi
echo ""
