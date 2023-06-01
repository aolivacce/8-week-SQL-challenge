-- How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM foodie_fi.subscriptions;

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

 SELECT 
 DATE_PART('month', sub.start_date) AS month_num,
 TO_CHAR(sub.start_date,'Month') AS month, COUNT(p.plan_id) AS trial_subscriptions
 FROM foodie_fi.plans AS p
 JOIN foodie_fi.subscriptions AS sub ON p.plan_id = sub.plan_id
 WHERE sub.plan_id = 0
GROUP BY month_num, month
ORDER BY month_num;

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT p.plan_id, p.plan_name, COUNT(*) AS events_2021 
FROM foodie_fi.plans AS p
 JOIN foodie_fi.subscriptions AS sub ON p.plan_id = sub.plan_id
WHERE sub.start_date >= '2021-01-01'
GROUP BY p.plan_id, p.plan_name
ORDER BY plan_id;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT COUNT(*) AS churn_count, 
	 ROUND(100 * COUNT(*)::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS churn_percentage  
FROM foodie_fi.subscriptions AS sub
JOIN foodie_fi.plans AS p ON sub.plan_id = p.plan_id
WHERE p.plan_id = 4;

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

-- What is the number and percentage of customer plans after their initial free trial?


-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
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
    FROM foodie_fi.subscriptions),1) AS conversion_percentage
FROM next_plan_cte
WHERE next_plan IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan
ORDER BY next_plan;

-- How many customers have upgraded to an annual plan in 2020?

SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions 
WHERE start_date >= '2020-12-31'
	AND plan_id = 3;
    
-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

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
