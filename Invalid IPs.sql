WITH InvalidIPs AS (
    SELECT ip
    FROM logs
    WHERE 
        -- Check for invalid IP with less or more than 4 octets
        LENGTH(ip) - LENGTH(REPLACE(ip, '.', '')) != 3
        
        OR 
        
        -- Check for octets greater than 255
        CAST(SUBSTRING_INDEX(ip, '.', 1) AS UNSIGNED) > 255
        OR CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 2), '.', -1) AS UNSIGNED) > 255
        OR CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 3), '.', -1) AS UNSIGNED) > 255
        OR CAST(SUBSTRING_INDEX(ip, '.', -1) AS UNSIGNED) > 255
        
        OR
        
        -- Check for leading zeros in any octet
        -- Check for leading zeros in the first octet
        (SUBSTRING_INDEX(ip, '.', 1) REGEXP '^0[0-9]+$' )
        OR
        -- Check for leading zeros in the second octet
        (SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 2), '.', -1) REGEXP '^0[0-9]+$')
        OR
        -- Check for leading zeros in the third octet
        (SUBSTRING_INDEX(SUBSTRING_INDEX(ip, '.', 3), '.', -1) REGEXP '^0[0-9]+$')
        OR
        -- Check for leading zeros in the fourth octet
        (SUBSTRING_INDEX(ip, '.', -1) REGEXP '^0[0-9]+$')
)
SELECT ip, COUNT(*) AS invalid_count
FROM InvalidIPs
GROUP BY ip
ORDER BY invalid_count DESC, ip DESC;
