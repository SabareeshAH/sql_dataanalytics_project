/*
=========================================================================
Database Exploration - Adavanced Analytics
=========================================================================
*/

/*
=========================================================================
A. Changes Over Time
=========================================================================
*/

-- 1. Total Sales by year
SELECT DATE_PART('YEAR', order_date) AS Order_Year, SUM(sales_amount) AS Total_Sales 
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('YEAR', order_date)
ORDER BY SUM(sales_amount) DESC;

-- 2. Total Sales by month
SELECT DATE_PART('MONTH', order_date) AS Order_Month, SUM(sales_amount) AS Total_Sales 
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('MONTH', order_date)
ORDER BY SUM(sales_amount) DESC;

-- 3. Total Sales by month for each specific year
SELECT DATE_PART('YEAR', order_date) AS Order_Year,
DATE_PART('MONTH', order_date) AS Order_Month,
SUM(sales_amount) AS Total_Sales,
COUNT(DISTINCT customer_key) AS Total_Customer,
SUM(quantity) AS Total_Quantities_Sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('YEAR', order_date), DATE_PART('MONTH', order_date)
ORDER BY SUM(sales_amount) DESC;