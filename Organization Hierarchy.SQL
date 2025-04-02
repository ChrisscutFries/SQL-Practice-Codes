WITH RECURSIVE EmployeeHierarchy AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        salary,
        1 AS level
    FROM
        Employees
    WHERE
        manager_id IS NULL
    UNION ALL
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.salary,
        eh.level + 1 AS level
    FROM
        Employees e
    JOIN
        EmployeeHierarchy eh ON e.manager_id = eh.employee_id
),
TeamSizeRecursive AS (
    SELECT
        employee_id,
        manager_id,
        employee_id AS root_manager
    FROM
        Employees
    UNION ALL
    SELECT
        e.employee_id,
        e.manager_id,
        tsr.root_manager
    FROM
        Employees e
    JOIN
        TeamSizeRecursive tsr ON e.manager_id = tsr.employee_id
),
TeamSize AS (
    SELECT
        root_manager AS manager_id,
        COUNT(DISTINCT employee_id) - 1 AS team_size
    FROM
        TeamSizeRecursive
    WHERE root_manager IS NOT NULL
    GROUP BY root_manager
),
Budget AS (
    WITH RECURSIVE BudgetRecursive AS (
        SELECT
            employee_id,
            salary,
            employee_id AS root_manager
        FROM
            Employees
        UNION ALL
        SELECT
            e.employee_id,
            e.salary,
            br.root_manager
        FROM
            Employees e
        JOIN
            BudgetRecursive br ON e.manager_id = br.employee_id
    )
    SELECT
        root_manager AS manager_id,
        SUM(salary) AS budget
    FROM
        BudgetRecursive
    GROUP BY root_manager
)
SELECT
    eh.employee_id,
    eh.employee_name,
    eh.level,
    COALESCE(ts.team_size, 0) AS team_size,
    b.budget
FROM
    EmployeeHierarchy eh
LEFT JOIN
    TeamSize ts ON eh.employee_id = ts.manager_id
LEFT JOIN
    Budget b ON eh.employee_id = b.manager_id
ORDER BY
    eh.level ASC,
    b.budget DESC,
    eh.employee_name ASC;
