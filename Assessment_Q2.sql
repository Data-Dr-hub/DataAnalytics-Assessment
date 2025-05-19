WITH
    -- Step 1: Count all transactions per customer per month
    monthly_transactions AS (
        SELECT
            customers.id as customer_id,
            DATE_FORMAT(transaction_date, '%Y-%m') AS month,
            COUNT(
                DISTINCT transaction_reference
            ) AS transaction_count -- count of unique transactions
        FROM
            savings_savingsaccount savings
            JOIN `users_customuser` customers on savings.owner_id = customers.id
        GROUP BY
            customer_id,
            DATE_FORMAT(transaction_date, '%Y-%m')
    ),
    -- Step 2: Calculate average transactions per month for each customer
    customer_averages AS (
        SELECT
            customer_id,
            ROUND(AVG(transaction_count)) AS avg_transactions_per_month -- rounded to match business intuitions
        from monthly_transactions
        GROUP BY
            customer_id
    ),
    -- Step 3: Categorize customers based on avg_transactions_per_month
    customer_segments AS (
        SELECT
            customer_id,
            avg_transactions_per_month,
            CASE
                WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
                WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
                ELSE 'Low Frequency'
            END AS frequency_category
        FROM customer_averages
    )
SELECT
    frequency_category,
    count(customer_id) as customer_count,
    ROUND(
        avg(avg_transactions_per_month),
        1
    ) as avg_transactions_per_month
from customer_segments
group by
    frequency_category
order by avg_transactions_per_month desc;