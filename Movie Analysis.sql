(SELECT name results
FROM users u
JOIN MovieRating mr
ON u.user_id = mr.user_id
GROUP BY 1
ORDER BY count(rating) desc, 1 asc
Limit 1)

UNION All

(SELECT title results
FROM movies m
JOIN MovieRating mr
ON m.movie_id = mr.movie_id
WHERE month(created_at) = 2 and year(created_at)=2020
GROUP BY 1
ORDER BY avg(rating) desc, 1 asc
Limit 1)