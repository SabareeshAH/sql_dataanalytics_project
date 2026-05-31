# Data Analytics Using PostgreSQL

## Overview

This project focuses on performing comprehensive **Data Analytics** on a sales dataset using **PostgreSQL** and **pgAdmin**. The analysis is divided into two major phases:

1. **Exploratory Data Analysis (EDA)**
2. **Advanced Analytics**

The dataset was sourced from a previously developed Data Warehouse project and consists of customer, product, and sales data. The primary objective of this project is to extract meaningful business insights, identify trends, evaluate performance, and support data-driven decision-making through SQL-based analytical techniques.

---

## Project Objectives

* Understand the structure and quality of the data.
* Explore dimensions, measures, and business entities.
* Analyze customer, product, and sales performance.
* Identify trends and patterns over time.
* Perform segmentation and proportional analysis.
* Generate analytical reports using SQL queries.

---

## Technology Stack

| Component      | Technology             |
| -------------- | ---------------------- |
| Database       | PostgreSQL             |
| Query Tool     | pgAdmin                |
| Language       | SQL                    |
| Dataset Source | Data Warehouse Project |

---

## Dataset Description

The analysis is performed on the final curated dataset extracted from a Data Warehouse project.

### 1. dim_customers

Contains customer-related information.

**Sample Attributes:**

* customer_id
* customer_name
* gender
* city
* country
* birthdate

---

### 2. dim_products

Contains product-related information.

**Sample Attributes:**

* product_id
* product_name
* category
* subcategory
* cost

---

### 3. fact_sales

Contains transactional sales data.

**Sample Attributes:**

* sales_id
* customer_id
* product_id
* order_date
* quantity
* sales_amount
* price

---

## Database Schema

The project follows a Star Schema structure:

```text
                dim_customers
                       |
                       |
                       |
dim_products ---- fact_sales
```

* Dimension tables provide descriptive information.
* Fact table stores transactional sales records.
* Foreign key relationships connect dimensions to facts.

---

# Exploratory Data Analysis (EDA)

The first phase focuses on understanding the data and identifying key business metrics.

## 1. Database Exploration

* Identified available tables.
* Examined schema structures.
* Validated relationships between tables.
* Verified data availability and consistency.

### Key Activities

* Listing tables
* Inspecting columns
* Understanding primary and foreign keys

---

## 2. Dimension Exploration

Analyzed categorical attributes from dimension tables.

### Examples

* Customer distribution by country
* Product distribution by category
* Brand analysis

---

## 3. Date Exploration

Analyzed temporal aspects of the sales data.

### Examples

* First transaction date
* Latest transaction date
* Total sales duration
* Yearly and monthly activity

---

## 4. Measure Exploration

Investigated quantitative business metrics.

### Measures Analyzed

* Total Sales
* Total Profit
* Quantity Sold
* Average Order Value

---

## 5. Magnitude Analysis

Measured the scale of business operations across dimensions.

### Examples

* Sales by country
* Sales by product category
* Sales by customer segment

---

## 6. Ranking Analysis

Ranked entities based on business performance.

### Examples

* Top Customers
* Top Products
* Top Categories
* Highest Revenue Generators

---

# Advanced Analytics

The second phase focuses on deriving actionable insights and identifying business trends.

---

## 1. Change Over Time Analysis

Evaluated business performance across different time periods.

### Examples

* Monthly Sales Trends
* Year-over-Year Growth
* Revenue Trends

### Insights Generated

* Seasonal patterns
* Growth opportunities
* Performance fluctuations

---

## 2. Cumulative Analysis

Calculated running totals to evaluate business growth.

### Examples

* Running Sales Total
* Cumulative Revenue
* Progressive Order Volume

### Benefits

* Growth tracking
* Long-term trend analysis

---

## 3. Performance Analysis

Compared actual performance against benchmarks.

### Examples

* Product Performance
* Customer Performance
* Category Performance

### KPIs

* Revenue
* Profit
* Quantity Sold

---

## 4. Part-to-Whole (Proportional Analysis)

Measured contribution percentages.

### Examples

* Category Contribution to Total Sales
* Country Contribution to Revenue
* Customer Contribution Analysis

### Outcome

Identified major contributors driving business growth.

---

## 5. Data Segmentation

Grouped data into meaningful business segments.

### Examples

* High-Value Customers
* Medium-Value Customers
* Low-Value Customers

### Benefits

* Customer targeting
* Business strategy development
* Personalized marketing opportunities

---

## 6. Data Reporting

Created analytical reports for business stakeholders.

### Reports View Included

* Sales Performance Report
* Product Performance Report

### Objectives

* Support decision-making
* Monitor business performance
* Identify growth opportunities

---
## Query Results

Advanced Analytics query results screenshots are attached as proof under results folder 

---
# Key SQL Concepts Used

The project extensively utilizes PostgreSQL analytical capabilities.

## SQL Techniques

* SELECT Statements
* JOIN Operations
* Aggregate Functions
* GROUP BY
* ORDER BY
* CASE Statements
* Common Table Expressions (CTEs)
* Subqueries
* Window Functions
* Date Functions
* Ranking Functions

---

# Business Insights Generated

The project enables stakeholders to:

* Identify top-performing products and customers.
* Understand sales trends over time.
* Measure category and segment contributions.
* Track cumulative business growth.
* Monitor key performance indicators.
* Support strategic decision-making using data.

---

# Project Structure

```text
Data-Analytics-Project/
│
├── Advanced_Analytics/
│   ├── advanced_analytics.sql
|
├── Dataset/
│   ├── dim_customers.csv
│   ├── dim_products.csv
│   ├── fact_sales.csv
|
├── Results/
|
├── EDA/
│   ├── exploratory_data_analysis.sql
│
└── README.md
```

---

# Learning Outcomes

Through this project, the following skills were developed:

* SQL Query Writing
* PostgreSQL Database Analysis
* Data Exploration Techniques
* Business Analytics
* Window Functions
* Data Segmentation
* Performance Measurement
* Reporting and Insight Generation

---

## Conclusion

This project showcases end-to-end data analytics using PostgreSQL on customer, product, and sales data sourced from a Data Warehouse. Through Exploratory Data Analysis (EDA) and Advanced Analytics techniques, including trend analysis, performance evaluation, segmentation, and reporting, the project transforms raw data into actionable business insights. It demonstrates strong SQL expertise, analytical problem-solving, and the ability to support data-driven decision-making.
