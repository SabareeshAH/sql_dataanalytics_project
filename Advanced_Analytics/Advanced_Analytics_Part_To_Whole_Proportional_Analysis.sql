/*
=========================================================================
Database Exploration - Adavanced Analytics
=========================================================================
*/

/*
=========================================================================
D. Part to Whole (Proportional Analysis)
=========================================================================
*/

-- 1.Which category contribute most to the sales
with Category_Sales_CTE AS
(
SELECT B.category AS Category,
SUM(A.sales_amount) AS Total_Sales
FROM
gold.fact_sales AS A LEFT JOIN gold.dim_products AS B
ON A.product_key = B.product_key
GROUP BY B.category
)

SELECT 
Category,
Total_Sales,
SUM(Total_Sales) OVER() AS Overall_Sales_Categorywise,
CONCAT(ROUND((Total_Sales / SUM(Total_Sales) OVER()) * 100, 2), '%') AS Sales_Distribution_Percent
FROM Category_Sales_CTE
ORDER BY Total_Sales DESC;

-- 2.Which country bought most quantities from the sales also calculate sales contribution countrywise
WITH Country_Sale_CTE AS 
(
SELECT B.country AS Country,
SUM(A.sales_amount) AS Total_Sales,
SUM(A.quantity) AS Total_Quantities
FROM gold.fact_sales AS A LEFT JOIN
gold.dim_customers AS B ON
A.customer_key = B.customer_key
GROUP BY B.country
)

SELECT Country,
Total_Sales,
SUM(Total_Sales) OVER() AS Overall_Sales,
CONCAT(ROUND((Total_Sales / SUM(Total_Sales) OVER()) * 100, 2), '%') AS Sale_Distribution_Countrywise,
Total_Quantities,
SUM(Total_Quantities) OVER() AS Overall_Quantity,
CONCAT(ROUND((Total_Quantities / SUM(Total_Quantities) OVER()) * 100, 2), '%') AS Quantities_Distribution_Countrywise
FROM Country_Sale_CTE
ORDER BY Total_Quantities DESC, Total_Sales DESC;