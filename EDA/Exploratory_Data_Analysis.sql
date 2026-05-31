
/*
=========================================================================
Database Exploration - EDA
=========================================================================
*/

-- Exploring all objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

--Exploring all columns in the database, table wise
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products';

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';

/*
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*** Table column can be 2 forms -> Dimensions and Measures ***

1. Dimesions = Category / Non - numerical columns, mainly useful for category, sub category grouping, not useful for numerical analysis. E.g. Product_name, category, country etc..
2. Measures = Numerical columns useful for aggregrate (SUM, COUNT, AVG) findings. E.g. Total_sales, amount, quantity etc...
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*
=========================================================================
Dimension Exploration
=========================================================================
*/

-- Exploring country value from customers table
SELECT DISTINCT(country) FROM gold.dim_customers;

--Exploring the categories and related divisions from products table
SELECT DISTINCT category, subcategory, product_name from gold.dim_products
ORDER BY category, subcategory, product_name;

/*
=========================================================================
Date Exploration
=========================================================================
*/

--Finding the Fisrt and last order date from sales table
SELECT MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date
FROM gold.fact_sales;

--Finding the sales range in years
SELECT MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATE_PART('year', AGE(MAX(order_date),  MIN(order_date))) AS Sales_range 
FROM gold.fact_sales;

--Finding the youngest and oldest customers froom customers table
SELECT MAX(birthdate) AS young_customer, 
DATE_PART('YEAR', AGE(NOW(), MAX(birthdate))) AS young_customer_age,
MIN(birthdate) AS old_customer,
DATE_PART('YEAR', AGE(NOW(), MIN(birthdate))) AS old_customer_age
FROM gold.dim_customers;

/*
=========================================================================
Measure Exploration
=========================================================================
*/

--Find the total sales
SELECT SUM(sales_amount) AS Total_Sales FROM gold.fact_sales;

--Find how many items sold
SELECT SUM(quantity) AS Total_Items_sold FROM gold.fact_sales;

--Find the Average selling price
SELECT ROUND(AVG(price),2) AS Average_Selling_Price FROM gold.fact_sales;

--Find the total number of orders
SELECT COUNT(DISTINCT order_number) AS Total_Order_Count FROM gold.fact_sales;

--Find the total number of products
SELECT COUNT(DISTINCT product_key) AS Total_Product_Count FROM gold.dim_products;

--Find the total number of customer
SELECT COUNT(DISTINCT customer_id) AS Total_Customer_Count FROM gold.dim_customers;

--Find the total number of customers placed order
SELECT COUNT(DISTINCT customer_key) AS Total_Customers_made_Order_Count FROM gold.fact_sales;

/* >>> Combining all the above query results as single report <<< */

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' AS measure_name, ROUND(AVG(price),2) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Order Count' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Product Count' AS measure_name, COUNT(DISTINCT product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customer Count' AS measure_name, COUNT(DISTINCT customer_id) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'Customers Placed Order' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales;

/*
=========================================================================
Magnitude Exploration

>>> Measure by dimension
=========================================================================
*/

--Find Total Customers by Country
SELECT country, COUNT(DISTINCT customer_id) AS Total_Customers_by_Country FROM gold.dim_customers
GROUP BY country
ORDER BY Total_Customers_by_Country DESC;

--Find Total Customers by Gender
SELECT gender, COUNT(DISTINCT customer_id) AS Total_Customers_by_Gender FROM gold.dim_customers
GROUP BY gender
ORDER BY Total_Customers_by_Gender DESC;

--Find Total Products by Category
SELECT category, COUNT(DISTINCT product_id) AS Total_Products_by_Category FROM gold.dim_products
GROUP BY category
ORDER BY Total_Products_by_Category DESC;

--Average Cost in each Category
SELECT category, ROUND(AVG(cost),2) AS Average_cost_each_category FROM gold.dim_products
GROUP BY category
ORDER BY Average_cost_each_category DESC;

--Total Revenue in each Category
SELECT B.category, SUM(A.sales_amount) AS Total_Revenue_each_category 
FROM gold.fact_sales A LEFT JOIN gold.dim_products B ON
A.product_key = B.product_key
GROUP BY B.category
ORDER BY Total_Revenue_each_category DESC;

--Total Revenue generated by each customer
SELECT B.customer_id, B.fisrt_name, B.last_name, SUM(A.sales_amount) AS Total_Revenue_each_customer 
FROM gold.fact_sales A LEFT JOIN gold.dim_customers B ON
A.customer_key = B.customer_key
GROUP BY B.customer_id, B.fisrt_name, B.last_name
ORDER BY Total_Revenue_each_customer DESC;

--Distribution of Sold items Across countries
SELECT B.country, SUM(A.quantity) AS Sold_Items_Distribution_Across_Countries 
FROM gold.fact_sales A LEFT JOIN gold.dim_customers B ON
A.customer_key = B.customer_key
GROUP BY B.country
ORDER BY Sold_Items_Distribution_Across_Countries DESC;

/*
=========================================================================
Ranking Analysis

>>> Ranking the Dimension by Measure to find Top N and Bottom N values
=========================================================================
*/

--Which 5 Products generate highest revenue
SELECT * FROM (
SELECT B.product_id, B.product_name, SUM(A.sales_amount) AS Revenue,
DENSE_RANK() OVER(ORDER BY SUM(A.sales_amount) DESC) AS Rank
FROM gold.fact_sales A LEFT JOIN
gold.dim_products B  ON 
A.product_key = B.product_key
GROUP BY B.product_id, B.product_name) 
WHERE Rank<=5;

--Top 5 Worst perform products in terms of sales
WITH CTE_1 AS (
SELECT B.product_id, B.product_name, SUM(A.sales_amount) AS Revenue,
DENSE_RANK() OVER(ORDER BY SUM(A.sales_amount)) AS Rank
FROM gold.fact_sales A LEFT JOIN
gold.dim_products B  ON 
A.product_key = B.product_key
GROUP BY B.product_id, B.product_name)

SELECT * FROM CTE_1 WHERE Rank<=5;

--Which 5 Product Categories generate highest revenue
SELECT * FROM (
SELECT B.category, SUM(A.sales_amount) AS Revenue,
DENSE_RANK() OVER(ORDER BY SUM(A.sales_amount) DESC) AS Rank
FROM gold.fact_sales A LEFT JOIN
gold.dim_products B  ON 
A.product_key = B.product_key
GROUP BY B.category) 
WHERE Rank<=5;

--Top 5 Worst perform product category in terms of sales
WITH CTE_1 AS (
SELECT B.category, SUM(A.sales_amount) AS Revenue,
DENSE_RANK() OVER(ORDER BY SUM(A.sales_amount)) AS Rank
FROM gold.fact_sales A LEFT JOIN
gold.dim_products B  ON 
A.product_key = B.product_key
GROUP BY B.category)

SELECT * FROM CTE_1 WHERE Rank<=5;

--Which 5 Product Sub Categories generate highest revenue
SELECT * FROM (
SELECT B.subcategory, SUM(A.sales_amount) AS Revenue,
DENSE_RANK() OVER(ORDER BY SUM(A.sales_amount) DESC) AS Rank
FROM gold.fact_sales A LEFT JOIN
gold.dim_products B  ON 
A.product_key = B.product_key
GROUP BY B.subcategory) 
WHERE Rank<=5;

--Top 5 Worst perform product category in terms of sales
WITH CTE_1 AS (
SELECT B.subcategory, SUM(A.sales_amount) AS Revenue,
DENSE_RANK() OVER(ORDER BY SUM(A.sales_amount)) AS Rank
FROM gold.fact_sales A LEFT JOIN
gold.dim_products B  ON 
A.product_key = B.product_key
GROUP BY B.subcategory)

SELECT * FROM CTE_1 WHERE Rank<=5;

--Find top 10 Customers with Highest Revenue
WITH CTE_2 AS (
SELECT B.customer_id, B.fisrt_name, B.last_name, SUM(A.sales_amount) AS Revenue,
DENSE_RANK() OVER(ORDER BY SUM(A.sales_amount) DESC) AS Rank_customers
FROM gold.fact_sales A LEFT JOIN
gold.dim_customers B  ON 
A.customer_key = B.customer_key
GROUP BY B.customer_id, B.fisrt_name, B.last_name)

SELECT * FROM CTE_2 WHERE Rank_customers<=10;

--Top 3 customers with lowest orders
WITH CTE_2 AS (
SELECT B.customer_id, B.fisrt_name, B.last_name, COUNT(DISTINCT A.order_number) AS Orders,
DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT A.order_number)) AS Rank_customers
FROM gold.fact_sales A LEFT JOIN
gold.dim_customers B  ON 
A.customer_key = B.customer_key
GROUP BY B.customer_id, B.fisrt_name, B.last_name)

SELECT * FROM CTE_2 WHERE Rank_customers<=3;