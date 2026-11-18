#!/bin/bash
# Assign command-line arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Validate number of arguments
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

# Collect CPU information
lscpu_out=$(lscpu)

# Hardware information
hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\\(s\\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | sed 's/^[^:]*:[[:space:]]*//')
cpu_mhz=$(echo "$cpu_model" | grep -oE '[0-9]+\.[0-9]+GHz' | sed 's/GHz//' | awk '{print $1 * 1000}')
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}')
total_mem=$(cat /proc/meminfo | grep "^MemTotal:" | awk '{print $2}')
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")

# Display hardware information
echo "hostname=$hostname"
echo "cpu_number=$cpu_number"
echo "cpu_architecture=$cpu_architecture"
echo "cpu_model=$cpu_model"
echo "cpu_mhz=$cpu_mhz"
echo "l2_cache=$l2_cache"
echo "total_mem=$total_mem"
echo "timestamp=$timestamp"

# Check if host already exists in database
export PGPASSWORD=$psql_password

host_id=$(psql -h "$psql_host" -p "$psql_port" -U "$psql_user" -d "$db_name" -t -A \
-c "SELECT id FROM host_info WHERE hostname='$hostname' LIMIT 1")

# Insert hardware information if host does not exist
if [ -z "$host_id" ]; then
  psql -h "$psql_host" -p "$psql_port" -U "$psql_user" -d "$db_name" -c "
  INSERT INTO host_info (
    hostname, cpu_number, cpu_architecture, cpu_model,
    cpu_mhz, l2_cache, total_mem, timestamp
  )
  VALUES (
    '$hostname', $cpu_number, '$cpu_architecture', '$cpu_model',
    $cpu_mhz, $l2_cache, $total_mem, '$timestamp'
  );"
else
  echo "Host already exists with ID: $host_id"
fi
