SELECT
    plans.id AS plan_id,
    plans.owner_id,
    -- categorize plans into investment and savings type
    CASE
        WHEN plans.is_regular_savings = 1 THEN 'Savings'
        WHEN plans.is_a_fund = 1 THEN 'Investment'
    END AS type,
    -- return the latest date of inflow transaction
    MAX(
        CASE 
            WHEN savings.confirmed_amount > 0 THEN savings.transaction_date
        END) AS last_transaction_date,
        -- return how many days away is the last inflow transaction date
    DATEDIFF(
        CURRENT_DATE,
        MAX(
            CASE
                WHEN savings.confirmed_amount > 0 THEN savings.transaction_date
            END)
    ) AS inactivity_days
FROM
    plans_plan AS plans
LEFT JOIN       -- include all accounts, even those with no transactions
    savings_savingsaccount AS savings 
ON plans.id = savings.plan_id AND plans.owner_id = savings.owner_id -- matching both plan_id and owner_id for accuracy
    -- filter for saings and investment plans only
WHERE (
        plans.is_regular_savings = 1
        OR plans.is_a_fund = 1
    )
GROUP BY
    plans.id,
    plans.owner_id
    -- Last inflow >365 days (1yr) ago
HAVING
    inactivity_days >= 365
ORDER BY inactivity_days; 
