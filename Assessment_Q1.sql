-- CTE to calculate total deposits from savings accounts for each customer
WITH
    deposit AS (
        SELECT owner_id, SUM(confirmed_amount) AS total_deposits
        FROM savings_savingsaccount
        GROUP BY
            owner_id
    )
    -- Main query to identify cross-selling opportunities
SELECT
    plans.owner_id AS owner_id,
    CONCAT(first_name, ' ', last_name) AS name,
    SUM(is_regular_savings) AS savings_count,
    SUM(is_a_fund) AS investment_count,
    -- returns 0 if total_deposits is NULL and Convert kobo to main currency (Naira)
    ROUND(
        COALESCE(total_deposits, 0)/100, 
        2                               
    ) AS total_deposits 
FROM
    `Plans_plan` AS plans
    JOIN `users_customuser` AS users ON plans.owner_id = users.id
    JOIN deposit ON users.id = deposit.owner_id
GROUP BY
    owner_id
HAVING
    SUM(is_a_fund) >= 1
    AND SUM(is_regular_savings) >= 1
    AND total_deposits > 0 -- Explicit funded plan filter
ORDER BY total_deposits DESC; -- sort by total_deposits in descending order