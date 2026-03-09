#!/bin/bash

# Simple and effective script to force stop WSO2 API Manager distributed profiles
set -e

# Show usage if help requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: $0"
    echo ""
    echo "Force stops all WSO2 API Manager distributed profiles immediately."
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
COMPONENTS_DIR="$BASE_DIR/components"

# Stop profiles in reverse order: gw -> cp -> tm
PROFILES=("gw-2" "gw-1" "cp" "tm-3" "tm-2" "tm-1")
PROFILE_NAMES=("Gateway Worker 2" "Gateway Worker 1" "Control Plane" "Traffic Manager 3" "Traffic Manager 2" "Traffic Manager 1")

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

echo "🛑 Force stopping WSO2 API Manager distributed profiles..."

stopped_count=0
for i in "${!PROFILES[@]}"; do
    profile="${PROFILES[i]}"
    profile_name="${PROFILE_NAMES[i]}"
    profile_dir="$COMPONENTS_DIR/wso2am-$profile"
    pid_file="$profile_dir/$profile.pid"
    
    echo "⏳ Killing $profile_name..."
    
    # Kill using PID file if it exists
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill -9 "$pid" 2>/dev/null || true
            echo "   💀 Killed PID $pid"
        fi
        rm -f "$pid_file"
    fi
    
    # Find and kill all processes by multiple methods
    pids=""
    
    # Search by profile directory pattern
    profile_pids=$(pgrep -f "wso2am-$profile" 2>/dev/null || true)
    if [ -n "$profile_pids" ]; then
        pids="$pids $profile_pids"
    fi
    
    # Search by port usage
    ports=$(get_profile_ports $profile)
    for port in $ports; do
        port_pids=$(lsof -ti :$port 2>/dev/null || true)
        if [ -n "$port_pids" ]; then
            pids="$pids $port_pids"
        fi
    done
    
    # Remove duplicates and kill all
    pids=$(echo $pids | tr ' ' '\n' | sort -u | tr '\n' ' ')
    
    if [ -n "$pids" ]; then
        echo "   � Force killing PIDs: $pids"
        echo "$pids" | xargs kill -9 2>/dev/null || true
        stopped_count=$((stopped_count + 1))
        echo "   ✅ $profile_name processes terminated"
    else
        echo "   ℹ️  No $profile_name processes found"
    fi
done

echo ""
if [ $stopped_count -gt 0 ]; then
    echo "🎯 Terminated $stopped_count profile(s)"
else
    echo "ℹ️  No running profiles found"
fi

# Final cleanup - kill any remaining WSO2 processes
echo ""
echo "🧹 Final cleanup - killing any remaining WSO2 processes..."
remaining_java_pids=$(pgrep -f "org.wso2.carbon.bootstrap.Bootstrap" 2>/dev/null || true)
if [ -n "$remaining_java_pids" ]; then
    echo "� Terminating remaining WSO2 Java processes: $remaining_java_pids"
    echo "$remaining_java_pids" | xargs kill -9 2>/dev/null || true
fi

# Quick final port check
echo ""
echo "🔍 Final verification..."
remaining_found=false
for i in "${!PROFILES[@]}"; do
    profile="${PROFILES[i]}"
    profile_name="${PROFILE_NAMES[i]}"
    ports=$(get_profile_ports $profile)
    
    for port in $ports; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "⚠️  $profile_name still on port $port"
            remaining_found=true
        fi
    done
done

if [ "$remaining_found" = false ]; then
    echo "✅ All WSO2 services terminated successfully"
else
    echo "⚠️  Some processes may still be shutting down - run script again if needed"
fi
