#!/bin/sh
if [ "$SYNC" = "true" ]; then
    ./redis-shake shake_sync_env.toml
elif [ "$SCAN" = "true" ]; then
    ./redis-shake shake_scan_env.toml
elif [ "$RDB" = "true" ]; then
    ./redis-shake shake_rdb_env.toml
elif [ "$AOF" = "true" ]; then
    ./redis-shake shake_aof_env.toml
else
    echo "Error: Neither SYNC 、 SCAN  、RDB nor  AOF environment variable is set to true"
    exit 1
fi