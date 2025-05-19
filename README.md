# DataAnalytics-Assessment (Solved with Mysql)

## Assessment_Q1 Solution - Cross-Selling Opportunities

### Business Objective
Identify high-value customers who maintain both savings and investment products to uncover cross-selling opportunities, sorted by their total deposit amounts.

* **The Goal:** To find customers who have both savings and investment accounts, showing how much they've deposited, sorted from highest to lowest balance.

### Step-by-Step Thinking
1. **First, calculate each customer's total deposits**: 
This creates a temporary list of customers and their combined savings.

2. **Then find customers with both account types:**
Here, I counted the number of savings and investment plan each customer has in total as well as their total deposits I calculated earlier (converted to naira).

3. **Connecting the data:** 
I connected plans and customers data together to attach the necessary customer names with their saving and investment counts. I also connected the deposit CTE to attach their total_deposits.

4. **Filter for exactly who we want:**
Added necessary filters to select only customers who have atleast 1 savings and 1 investment plan and also added `total_deposit > 0` to make sure those plans are funded.

5. **Present the results neatly:** 
```
ORDER BY total_deposits DESC;
```
This ensures biggest depositors are at the top, making it easy to see high-value customers first.

### Final Query >>> [Assessment_Q1.sql](Assessment_Q1.sql)

### Challenges Faced & Solutions Implemented

#### Identifying Correct Deposit Amount
**Challenge**:  
No direct "total_deposits" column existed in the database. In a real life scenario, I would make enquries and ask clarifying questions and also request for the complete data dictionary.

**Solution**:  
- Analyzed all available amount fields (`confirmed_amount`, `amount`, `deduction_amount`)
- Used `confirmed_amount` based on the hint that it represents "value of inflow"
- Verified this was the actual deposited money (not just planned transactions)

---------------
--------------

## Assessment_Q2 Solution
### Business Objective - Transaction Frequency Analysis
**Scenario:** The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).

**Task:** Calculate the average number of transactions per customer per month and categorize them:"High Frequency" (≥10 transactions/month), "Medium Frequency (3-9 transactions/month), "Low Frequency" (≤2 transactions/month).

### My Thought Process:
1. **First, To understand What We Need to Calculate:**
    * For each customer, find their average number of transactions per month
    * Then group them into 3 categories based on that average.
2. **Let's break down the Problem into Smaller Tasks:**
    * Task 1: Count Transactions per Customer per Month:
        For each customer (owner_id), count how many transactions they made each month
        Need to extract year-month from transaction dates to group by month
    * Task 2: Calculate Monthly Averages:
        Using the monthly count from task1; For each customer, average their monthly transaction counts
    * Task 3: Categorize Customers:
        Apply the business rules to categorize customers into high, medium and low frequency.
    * Task 4: Aggregate Customer count and average transactions per month in each category.  

### Final Query >>> [Assessment_Q2.sql](Assessment_Q2.sql)

### Challenges Faced & Solutions Implemented
**Challenge**:  Float averages (e.g., 9.2) didn't match integer category thresholds (e.g., ≥10).

**Solution**:  Rounded averages before categorization (e.g., 9.5 → 10 = High Frequency) for clean segmentation.

--------------
--------------

## Assessment_Q3 Solution
### Business Objective - Account Inactivity Alert
**Scenario:** The ops team wants to flag accounts with no inflow transactions for over one year.

**Task:** Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .

### My Thought Process:
1. **Understanding the Requirement:**
        - Need to find accounts with no deposits/transactions for 365 days and above.
        - Must check both savings and investment accounts
        - Only active accounts should be considered
2. **Key Data Points Needed:** 
        - Account identification (plan_id and owner_id)
        - Account type (Savings/Investment)
        - Most recent transaction date
        - Days since last transaction
3. **Approach:** For each account type (savings/investment):
        - I will join plans_plan table with savings_savingsaccount tables,
        - Filter for active accounts only _i.e only savings and investments_,
        - Find most recent transaction per account,
        - Calculate days since last transaction,
        - Filter for inactivity > 365 days

### Final Query >>> [Assessment_Q3.sql](Assessment_Q3.sql)

### Challenges Faced & Solutions Implemented
**Challenge**:  
While I do not have a significant challenge in this case, I wish to state an observation:

**Inflow-Only Focus**:  
* Business Rule: Only inflow transactions (confirmed_amount > 0) were considered
* Implication: Accounts with recent withdrawals but no deposits could still appear inactive.
* Documentation: Added SQL comments to clarify this intentional filtering.

---------------
---------------

## Assessment_Q4 Solution
### Business Objective - Customer Lifetime Value (CLV) Estimation
**Scenario:** Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).

**Task:** For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
* Account tenure (months since signup)
* Total transactions
* Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
* Order by estimated CLV from highest to lowest


### My Thought Process:
1. **Understanding the Business Goal:**
    - Marketing wants to predict customer profitability based on historical behavior.
    - CLV helps prioritize high-value customers for retention/growth strategies.

2. **Defining Key Components:**

| **Component**               | **Definition**                                                                                          |
|-----------------------------|---------------------------------------------------------------------------------------------------------|
| **Profit per Transaction**  | 0.1% of the transaction value (`confirmed_amount × 0.001`).                                             |
| **Transaction Value**       | Monetary amount of a deposit (in kobo). 100 kobo = 1 Naira.                                             |
| **Total Transactions**      | Count of unique successful transactions (`transaction_status = 'success'`).                             |
| **Account Tenure**          | Months since customer signup (`created_on`) to current date.                                            |
| **Avg. Profit per Tx**      | `(Total Profit / Total Transactions)` where Total Profit = `SUM(confirmed_amount × 0.001)`.             |
| **Estimated CLV**           | `(Total Transactions / Tenure in Months) × 12 × Avg. Profit per Tx` (annualized profit potential).      |

3. **Code Explanation:** 
    - I created a CTE to hold the metrics necesssary to calculate the estimated CLTV, such as `tenure_months`, `total_transactions`, and `avg_profit_per_transaction`.
    - The final query calculates the estimated Customer Lifetime Value (CLV) for each customer based on their transaction history.
    - **Note:** I filtered for only **successful** transactions because of the following:
        * Accuracy – Failed/reversed transactions don’t contribute to revenue.
        * Business Realism – Only completed transactions reflect actual customer value and including failed transactions would artificially inflate CLV.

### Final Query >>> [Assessment_Q4.sql](Assessment_Q4.sql)

### Challenges Faced & Solutions Implemented
**Challenge**:  
The only challenge for me was deciding from which of the two tables should I choose the `created_on` column.
I chose the column from the `users_customuser` because of the following reason:
1. **Tenure Should Reflect Customer Age:**
    * `users_customuser.created_on` = When the customer joined the platform
    * `savings_savingsaccount.created_on` = When the savings account was opened
    * A customer might have signed up years before opening a savings account.
    * CLV measures lifetime value **since customer acquisition**, not product usage.

# Final Notes
This solution demonstrates:
🔹 Clean, Modular SQL: Readable CTEs with logical separation of concerns.

🔹 Business Alignment: Metrics tailored to marketing’s CLV requirements.

🔹 Robustness: Edge-case handling (new customers, failed transactions).

**Next Steps:** With additional data (e.g., investment transactions), the model could be expanded for even deeper insights.

Thank you for your consideration. I welcome feedback and look forward to discussing how this approach could drive value for your team.