--------------------------------
--CASE STUDY #1: DANNY'S DINER--
     Tool used:PostgreSQL
--------------------------------

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
SELECT *
FROM dbo.members;

SELECT *
FROM dbo.menu;

SELECT *
FROM dbo.sales;
 
 --------------------
 Case Study Questions
 --------------------

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, sum(price) AS total_sales
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id; 

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT(order_date))
FROM dbo.sales

-- 3. What was the first item from the menu purchased by each customer?

with ordered_sales AS ( 
SELECT customer_id, order_date, product_name,
ROW_NUMBER OVER(PARTITION BY customer_id
                ORDER BY order_date) AS rank
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id)

SELECT customer_id, product_name, order_date
FROM ordered_sales
WHERE rank = 1
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, COUNT(*) 
FROM dbo.sales AS s
JOIN dbo.menu AS m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY total_purchases DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

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

                             
-- 6. Which item was purchased first by the customer after they became a member?

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

-- 7. Which item was purchased just before the customer became a member?

SELECT s.customer_id, m.product_name, MAX(s.order_date) AS last_purchase_date
FROM dbo.sales AS s
JOIN dbo.menu AS m ON s.product_id = m.product_id
JOIN dbo.members AS mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
    s.customer_id,
    COUNT(*) AS total_items,
    SUM(s.price) AS total_amount_spent
FROM
    dbo.sales AS s
JOIN
    dbo.members AS mem ON s.customer_id = mem.customer_id
WHERE
    s.order_date < mem.join_date
GROUP BY
    s.customer_id;
    
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH points_cte AS
(
	SELECT *, 
		CASE WHEN product_name = 'sushi' THEN price * 20
		ELSE price * 10 END AS points
	FROM menu
)

SELECT 
  s.customer_id, 
  SUM(p.points) AS total_points
FROM points_cte AS p
JOIN sales AS s
	ON p.product_id = s.product_id
GROUP BY s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

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
