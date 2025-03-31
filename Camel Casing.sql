WITH RECURSIVE 
words AS (
    SELECT 
        content_id,
        content_text AS original_text,
        TRIM(SUBSTRING_INDEX(content_text, ' ', 1)) AS word,
        SUBSTRING(content_text, LENGTH(SUBSTRING_INDEX(content_text, ' ', 1)) + 2) AS remainder,
        1 AS word_num
    FROM user_content
    
    UNION ALL
    
    SELECT 
        content_id,
        original_text,
        CASE 
            WHEN INSTR(remainder, ' ') > 0 
            THEN TRIM(SUBSTRING_INDEX(remainder, ' ', 1))
            ELSE remainder
        END AS word,
        CASE 
            WHEN INSTR(remainder, ' ') > 0 
            THEN SUBSTRING(remainder, INSTR(remainder, ' ') + 1)
            ELSE ''
        END AS remainder,
        word_num + 1
    FROM words
    WHERE remainder != ''
),
transformed AS (
    SELECT 
        content_id,
        original_text,
        word_num,
        CASE 
            WHEN word LIKE '%-%' THEN 
                CONCAT(
                    UPPER(SUBSTRING(SUBSTRING_INDEX(word, '-', 1), 1, 1)),
                    LOWER(SUBSTRING(SUBSTRING_INDEX(word, '-', 1), 2)),
                    '-',
                    UPPER(SUBSTRING(
                        SUBSTRING(word, LENGTH(SUBSTRING_INDEX(word, '-', 1)) + 2), 
                        1, 1)),
                    LOWER(SUBSTRING(
                        SUBSTRING(word, LENGTH(SUBSTRING_INDEX(word, '-', 1)) + 2), 
                        2))
                )
            ELSE 
                CONCAT(
                    UPPER(SUBSTRING(word, 1, 1)),
                    LOWER(SUBSTRING(word, 2))
                )
        END AS transformed_word
    FROM words
)
SELECT 
    content_id,
    original_text,
    (
        SELECT GROUP_CONCAT(transformed_word ORDER BY word_num SEPARATOR ' ')
        FROM transformed t
        WHERE t.content_id = outer_t.content_id
    ) AS converted_text
FROM transformed outer_t
GROUP BY content_id, original_text
ORDER BY content_id;