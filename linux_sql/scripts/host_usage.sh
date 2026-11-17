#!/bin/bash

# Collect timestamp
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")

# Collect memory usage
memory_free=$(vmstat --unit M | tail -1 | awk '{print $4}')

# Collect CPU usage
cpu_idle=$(vmstat | tail -1 | awk '{print $15}')
cpu_kernel=$(vmstat | tail -1 | awk '{print $14}')

# Collect disk I/O
disk_io=$(vmstat --unit M -d | tail -1 | awk '{print $10}')

# Collect available disk space
disk_available=$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M//')

# Get hostname and host ID
hostname=$(hostname -f)
host_id=$(psql -h localhost -U postgres -d host_agent -t -A \
-c "SELECT id FROM host_info WHERE hostname='$hostname' LIMIT 1")

# Check if host ID exists
if [ -z "$host_id" ]; then
  echo "Error: Host not found in host_info"
  exit 1
fi

# Display usage information
echo "timestamp=$timestamp"
echo "host_id=$host_id"
echo "memory_free=$memory_free"
echo "cpu_idle=$cpu_idle"
echo "cpu_kernel=$cpu_kernel"
echo "disk_io=$disk_io"
echo "disk_available=$disk_available"

# Insert usage information into database
psql -h localhost -U postgres -d host_agent -c "
INSERT INTO host_usage (
  timestamp, host_id, memory_free, cpu_idle,
  cpu_kernel, disk_io, disk_available
)
VALUES (
  '$timestamp', $host_id, $memory_free, $cpu_idle,
  $cpu_kernel, $disk_io, $disk_available
);"
