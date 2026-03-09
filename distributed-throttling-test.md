# Redis Commands for Distributed Throttling

## Basic Commands
```bash
# Check connectivity
docker exec wso2am-redis redis-cli ping

# List all keys
docker exec wso2am-redis redis-cli keys '*'

# Get throttle count for Bronze tier
docker exec wso2am-redis redis-cli get "wso2_throttler:1:/pizzashack/1.0.0:1.0.0:Bronze::"

# Get total key count
docker exec wso2am-redis redis-cli dbsize

# Clear all keys (reset for testing)
docker exec wso2am-redis redis-cli flushdb
```