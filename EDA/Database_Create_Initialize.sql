/*
=========================================================================
Create Database, Schema and Tables
=========================================================================

Purpose: This part of sql file / code involves creating a new database 
"EDA_DataAnalytics" database for our project and also involves creating
a schema gold with three analytics ready tables namely dim_customers, 
dim_products, fact_sales for the project.

Warning: Ensure that database and schemas are not existing already if so
you can make use of the existing one and skips this procedure. Again
creating of database and schemas with the same existing name results in 
warning or error.
*/

/*
======================================================================
Creating Database - EDA_DataAnalytics
======================================================================
*/

CREATE DATABASE "EDA_DataAnalytics";

SELECT current_database();

/*
======================================================================
Creating schema - gold
======================================================================
*/

CREATE SCHEMA gold;

/*
======================================================================
Creating the Table required for EDA
======================================================================

Table 1: gold.dim_customers
Table 2: gold.dim_products
Table 3: gold.fact_sales

*/

/* Creating DDL for Table 1: gold.dim_customers */
DROP TABLE IF EXISTS gold.dim_customers; 
CREATE TABLE gold.dim_customers(
	customer_key BIGINT,
	customer_id INT,
	customer_number VARCHAR(20),
	fisrt_name VARCHAR(25),
	last_name VARCHAR(25),
	country VARCHAR(50),
	martial_status VARCHAR(15),
	gender VARCHAR(15),
	birthdate DATE,
	create_date DATE
);

/* Creating DDL for Table 2: gold.dim_products */
DROP TABLE IF EXISTS gold.dim_products; 
CREATE TABLE gold.dim_products(
	product_key BIGINT,
	product_id INT,
	product_number VARCHAR(20),
	product_name VARCHAR(50),
	category_id VARCHAR(10),
	category VARCHAR(30),
	subcategory VARCHAR(50),
	maintenance VARCHAR(5),
	cost INT,
	product_line VARCHAR(15),
	start_date DATE
);

/* Creating DDL for Table 3: gold.fact_sales */
DROP TABLE IF EXISTS gold.fact_sales; 
CREATE TABLE gold.fact_sales(
	order_number VARCHAR(30),
	product_key BIGINT,
	customer_key BIGINT,
	order_date DATE,
	shipping_date DATE,
	due_date DATE,
	sales_amount BIGINT,
	quantity INT,
	price INT
);

/*
======================================================================
Data Insertion into Tables using Bulk Insertion
======================================================================
*/

/*Inserting data into Table 1: gold.dim_customers*/
TRUNCATE TABLE gold.dim_customers;
COPY gold.dim_customers(customer_key, customer_id, customer_number, fisrt_name,last_name, country, martial_status, gender, birthdate, create_date)
FROM 'C:\Users\Lenovo\Documents\Data Project\EDA\dataset\dim_customers.csv'
DELIMITER ','
CSV HEADER;

/*Inserting data into Table 1: gold.dim_products*/
TRUNCATE TABLE gold.dim_products;
COPY gold.dim_products(product_key, product_id, product_number, product_name, category_id, category, subcategory, maintenance, cost, product_line, start_date)
FROM 'C:\Users\Lenovo\Documents\Data Project\EDA\dataset\dim_products.csv'
DELIMITER ','
CSV HEADER;

/*Inserting data into Table 1: gold.fact_sales*/
TRUNCATE TABLE gold.fact_sales;
COPY gold.fact_sales(order_number, product_key, customer_key, order_date, shipping_date, due_date, sales_amount, quantity, price)
FROM 'C:\Users\Lenovo\Documents\Data Project\EDA\dataset\fact_sales.csv'
DELIMITER ','
CSV HEADER;

/*
======================================================================
Data Check
======================================================================
*/
SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;