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

**1. How many customers has Foodie-Fi ever had?**

```sql

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM foodie_fi.subscriptions;

```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/1dacdeca-43a4-4ecf-a2af-7dd05c354232" width=20% height=20%>



**2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.**

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

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/e4e7a8ca-3483-468e-b737-dd5eb28ea4bb">



**3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name. **

```sql

SELECT p.plan_id, p.plan_name, COUNT(*) AS events_2021 
FROM foodie_fi.plans AS p
 JOIN foodie_fi.subscriptions AS sub ON p.plan_id = sub.plan_id
WHERE sub.start_date >= '2021-01-01'
GROUP BY p.plan_id, p.plan_name
ORDER BY plan_id;

```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/9a0cf92c-0063-4f0d-8361-24eb90bbf191">


**4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?**

```sql
SELECT COUNT(*) AS churn_count, 
	 ROUND(100 * COUNT(*)::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS churn_percentage  
FROM foodie_fi.subscriptions AS sub
JOIN foodie_fi.plans AS p ON sub.plan_id = p.plan_id
WHERE p.plan_id = 4;

```

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/b01fb733-2e2a-46c9-abe5-fe53d439ab00">


**5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?**

```sql
WITH ranked_cte AS (
  SELECT 
    sub.customer_id,  
    plans.plan_name, 
    LEAD(plans.plan_name) OVER ( 
      PARTITION BY sub.customer_id
      ORDER BY sub.start_date) AS next_plan
  FROM foodie_fi.subscriptions AS sub
  JOIN foodie_fi.plans AS plans
    ON sub.plan_id = plans.plan_id
)
  
SELECT 
  COUNT(customer_id) AS churned_customers,
  ROUND(100.0 * 
    COUNT(customer_id) 
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions)
  ) AS churn_percentage
FROM ranked_cte
WHERE plan_name = 'trial' 
  AND next_plan = 'churn';

```

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/b99e7863-780b-4acc-9c21-b163fbbc6eaf">


**6. What is the number and percentage of customer plans after their initial free trial?**

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

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/bd55fca6-324b-465a-ac08-7bf91f578763">


**7. What is the customer count and percentage breakdown of all 5 plan_name values at 20-12-31?**

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

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/66774872-4607-4242-9ad5-e7da4677e27a">

**8. How many customers have upgraded to an annual plan in 2020?**

```sql

SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions 
WHERE start_date <= '2020-12-31'
	AND plan_id = 3;
```

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/7ff2f9cf-9e51-443f-9289-4fab93cdd511">


**9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?**

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

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/fe0f8f7e-32cb-4bce-93c8-7d82f050ef1a">


**10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)**

```sql
WITH trial_plan AS (
-- trial_plan CTE: Filter results to include only the customers subscribed to the trial plan.
  SELECT 
    customer_id, 
    start_date AS trial_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 0
), annual_plan AS (
-- annual_plan CTE: Filter results to only include the customers subscribed to the pro annual plan.
  SELECT 
    customer_id, 
    start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
), bins AS (
-- bins CTE: Put customers in 30-day buckets based on the average number of days taken to upgrade to a pro annual plan.
  SELECT 
    WIDTH_BUCKET(annual.annual_date - trial.trial_date, 0, 365, 12) AS avg_days_to_upgrade
  FROM trial_plan AS trial
  JOIN annual_plan AS annual
    ON trial.customer_id = annual.customer_id
)
  
SELECT 
  ((avg_days_to_upgrade - 1) * 30 || ' - ' || avg_days_to_upgrade * 30 || ' days') AS bucket, 
  COUNT(*) AS num_of_customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;
```

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/2d5199c7-ef99-43e8-8c16-932610d12e79">


11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql

SELECT COUNT(*) AS customers_downgraded
FROM next_plan_cte
WHERE plan_id=2 AND next_plan=1;

```

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/9c93874c-f848-4de6-8a24-3e934d161c13">
