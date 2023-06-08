## Case Study #2: Pizza Runner 
<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/db2848e5-d57b-46de-aa01-3386a8086046" width=40% height=40%>

## Table of Contents
  - [Business Task](#business-task)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Data Preperation](data-preperation)
  - [Solutions](#solutions)

## Business Task 
Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.
## Entity Relationship Diagram

![05D885BF-52AA-4D70-89C8-0A05C57D70CA_1_105_c](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/2d0aa9a1-bce0-4951-aacb-464c95af25b1)

## Data Preperation

### Table: customer_orders
Looking at the `` customer_orders `` table below, we can see that there are

- Missing/ blank values ' ' and null values in the `` exclusions `` column
- Missing/ blank values ' ' and null values in the `` extras `` column 

![E76AB9C6-097B-4DFF-8680-C2EC4A353B72](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/95edb6ea-e9c5-4e8d-bde2-362c20016b65)

Let's remove null values in `` exlusions `` and `` extras `` columns and replace with blank space ' '.

```sql
DROP TABLE IF EXISTS updated_customer_orders;
CREATE TEMP TABLE updated_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE 
      WHEN exclusions IS NULL 
        OR exclusions LIKE 'null' THEN ''
      ELSE exclusions 
    END AS exclusions,
    CASE 
      WHEN extras IS NULL
        OR extras LIKE 'null' THEN ''
      ELSE extras 
    END AS extras,
    order_time
  FROM pizza_runner.customer_orders
);
SELECT * FROM updated_customer_orders;
```

Result: 

![E781E5D6-2EDA-4A97-8E30-606A1977036A](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/e29e4721-eaa9-4a63-9436-cae9b6644978)

### Table: runner_orders

Looking at the `` runner_orders `` table below, we can see that there are

- Missing/ blank values ' ' and null values in the `` exclusions `` column
- Missing/ blank values ' ' and null values in the `` extras `` column 

![A0ABB216-B79F-485B-AE78-4936B3D65918](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/6510c513-30a4-45cb-9397-af510723f40e)

After doing a little more digging, we realize that `` pickup time ``, `` distance `` and `` duration `` are not the correct data types. Also, units (km, minutes) need to be removed from `` distance `` and `` duration `` for our analysis.


``` sql
DROP TABLE IF EXISTS updated_runner_orders;
CREATE TEMP TABLE updated_runner_orders AS (
  SELECT
    order_id,
    runner_id,
    CASE WHEN pickup_time LIKE 'null' THEN null ELSE pickup_time END::timestamp AS pickup_time,
    NULLIF(regexp_replace(distance, '[^0-9.]','','g'), '')::numeric AS distance,
    NULLIF(regexp_replace(duration, '[^0-9.]','','g'), '')::numeric AS duration,
    CASE WHEN cancellation IN ('null', 'NaN', '') THEN null ELSE cancellation END AS cancellation
  FROM pizza_runner.runner_orders);
SELECT * FROM updated_runner_orders;
```
Now, to check the data types
```sql
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'updated_customer_orders'
```
Result:
![E77532AA-135B-4075-BF5B-90A974333EEE](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/3caf090b-ee9d-4821-918c-17afe9567abc)

## Solutions 

1. How many pizzas were ordered?

Steps:

Query:
```sql
SELECT COUNT(*) AS order_count 
FROM pizza_runner.customer_orders;

```
Result:

2. How many unique customer orders were made?

Steps:

Query:
```sql
SELECT COUNT(DISTINCT order_id) AS order_count 
FROM pizza_runner.customer_orders;
```
Result:

3. How many successful orders were delivered by each runner?

Steps:

Query:
```sql
SELECT runner_id, COUNT(order_id) 
FROM pizza_runner.runner_orders
WHERE distance IS NOT NULL
GROUP BY runner_id;
```
Result:

4. How many of each type of pizza was delivered?

Steps:

Query:
```sql
SELECT p.pizza_name, COUNT(c.pizza_id)
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
JOIN pizza_runner.pizza_names AS p ON c.pizza_id = p.pizza_id
WHERE r.distance IS NOT NULL
GROUP BY p.pizza_name;
```
Result:

5. How many Vegetarian and Meatlovers were ordered by each customer?

Steps:

Query:

```sql
SELECT c.customer_id, p.pizza_name, COUNT(c.order_id)
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.pizza_names AS p
ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;
```
Result:

6. What was the maximum number of pizzas delivered in a single order?

Steps:
Query:
```sql
WITH delivered AS (
  SELECT 
    c.order_id, 
    COUNT(c.pizza_id) AS pizza_per_order
  FROM pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
  WHERE r.distance IS NOT NULL
  GROUP BY c.order_id
)
SELECT MAX(pizza_per_order) AS max_pizza_per_order
FROM delivered;
```
Result:

7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

Steps:

Query:
```sql

SELECT
  c.customer_id,
  COUNT(CASE WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1 END) AS changes,
  COUNT(CASE WHEN (c.exclusions = ' ' AND c.extras = ' ') OR (c.exclusions IS NULL AND c.extras IS NULL) THEN 1 END) AS no_change
FROM pizza_runner.customer_orders AS c
JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;
```
Result:

8. How many pizzas were delivered that had both exclusions and extras?

Steps:
Query:
```sql

WITH delivered AS (
  SELECT 
    c.order_id, 
    COUNT(c.pizza_id) AS pizza_per_order
  FROM pizza_runner.customer_orders AS c
  JOIN pizza_runner.runner_orders AS r ON c.order_id = r.order_id
  WHERE r.distance IS NOT NULL
  GROUP BY c.order_id
)
SELECT 
  COUNT(c.pizza_id) as delivered_with_exclusions_and_extras 
FROM delivered
WHERE 
  pickup_time <> 'null'
  AND exclusions IS NOT NULL AND LENGTH(exclusions) > 0
  AND extras IS NOT NULL AND LENGTH(extras) > 0;
```
Result:

9. What was the total volume of pizzas ordered for each hour of the day?

Steps:

Query:
```sql

SELECT EXTRACT(HOUR FROM order_time) AS hour_of_day,
  COUNT(*) AS total_pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY hour_of_day
ORDER BY
  hour_of_day;
```
Result:


10. What was the volume of orders for each day of the week?

Steps:

Query:
```sql

SELECT
  to_char(date_trunc('day', order_time + INTERVAL '2 days'), 'Day') AS day_of_week,
  COUNT(order_id) AS total_pizzas_ordered
FROM
  pizza_runner.customer_orders
GROUP BY
  day_of_week;
```
Result:
