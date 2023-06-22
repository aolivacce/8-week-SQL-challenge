## Case Study #4: Data Bank

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/458aba0e-40e5-440b-bde5-20d4dade8e35" width=40% height=40%>

## Table of Contents
  - [Business Task](#business-task)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Questions and Solutions](#questions-and-solutions)
            
  

## Business Task
Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - Data Bank!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

## Entity Relationship Diagram 

![F1E23915-99E4-4ABC-987A-FF0FEA24C0E6_4_5005_c](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/8ace8a6a-4e71-4bd5-88b1-262e744d8e00)

## Questions and Solutions 

**1. How many unique nodes are there on the Data Bank system?**


```sql
SELECT COUNT(DISTINCT node_id) 
FROM data_bank.customer_nodes;
```

Result:

![image](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/dab50c28-a582-478b-a897-f2ea623f2c3b)


**2. What is the number of nodes per region?**


```sql
SELECT r.region_name, COUNT(DISTINCT n.node_id) AS nodes_per_region
FROM data_bank.customer_nodes AS n
JOIN data_bank.regions AS r ON n.region_id = r.region_id
GROUP BY r.region_name;
```

Result:

![image](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/66b1fd9b-f8a2-4043-adc2-47d9fdc723ae)


**3. How many customers are allocated to each region?**

```sql
SELECT r.region_name, COUNT(DISTINCT n.node_id) AS nodes_per_region
FROM data_bank.customer_nodes AS n
JOIN data_bank.regions AS r ON n.region_id = r.region_id
GROUP BY r.region_name;
```

Result:

**4. How many days on average are customers reallocated to a different node?**


```sql
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
```

Result:



5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

Query:

```sql
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

```

Result:

![image](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/3ff5049a-bc21-49cf-a2f8-c83c1de17df4)


**6. What is the unique count and total amount for each transaction type?**

```sql
SELECT txn_type, COUNT(customer_id) AS total_count, SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type; 
```

Result:

![image](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/4dd0cf10-8739-422d-bb37-18fbfb6e61f9)


**7. What is the average total historical deposit counts and amounts for all customers?**

```sql
WITH cte AS (
SELECT customer_id, COUNT(customer_id) AS txn_count , AVG(txn_amount) AS total_amount
FROM data_bank.customer_transactions
WHERE txn_type = 'deposit'
GROUP BY customer_id)

SELECT ROUND(AVG(txn_count),2) AS avg_txn_count, 
ROUND(AVG(total_amount),2)  AS avg_total
FROM cte;
```

Result:

![image](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/412e02ef-38d0-43a8-bd07-d6a98fcf4a2f)


**8. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

```sql

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
```

Result:

9. What is the closing balance for each customer at the end of the month?

Query:

```sql
SELECT customer_id, 
TO_CHAR(txn_date, 'Month') AS month, 
SUM(txn_amount) AS closing_balance
FROM data_bank.customer_transactions 
GROUP BY customer_id, month
ORDER BY customer_id;
```

Result:



View the case study [here](https://8weeksqlchallenge.com/case-study-4/) and my full query [here](https://github.com/aolivacce/8-week-SQL-challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/fullSQLquery.sql)!
