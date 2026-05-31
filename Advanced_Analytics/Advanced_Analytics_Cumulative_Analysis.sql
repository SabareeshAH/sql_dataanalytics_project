/*
=========================================================================
Database Exploration - Adavanced Analytics
=========================================================================
*/

/*
=========================================================================
B. Cumulative Analysis
=========================================================================
*/

-- 1. Calculate the running sales per month in each year
SELECT 
Order_Year,
Order_Month,
Total_Sales,
SUM(Total_Sales) OVER(PARTITION BY Order_Year ORDER BY Order_Year, Order_Month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Running_Sum
FROM
(
SELECT DATE_PART('YEAR', order_date) AS Order_Year,
DATE_PART('MONTH', order_date) AS Order_Month, 
SUM(sales_amount) AS Total_Sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('YEAR', order_date), DATE_PART('MONTH', order_date)
) AS Sub_func;

-- 2. Calculate the moving average for each year
SELECT 
Order_Year,
Avg_Sales,
AVG(Avg_Sales) OVER(ORDER BY Order_Year) AS Moving_Average
FROM
(
SELECT DATE_PART('YEAR', order_date) AS Order_Year,
AVG(sales_amount) AS Avg_Sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_PART('YEAR', order_date)
) AS Sub_func;