WITH customer_transactions AS (
SELECT 
    customer.id AS customer_id,
    CONCAT(customer.first_name, ' ', customer.last_name) AS name,
    TIMESTAMPDIFF(MONTH, customer.created_on, CURRENT_DATE) AS tenure_months,
    COUNT(DISTINCT savings.transaction_reference) AS total_transactions,
    AVG(confirmed_amount * 0.01) AS  avg_profit_per_transaction -- 0.1% profit
FROM users_customuser AS customer
JOIN savings_savingsaccount AS savings
    ON customer.id = savings.owner_id
WHERE savings.transaction_status = 'success'  -- Only successful transactions
GROUP BY customer_id, name, tenure_months
HAVING tenure_months > 0 -- Exclude customers who just signed up
)
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    -- Calculate estimated CLV (annualized)
    ROUND(
        (total_transactions / tenure_months) * 12 * avg_profit_per_transaction,
        2) AS estimated_clv
FROM customer_transactions
ORDER BY estimated_clv DESC;
-- This query calculates the estimated Customer Lifetime Value (CLV) for each customer based on their transaction history.