/*
=========================================================================
Database Exploration - Adavanced Analytics
=========================================================================
*/

/*
=========================================================================
f. Customer Report
=========================================================================
Purpose: Report Consolidates key customer metrics and behaviour

Highlights:
1. Gathers the essentail fields such as names, age and Transaction details
2. Segments the customer into 3 categories 'VIP', 'Regular', 'New'
3. Segments the customer based on Age group
4. Aggregrates the Customer Level Metrics:
	-> Total Orders
	-> Total Sales
	-> Total Quantity Purchased
	-> Total Products
	-> Life Span (in Months)
5. Calculates the valuable KPIs
	-> Recency (months since last order)
	-> Average value order
	-> Average monthly spend

Final Export the Query result into a View
=========================================================================
*/

CREATE VIEW gold.report_customers AS
/*A. Gathering the required details*/
WITH CTE_base AS(
SELECT 
A.order_number AS Order_Number,
A.product_key AS Product_Key,
A.order_date AS Order_Date,
A.sales_amount AS Sales_Amount,
A.quantity AS Quantity,
B.customer_id AS Customer_Id,
B.customer_number AS Customer_Number,
CONCAT(B.fisrt_name,' ',B.last_name) AS Customer_Name,
EXTRACT(YEAR FROM AGE(B.birthdate)) AS Customer_Age
FROM gold.fact_sales AS A LEFT JOIN gold.dim_customers AS B
ON A.customer_key = B.customer_key
WHERE A.order_date IS NOT NULL
),
/*B. Aggregrating the Customer Level Metrics */
CTE_intermeidate AS(
SELECT 
Customer_Name,
Customer_Id,
Customer_Number,
Customer_Age,
SUM(Sales_Amount) AS Total_Sales,
COUNT(DISTINCT Order_Number) AS Total_Orders_Placed,
SUM(Quantity) AS Total_Quantity_Purchased,
COUNT(DISTINCT Product_Key) AS Total_Products_Purchased,
MAX(Order_Date) AS Last_Order_Date,
ROUND((MAX(order_date) - MIN(order_date)) / 30.4375,0) AS LifeSpan_Months
FROM CTE_base
GROUP BY Customer_Name, Customer_Id, Customer_Number, Customer_Age)
/*C. Contains KPI Calculations with the Customer Segment and Age group*/
SELECT Customer_Name,
Customer_Id,
Customer_Number,
Customer_Age,
CASE WHEN Customer_Age >= 65 THEN 'Seniors'
	 WHEN Customer_Age BETWEEN 50 AND 64 THEN 'Old Adults'
	 WHEN Customer_Age BETWEEN 40 AND 49 THEN 'Mature Adults'
	 WHEN Customer_Age BETWEEN 30 AND 39 THEN 'Adults'
	 WHEN Customer_Age BETWEEN 23 AND 29 THEN 'Young Adults'
	 WHEN Customer_Age BETWEEN 17 AND 22 THEN 'Teenage'
	 ELSE 'Children'
END AS Customer_Age_Category,
LifeSpan_Months,
CASE WHEN LifeSpan_Months >= 12 AND Total_Sales > 5000 THEN 'VIP'
	 WHEN LifeSpan_Months >= 12 AND Total_Sales <= 5000 THEN 'Regular'
	 ELSE 'NEW'
END AS Customer_Sales_Category,
Total_Sales,
Total_Orders_Placed,
Total_Quantity_Purchased,
Total_Products_Purchased,
-- KPI-1: Recency in Months 
EXTRACT(YEAR FROM AGE(NOW(), Last_Order_Date)) * 12 + EXTRACT(MONTH FROM AGE(NOW(), Last_Order_Date)) AS Recency_Months,
-- KPI-2: Aveare Value Order (Total Sales / Total Orders)
CASE WHEN Total_Orders_Placed = 0 THEN 0
	 ELSE ROUND((Total_Sales / Total_Orders_Placed), 2)
END AS Average_Value_Order,
--KPI-3: Average Monthly Spend (Total Sales / No. of Months)
CASE WHEN LifeSpan_Months = 0 THEN Total_Sales
	 ELSE ROUND((Total_Sales / LifeSpan_Months), 2)
END AS Average_Monthly_Spend
FROM CTE_intermeidate;

--Checking the created view
SELECT * FROM gold.report_customers; 