-- How many unique nodes are there on the Data Bank system?

SELECT COUNT(DISTINCT node_id) 
FROM data_bank.customer_nodes;

-- What is the number of nodes per region?

SELECT r.region_name, COUNT(DISTINCT n.node_id) AS nodes_per_region
FROM data_bank.customer_nodes AS n
JOIN data_bank.regions AS r ON n.region_id = r.region_id
GROUP BY r.region_name;

-- How many customers are allocated to each region?

SELECT r.region_name, COUNT(DISTINCT n.node_id) AS nodes_per_region
FROM data_bank.customer_nodes AS n
JOIN data_bank.regions AS r ON n.region_id = r.region_id
GROUP BY r.region_name;

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
