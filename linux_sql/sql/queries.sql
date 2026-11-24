-- Average memory usage percentage for each host over 5-minute intervals
SELECT
    hi.hostname,
    to_timestamp(floor(extract(epoch FROM hu.timestamp) / 300) * 300) AS interval_start,
    AVG(
        (hi.total_mem - hu.memory_free * 1024) * 100.0 / hi.total_mem
    ) AS avg_used_memory_percentage
FROM host_usage hu
JOIN host_info hi ON hu.host_id = hi.id
GROUP BY hi.hostname, interval_start
ORDER BY hi.hostname, interval_start;
