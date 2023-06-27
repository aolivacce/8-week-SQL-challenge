---------------------
-- Case Study #4 --
-- PART A -- 
-- Customer Nodes Exploration --
---------------------

-- How many unique nodes are there on the Data Bank system?

SELECT COUNT(DISTINCT node_id) 
FROM data_bank.customer_nodes;

-- What is the number of nodes per region?

SELECT r.region_name, COUNT(DISTINCT n.node_id) AS nodes_per_region
FROM data_bank.customer_nodes AS n
JOIN data_bank.regions AS r ON n.region_id = r.region_id
GROUP BY r.region_name;

-- How many customers are allocated to each region?

SELECT 
  region_id, 
  COUNT(customer_id) AS customer_count
FROM data_bank.customer_nodes
GROUP BY region_id
ORDER BY region_id;

-- How many days on average are customers reallocated to a different node?

WITH node_days AS (
  SELECT 
    customer_id, 
    node_id,
    end_date - start_date AS days_in_node
  FROM data_bank.customer_nodes
  WHERE end_date != '9999-12-31'
  GROUP BY customer_id, node_id, start_date, end_date
) 
, total_node_days AS (
  SELECT 
    customer_id,
    node_id,
    SUM(days_in_node) AS total_days_in_node
  FROM node_days
  GROUP BY customer_id, node_id
)

SELECT ROUND(AVG(total_days_in_node)) AS avg_node_reallocation_days
FROM total_node_days;

-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?


WITH date_diff AS
(
	SELECT c.customer_id,
	       c.region_id,
	       r.region_name,
	       DATEDIFF(DAY, start_date, end_date) AS reallocation_days
	FROM customer_nodes c
	INNER JOIN regions r
	ON c.region_id = r.region_id
	WHERE end_date != '9999-12-31'
)

SELECT DISTINCT region_id,
	        region_name,
	        PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY reallocation_days) OVER(PARTITION BY region_name) AS median,
	        PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY reallocation_days) OVER(PARTITION BY region_name) AS percentile_80,
	        PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY reallocation_days) OVER(PARTITION BY region_name) AS percentile_95
FROM date_diff
ORDER BY region_name;


------------------------------
-- B. Customer Transactions --
------------------------------

-- What is the unique count and total amount for each transaction type?

SELECT txn_type, COUNT(customer_id) AS total_count, SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type; 

-- What is the average total historical deposit counts and amounts for all customers?

WITH cte AS (
SELECT customer_id, COUNT(customer_id) AS txn_count , AVG(txn_amount) AS total_amount
FROM data_bank.customer_transactions
WHERE txn_type = 'deposit'
GROUP BY customer_id)

SELECT ROUND(AVG(txn_count),2) AS avg_txn_count, 
ROUND(AVG(total_amount),2)  AS avg_total
FROM cte;;

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH cust_activity AS (
  SELECT 
    customer_id, 
    TO_CHAR(txn_date, 'Month') AS month_name, 
    COUNT(CASE WHEN txn_type = 'deposit' THEN 1 END) AS deposit_count,
    COUNT(CASE WHEN txn_type = 'purchase' THEN 1 END) AS purchase_count,
    COUNT(CASE WHEN txn_type = 'withdrawal' THEN 1 END) AS withdrawal_count
  FROM 
    data_bank.customer_transactions
  GROUP BY 
    customer_id, month_name
)

SELECT 
  month_name, 
  COUNT(DISTINCT customer_id) AS active_customers
FROM 
  cust_activity
WHERE 
  deposit_count > 1
  AND (purchase_count = 1 OR withdrawal_count = 1)
GROUP BY 
  month_name;

-- What is the closing balance for each customer at the end of the month?

SELECT customer_id, 
TO_CHAR(txn_date, 'Month') AS month, 
SUM(txn_amount) AS closing_balance
FROM data_bank.customer_transactions 
GROUP BY customer_id, month
ORDER BY customer_id;

-- What is the percentage of customers who increase their closing balance by more than 5%?




