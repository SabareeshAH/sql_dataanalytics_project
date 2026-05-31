/*
=========================================================================
Database Exploration - Adavanced Analytics
=========================================================================
*/

/*
=========================================================================
C. Performance Analysis
=========================================================================
*/

--1. Analyze the product sale with average sales yearly
WITH SALES_CTE AS
(
SELECT
DATE_PART('YEAR', A.order_date) AS Order_year,
SUM(A.sales_amount) AS Current_Sales,
B.product_name AS Product
FROM
gold.fact_sales AS A 
LEFT JOIN gold.dim_products AS B
ON A.product_key = B.product_key
WHERE A.order_date IS NOT NULL
GROUP BY B.product_name, DATE_PART('YEAR', A.order_date)
ORDER BY B.product_name
)

SELECT
Order_year,
Product,
Current_Sales,
AVG(Current_sales) OVER(PARTITION BY Product) AS Avg_Product_Wise,
Current_Sales - AVG(Current_sales) OVER(PARTITION BY Product) AS Avg_Sale_Diff,
CASE WHEN Current_Sales - AVG(Current_sales) OVER(PARTITION BY Product) < 0 THEN 'Negative Average'
     WHEN Current_Sales - AVG(Current_sales) OVER(PARTITION BY Product) > 0 THEN 'Positive Average'
	 ELSE 'Average Detected'
END AS Avg_Sale_Diff_Category
FROM SALES_CTE;

--2. Analyze the product sale with previous year sales 
WITH SALES_CTE AS
(
SELECT
DATE_PART('YEAR', A.order_date) AS Order_year,
SUM(A.sales_amount) AS Current_Sales,
B.product_name AS Product
FROM
gold.fact_sales AS A 
LEFT JOIN gold.dim_products AS B
ON A.product_key = B.product_key
WHERE A.order_date IS NOT NULL
GROUP BY B.product_name, DATE_PART('YEAR', A.order_date)
ORDER BY B.product_name
)

SELECT
Order_year,
Product,
Current_Sales,
LAG(Current_Sales) OVER(PARTITION BY Product) AS Previous_Year_Sale,
Current_Sales - LAG(Current_Sales) OVER(PARTITION BY Product) AS Previous_Year_Sale_Diff,
CASE WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY Product) < 0 THEN 'Low Sales'
     WHEN Current_Sales - LAG(Current_sales) OVER(PARTITION BY Product) > 0 THEN 'High Sales'
	 ELSE 'No Change'
END AS Previous_Year_Sale_Category
FROM SALES_CTE;