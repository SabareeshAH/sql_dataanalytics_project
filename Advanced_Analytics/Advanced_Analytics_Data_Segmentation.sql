/*
=========================================================================
Database Exploration - Adavanced Analytics
=========================================================================
*/

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