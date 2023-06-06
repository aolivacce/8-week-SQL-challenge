## Data Cleaning and Transformation

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
