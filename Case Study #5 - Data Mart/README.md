## Case Study #5: Data Mart 

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/2fad8946-f9d5-4a62-86a8-3534b3ad61a8" width=40% height=40%>

## Table of Contents 

  - [Business Task](#business-task)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Questions and Solutions](#questions-and-solutions)

## Business Task 
Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question he wants you to help him answer are the following:

- What was the quantifiable impact of the changes introduced in June 2020?
- Which platform, region, segment and customer types were the most impacted by this change?
- What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?

## Entity Relationship Diagram 

For this case study there is only a single table: ``` data_mart.weekly_sales ```

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/3f2deafb-0b36-449f-9a97-eb95b818303d" width=40% height=40%>

## Questions and Solutions 

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

- Convert the ``` week_date ``` to a ``` DATE``` format

- Add a ``` week_number ``` as the second column for each ```week_date value``` , for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

- Add a ``` month_number```  with the calendar month for each ``` week_date value ``` as the 3rd column

- Add a ``` calendar_year ``` column as the 4th column containing either 2018, 2019 or 2020 values

- Add a new column called ``` age_band ``` after the original ``` segment ``` column using the following mapping on the number inside the ``` segment ``` value

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/6b8e6ac4-99d2-4f4b-bf67-ffcbdbb9f96f" width=20% height=20%>

- Add a new ``` demographic ``` column using the following mapping for the first letter in the ``` segment```  values:

<img src="https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/53600a9a-6218-493b-b314-9f863e60a66d" width=20% height=20%>


- Ensure all ``` null ``` string values with an ``` "unknown" ``` string value in the original ``` segment ``` column as well as the new ``` age_band ``` and ``` demographi c``` columns

- Generate a new ``` avg_transaction column``` as the ``` sales ``` value divided by ``` transactions ``` rounded to 2 decimal places for each record

**Let's clean this data!**
``` sql

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMP TABLE clean_weekly_sales AS (
SELECT
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
  region, 
  platform, 
  segment,
  CASE 
    WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
    ELSE 'unknown' END AS age_band,
  CASE 
    WHEN LEFT(segment,1) = 'C' THEN 'Couples'
    WHEN LEFT(segment,1) = 'F' THEN 'Families'
    ELSE 'unknown' END AS demographic,
  transactions,
  ROUND((sales::NUMERIC/transactions),2) AS avg_transaction,
  sales
FROM data_mart.weekly_sales

);



```

**Let's take a peak at the data:**

![image](https://github.com/aolivacce/8-week-SQL-challenge/assets/72052149/b3efa78a-62c8-457f-9dfa-578a629810c6)

## B. Data Exploration 

1. What day of the week is used for each week_date value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What is the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which age_band and demographic values contribute the most to Retail sales?
9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

