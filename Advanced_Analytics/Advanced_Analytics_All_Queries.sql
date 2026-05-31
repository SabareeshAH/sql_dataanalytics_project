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

/*
=========================================================================
E. Data Segmentation
=========================================================================
*/

-- 1.Segment the Products based on cost, count how many products fall into the cost segment
WITH CTE_r as 
(
SELECT product_id,
cost,
CASE WHEN cost<100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100 To 500'
	 WHEN cost BETWEEN 501 AND 1000 THEN '501 To 1000'
	 ELSE 'Above 1000'
END AS Cost_Range
FROM gold.dim_products
)

SELECT Cost_Range,
COUNT(product_id) AS Total_Products
FROM CTE_r
GROUP BY Cost_Range
ORDER BY COUNT(product_id) DESC;

--2. Group the Customers based on the Spending into 3 Segments, 
--	Segment 1: 'VIP' - Atleast 12 Months history and Spending greater than 5000
--	Segment 2: 'Regular' -  Atleast 12 Months history and Spending less than or equal to 5000
--	Segment 3: 'NEW' - Less than 12 months history
--then count the customers in each segment

WITH CTE_s AS
(
SELECT 
B.customer_id AS Customer_Id, 
SUM(A.sales_amount) AS Total_Customer_Sale,
MIN(A.order_date) AS First_Order,
MAX(A.order_date) AS Last_Order,
ROUND((MAX(order_date) - MIN(order_date)) / 30.4375,0) AS Life_Span,
CASE WHEN ROUND((MAX(order_date) - MIN(order_date)) / 30.4375,0) >= 12 AND SUM(A.sales_amount) > 5000 THEN 'VIP'
	 WHEN ROUND((MAX(order_date) - MIN(order_date)) / 30.4375,0) >= 12 AND SUM(A.sales_amount) <= 5000 THEN 'Regular'
	 ELSE 'NEW'
END AS Customer_Category
FROM
gold.fact_sales AS A LEFT JOIN 
gold.dim_customers AS B ON
A.customer_key = B.customer_key
GROUP BY B.customer_id
)

SELECT 
Customer_Category,
COUNT(Customer_Id) AS Customer_Count_Categorywise
FROM CTE_s
GROUP BY Customer_Category
ORDER BY COUNT(Customer_Id) DESC;

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