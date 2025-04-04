CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE result INT;
  
  SET result = (
      SELECT salary FROM (
          SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk 
          FROM Employee
      ) ranked
      WHERE rnk = N
      LIMIT 1
  );

  RETURN result;
END;