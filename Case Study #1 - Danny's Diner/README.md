## Case Study #1: Danny's Diner

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/5eb59780-5759-40d5-a26e-f46d53897d0e" width=40% height=40%>

## Table of Contents
  - [Business Task](#business-task)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Questions and Solutions](#questions-and-solutions)



## Business Task 

Danny’s Diner is in need of our assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favorite.


## Entity Relationship Diagram

![2F3E7E6A-6FF4-46A6-B9F9-3EE19CABC122_4_5005_c](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/89c667ac-a447-4278-977f-01922644758d)

## Questions and Solutions

**1. What is the total amount each customer spent at the restaurant?**

```sql
SELECT s.customer_id, sum(price) AS total_sales
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id; 
```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/2e2044d2-59de-4887-baec-ffedeefe2157" width=40% height=40%>


**2. How many days has each customer visited the restaurant?**
 
```sql
SELECT customer_id, COUNT(DISTINCT(order_date))
FROM dannys_diner.sales
GROUP BY customer_id;
```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/9e8a642b-d2a6-4748-bb97-3247f8892cef" width=50% height=50%>

**3. What was the first item from the menu purchased by each customer?**
```sql
with ordered_sales AS ( 
SELECT customer_id, order_date, product_name,
DENSE_RANK() OVER(PARTITION BY customer_id
                ORDER BY order_date) AS rank
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id)

SELECT customer_id, product_name
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name;
```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/9931398b-bc3a-4b0b-bb95-f3fde71cc33b" width=50% height=50%>


**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

```sql
SELECT m.product_name, COUNT(*) as total_purchases
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY total_purchases DESC
LIMIT 1;
```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/b11deffe-e859-4644-8824-83b2d1360d35" width=50% height=50%>


**5. Which item was the most popular for each customer?**

```sql
WITH customer_popularity AS (
  SELECT s.customer_id, m.product_name, COUNT(*) AS purchase_count,
         RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS item_rank
  FROM dbo.sales AS s
  JOIN dbo.menu AS m 
  ON s.product_id = m.product_id
  GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, purchase_count
FROM customer_popularity
WHERE item_rank = 1;
```

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/68aab655-29a1-4255-8a69-e7f017d86e47" width=50% height=50%>


**6. Which item was purchased first by the customer after they became a member?**

```sql

WITH ordered_sales AS (
  SELECT s.customer_id, s.order_date, m.product_name,
         ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
  FROM dbo.sales AS s
  JOIN dbo.menu AS m ON s.product_id = m.product_id
  JOIN dbo.members AS mem ON s.customer_id = mem.customer_id
  WHERE s.order_date > mem.join_date
)
SELECT customer_id, product_name, order_date
FROM ordered_sales
WHERE rank = 1;
```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/359fb49d-8f96-4776-be13-6a40a4177f25" width=50% height=50%>


**7. Which item was purchased just before the customer became a member?**

```sql

SELECT s.customer_id, m.product_name, MAX(s.order_date) AS last_purchase_date
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON s.product_id = m.product_id
JOIN dannys_diner.members AS mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id, m.product_name
ORDER BY customer_id;

```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/479e939e-dd78-477a-a203-e7fcdecb8c07" width=50% height=50%>


**8. What is the total items and amount spent for each member before they became a member?**

```sql

SELECT 
  sales.customer_id, 
  COUNT(sales.product_id) AS total_items, 
  SUM(menu.price) AS total_sales
FROM dannys_diner.sales 
INNER JOIN dannys_diner.members
  ON sales.customer_id = members.customer_id
  AND sales.order_date < members.join_date
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

```

**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/aebef089-4c0d-48f9-8c44-2eef47f70bcb" width=50% height=50%>


**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

```sql
WITH points_cte AS
(SELECT *, 
CASE WHEN product_name = 'sushi' THEN price * 20
	ELSE price * 10 END AS points
FROM dannys_diner.menu
)

SELECT 
  s.customer_id, 
  SUM(p.points) AS total_points
FROM points_cte AS p
JOIN dannys_diner.sales AS s
	ON p.product_id = s.product_id
GROUP BY s.customer_id
Order BY s.customer_id;

```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/5d756ea9-7bd1-4a23-b134-a9c4366e9f69" width=50% height=50%>




**10. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

```sql
WITH dates_cte AS (
  SELECT 
    customer_id, 
      join_date, 
      join_date + 6 AS valid_date, 
      DATE_TRUNC(
        'month', '2021-01-31'::DATE)
        + interval '1 month' 
        - interval '1 day' AS last_date
  FROM dannys_diner.members
)

SELECT 
  sales.customer_id, 
  SUM(CASE
    WHEN menu.product_name = 'sushi' THEN 2 * 10 * menu.price
    WHEN sales.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2 * 10 * menu.price
    ELSE 10 * menu.price END) AS points
FROM dannys_diner.sales
INNER JOIN dates_cte AS dates
  ON sales.customer_id = dates.customer_id
  AND sales.order_date <= dates.last_date
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

```
**Result:**

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/eea88ca4-457f-48b5-83d2-cdc16b70224a" width=50% height=50%>


View the case study [here](https://8weeksqlchallenge.com/case-study-1/) and my full solution [here](https://github.com/aolivacce/8-week-SQL-challenge/blob/main/Danny's%20Diner/SQLquery.sql)!
