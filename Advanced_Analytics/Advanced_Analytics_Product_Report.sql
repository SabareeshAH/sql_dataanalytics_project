/*
=========================================================================
Database Exploration - Adavanced Analytics
=========================================================================
*/

/*
=========================================================================
f. Product Report
=========================================================================
Purpose: Report Consolidates key product metrics and behaviour

Highlights:
1. Gathers the essentail fields such as product names, category, subcategory, cost
2. Segments the product revenue into 3 categories 'High Performers', 'Mid Performers' and 'Low Performers'
3. Aggregrates the product Level Metrics:
	-> Total Orders
	-> Total Sales
	-> Total Quantity sold
	-> Total customers (unique)
	-> Average Selling Price
	-> Life Span (in Months)
4. Calculates the valuable KPIs
	-> Recency (months since last order)
	-> Average order revenue
	-> Average monthly spend

Final Export the Query result into a View
=========================================================================
*/
CREATE VIEW gold.product_report AS
WITH CTE_base AS(
/*A. Gathers the essentail fields*/
SELECT 
A.order_number AS Order_Number,
A.order_date AS Order_Date,
A.sales_amount AS Sales_Amount,
A.quantity AS Quantity,
A.customer_key AS Customer_Key,
B.product_key AS Product_Key,
B.product_id AS Product_Id,
B.product_number AS Product_Number,
B.category AS Product_Category,
B.subcategory AS Product_Subcategory,
B.cost AS Cost
FROM 
gold.fact_sales AS A LEFT JOIN gold.dim_products AS B
ON A.product_key = B.product_key
WHERE A.order_date IS NOT NULL
),
CTE_intermeidate AS(
/*B. Aggregrating the product Level Metrics*/
SELECT 
Product_Key,
Product_Id,
Product_Number,
Product_Category,
Product_Subcategory,
MAX(Order_Date) AS Last_Order_Date,
Cost,
COUNT(DISTINCT Order_Number) AS Total_Orders,
SUM(Sales_Amount) AS Total_Sales,
SUM(Quantity) AS Total_Quantities_Sold,
COUNT(DISTINCT Customer_Key) AS Total_Customers,
ROUND((MAX(Order_Date) - MIN(Order_Date))/30.4375, 0) AS LifeSpan_Months,
ROUND(AVG(Sales_Amount / NULLIF(Quantity, 0)), 2) AS Average_Selling_Price
FROM CTE_base
GROUP BY Product_Key, Product_Id, Product_Number, Product_Category, Product_Subcategory, Cost
)
SELECT 
Product_Key,
Product_Id,
Product_Number,
Product_Category,
Product_Subcategory,
Cost,
Total_Orders,
Total_Sales,
-- C. Segments the product revenue into 3 categories
CASE WHEN Total_Sales > 100000 THEN 'High Sales'
	 WHEN Total_Sales Between 25000 AND 100000 THEN 'Mid Sales'
	 ELSE 'Low Sales'
END AS Product_Sale_Category,
Total_Quantities_Sold,
Total_Customers,
LifeSpan_Months,
Average_Selling_Price,
-- D.KPI-1: Recency in Months
EXTRACT(YEAR FROM AGE(Last_Order_Date)) * 12 + EXTRACT(MONTH FROM AGE(Last_Order_Date)) AS Recency_Months,
-- D.KPI-2: Average Order Revenue
CASE WHEN Total_Orders = 0 THEN 0
     ELSE ROUND((Total_Sales / Total_Orders),2)
END AS Average_Order_Revenue,
-- D.KPI-3: Average Monthly Revenue
CASE WHEN LifeSpan_Months = 0 THEN Total_Sales
	 ELSE ROUND((Total_Sales / LifeSpan_Months),2)
END AS Average_Monthly_Revenue
FROM CTE_intermeidate;

--Checking the View
SELECT * FROM gold.product_report;