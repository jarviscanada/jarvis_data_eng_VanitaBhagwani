-- Average memory usage percentage for each host over 1-minute intervals
SELECT
    hi.hostname,
    date_trunc('minute', hu.timestamp) AS interval,
    AVG(
        (hi.total_mem - hu.memory_free * 1024) * 100.0 / hi.total_mem
    ) AS avg_used_memory_percentage
FROM host_usage hu
JOIN host_info hi ON hu.host_id = hi.id
GROUP BY hi.hostname, interval
ORDER BY hi.hostname, interval;
