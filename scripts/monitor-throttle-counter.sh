#!/bin/bash

# Script to monitor Redis throttle counter every 500ms and log to file
# Usage: ./monitor-throttle-counter.sh [log_file_path]

# Default log file location
LOG_FILE="${1:-../logs/throttle-counter-monitor.log}"

# Redis key to monitor
REDIS_KEY="wso2_throttler:1:/pizzashack/1.0.0:1.0.0:Bronze::"

# Docker container name
CONTAINER_NAME="wso2am-redis"

echo "Starting throttle counter monitoring..."
echo "Logging to: $LOG_FILE"
echo "Press Ctrl+C to stop monitoring"
echo "======================================"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to handle script termination
cleanup() {
    echo ""
    echo "Monitoring stopped. Log saved to: $LOG_FILE"
    exit 0
}

# Trap Ctrl+C and call cleanup function
trap cleanup SIGINT

# Initialize log file with header
echo "Timestamp,Counter Value" > "$LOG_FILE"

# Main monitoring loop
while true; do
    # Get current timestamp
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    # Execute Redis command and capture output
    COUNTER_VALUE=$(docker exec $CONTAINER_NAME redis-cli get "$REDIS_KEY" 2>/dev/null)
    
    # Handle case where Redis returns (nil) or command fails
    if [ $? -ne 0 ]; then
        COUNTER_VALUE="ERROR"
    elif [ "$COUNTER_VALUE" = "(nil)" ] || [ -z "$COUNTER_VALUE" ]; then
        COUNTER_VALUE="0"
    fi
    
    # Log to file and display on console
    echo "$TIMESTAMP,$COUNTER_VALUE" >> "$LOG_FILE"
    echo "[$TIMESTAMP] Counter: $COUNTER_VALUE"
    
    # Wait 500ms before next check
    sleep 0.1
done