# DataAnalytics-Assessment

## SQL Assessment Solution: Q1 - Cross-Selling Opportunities

### Business Objective
Identify high-value customers who maintain both savings and investment products to uncover cross-selling opportunities, sorted by their total deposit amounts.

## Solution Design

### Technical Approach >> [Assessment_Q1.sql](Assessment_Q1.sql)

```
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
```
* **The Goal:** To find customers who have both savings and investment accounts, showing how much they've deposited, sorted from highest to lowest balance.

### Step-by-Step Thinking
1. **First, calculate each customer's total deposits**: 
```WITH deposit AS (
    SELECT owner_id, SUM(confirmed_amount) AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
)
```
This creates a temporary list of customers and their combined savings.

2. **Then find customers with both account types:**
```SELECT
    plans.owner_id,
    CONCAT(first_name, ' ', last_name) AS name,
    SUM(is_regular_savings) AS savings_count,
    SUM(is_a_fund) AS investment_count,
    ROUND(COALESCE(total_deposits, 0)/100, 2) AS total_deposits
```
Here, I counted the number of savings and investment plan each customer has in total as well as their total deposits I calculated earlier (converted to naira).

3. **Connecting the data:** 
```
FROM Plans_plan AS plans
JOIN users_customuser AS users ON plans.owner_id = users.id
JOIN deposit ON users.id = deposit.owner_id
```
I connected plans and customers data together to attach the necessary customer names with their saving and investment counts. I also connected the deposit CTE to attach their total_deposits.

4. **Filter for exactly who we want:**
```
GROUP BY owner_id
HAVING
    SUM(is_a_fund) >= 1          -- Has at least 1 investment
    AND SUM(is_regular_savings) >= 1  -- Has at least 1 savings
    AND total_deposits > 0        -- With real money deposited
```
Added necessary filters to select only customers who have atleast 1 savings and 1 investment plan and also added `total_deposit > 0` to make sure those plans are funded.

5. **Present the results neatly:** 
```
ORDER BY total_deposits DESC;
```
This ensures biggest depositors are at the top, making it easy to see high-value customers first.

### Challenges Faced & Solutions Implemented

#### Identifying Correct Deposit Amount
**Challenge**:  
No direct "total_deposits" column existed in the database. In a real life scenario, I would make enquries and ask clarifying questions and also request for the complete data dictionary.

**Solution**:  
- Analyzed all available amount fields (`confirmed_amount`, `amount`, `deduction_amount`)
- Used `confirmed_amount` based on the hint that it represents "value of inflow"
- Verified this was the actual deposited money (not just planned transactions)
