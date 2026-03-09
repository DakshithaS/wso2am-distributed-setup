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

## Monitoring Commands
```bash
# Monitor keys in real-time (press Ctrl+C to stop)
docker exec wso2am-redis redis-cli --raw monitor | grep throttler

# Get all throttle keys with values
docker exec wso2am-redis redis-cli --raw keys 'wso2_throttler:*' | xargs -I {} sh -c 'echo "{}: $(docker exec wso2am-redis redis-cli get "{}")"'
```</content>
<parameter name="filePath">/Users/dakshithas/Downloads/Patches/throttle/wso2am-distributed-setup/distributed-throttling-test.md