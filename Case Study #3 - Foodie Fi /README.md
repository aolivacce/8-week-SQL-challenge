## Case Study #3: Foodie Fi
<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/41a94436-8987-46a0-a186-097d9ebef26b" width=40% height=40%>

## Table of Contents
  - [Business Task](#business-task)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Questions and Solutions](#questions-and-solutions)
 
## Business Task

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

## Entity Relationship Diagram

![52768C7B-67C9-4012-9886-422A70073D60_4_5005_c](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/a3c18f91-fd24-4b6b-9aa3-f00601091a17)

## Questions and Solutions 

1. How many customers has Foodie-Fi ever had?

Query:
```sql

SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM foodie_fi.subscriptions;

```
Result:

2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

Query:

```sql
 SELECT 
 DATE_PART('month', sub.start_date) AS month_num,
 TO_CHAR(sub.start_date,'Month') AS month, COUNT(p.plan_id) AS trial_subscriptions
 FROM foodie_fi.plans AS p
 JOIN foodie_fi.subscriptions AS sub ON p.plan_id = sub.plan_id
 WHERE sub.plan_id = 0
GROUP BY month_num, month
ORDER BY month_num;
```
Result:

3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

Query:
```sql

SELECT p.plan_id, p.plan_name, COUNT(*) AS events_2021 
FROM foodie_fi.plans AS p
 JOIN foodie_fi.subscriptions AS sub ON p.plan_id = sub.plan_id
WHERE sub.start_date >= '2021-01-01'
GROUP BY p.plan_id, p.plan_name
ORDER BY plan_id;

```
Result:

4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

Query:
```sql
SELECT COUNT(*) AS churn_count, 
	 ROUND(100 * COUNT(*)::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS churn_percentage  
FROM foodie_fi.subscriptions AS sub
JOIN foodie_fi.plans AS p ON sub.plan_id = p.plan_id
WHERE p.plan_id = 4;

```
Result:

5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

Query:
```sql
WITH next_plan_cte AS (
SELECT 
  customer_id, 
  plan_id, 
  LEAD(plan_id, 1) OVER( 
    PARTITION BY customer_id 
    ORDER BY plan_id) as next_plan
FROM foodie_fi.subscriptions)

SELECT 
  next_plan, 
  COUNT(*) AS conversions,
  ROUND(100 * COUNT(*)::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS conversion_rate
FROM next_plan_cte
WHERE next_plan IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan
ORDER BY next_plan;

```
Result:

6. What is the number and percentage of customer plans after their initial free trial?

Query:
```sql
WITH next_plans AS (
  SELECT 
    customer_id, 
    plan_id, 
    LEAD(plan_id) OVER(
      PARTITION BY customer_id 
      ORDER BY plan_id) as next_plan_id
  FROM foodie_fi.subscriptions
)

SELECT 
  next_plan_id AS plan_id, 
  COUNT(customer_id) AS converted_customers,
  ROUND(100 * 
    COUNT(customer_id)::NUMERIC 
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions)
  ,1) AS conversion_percentage
FROM next_plans
WHERE next_plan_id IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan_id
ORDER BY next_plan_id;
```
Result:

7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

Query:
```sql
WITH customer_breakdown AS (
  SELECT plan_id, COUNT(DISTINCT customer_id) AS customers
  FROM (
    SELECT 
      customer_id, 
      plan_id, 
      start_date,
      LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_date
    FROM foodie_fi.subscriptions
    WHERE start_date <= '2020-12-31'
  ) AS next_plan
  WHERE (next_date IS NOT NULL AND (start_date < '2020-12-31' AND next_date > '2020-12-31'))
    OR (next_date IS NULL AND start_date < '2020-12-31')
  GROUP BY plan_id
)

SELECT plan_id, customers, 
  ROUND(100 * customers::NUMERIC / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions), 1) AS percentage
FROM customer_breakdown
ORDER BY plan_id;
```
Result:

8. How many customers have upgraded to an annual plan in 2020?

Query:
```sql

SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions 
WHERE start_date >= '2020-12-31'
	AND plan_id = 3;
```
Result:

9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

Query:
```sql
WITH trial_plan AS 
(SELECT 
  customer_id, 
  start_date AS trial_date
FROM foodie_fi.subscriptions
WHERE plan_id = 0
),

annual_plan AS
(SELECT 
  customer_id, 
  start_date AS annual_date
FROM foodie_fi.subscriptions
WHERE plan_id = 3
)

SELECT 
  ROUND(AVG(annual_date - trial_date),0) AS avg_days_to_upgrade
FROM trial_plan AS t
JOIN annual_plan  AS a
  ON t.customer_id = a.customer_id;

```
Result:

10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

Query:
```sql
WITH trial_plan AS (
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
),
annual_plan AS (
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
),
bins AS (
  SELECT 
    FLOOR(DATE_DIFF('day', t.trial_date, a.annual_date) / 30) AS avg_days_to_upgrade
  FROM trial_plan t
  JOIN annual_plan a ON t.customer_id = a.customer_id
)
SELECT 
  CONCAT((avg_days_to_upgrade * 30 - 30), ' - ', avg_days_to_upgrade * 30, ' days') AS breakdown, 
  COUNT(*) AS customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;
```
Result:

11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

Query:
```sql
WITH next_plan_cte AS 
(
SELECT customer_id, plan_id start_date,
	LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
FROM foodie_fi.subscriptions)

SELECT COUNT(DISTINCT customer_id)
FROM next_plan_cte
WHERE next_plan = 1
AND plan_id = 2; 
```
Result:
