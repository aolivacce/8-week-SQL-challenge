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

chart 
- Add a new ``` demographic ``` column using the following mapping for the first letter in the ``` segment```  values:

chart


