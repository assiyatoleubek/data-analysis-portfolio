CREATE TABLE fact_sales (
sales_key INT PRIMARY KEY,
order_id INT,
product_key INT,
customer_key INT,
date_key INT,
quantity INT,
unit_price DECIMAL(10,2),
revenue DECIMAL(10,2)
);

CREATE TABLE dim_product (
product_key INT PRIMARY KEY,
product_id VARCHAR(50),
title TEXT,
author TEXT,
genre TEXT,
price DECIMAL(10,2)
);

CREATE TABLE dim_customer (
customer_key INT PRIMARY KEY,
customer_id VARCHAR(50),
name TEXT,
email TEXT,
loyalty_tier TEXT,
registration_date DATE
);

CREATE TABLE dim_date (
date_key INT PRIMARY KEY,
date DATE,
year INT,
quarter INT,
month INT,
month_name TEXT,
day_of_week TEXT
);


-- part 2

-- 1.Total revenue by genre 
SELECT 
    p.genre,
    SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_product p 
    ON f.product_key = p.product_key
GROUP BY p.genre
ORDER BY total_revenue DESC;

--2.Number of orders and total revenue per loyalty tier 
SELECT 
    c.loyalty_tier,
    COUNT(DISTINCT f.order_id) AS number_of_orders,
    SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY c.loyalty_tier
ORDER BY total_revenue DESC;

--3.Monthly total revenue for 2024
SELECT 
    d.month_name,
    SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY d.month, d.month_name
ORDER BY d.month;

--4.Top 3 best selling products 
SELECT 
    p.title,
    SUM(f.quantity) AS total_quantity
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY p.title
ORDER BY total_quantity DESC
LIMIT 3;

--5.Average order value overall
SELECT 
    SUM(revenue) / COUNT(DISTINCT order_id) AS avg_order_value
FROM fact_sales;

--6.Customers who have spent more than $100 
SELECT 
    c.name,
    SUM(f.revenue) AS total_spent
FROM fact_sales f
JOIN dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY c.name
HAVING SUM(f.revenue) > 100
ORDER BY total_spent DESC;


--part 3

ALTER TABLE dim_customer
ADD COLUMN effective_date DATE,
ADD COLUMN end_date DATE,
ADD COLUMN is_current BOOLEAN;

UPDATE dim_customer
SET 
effective_date = registration_date,
end_date = NULL,
is_current = TRUE;

UPDATE dim_customer
SET 
end_date = '2024-03-31',
is_current = FALSE
WHERE customer_id = 'C1001'
AND is_current = TRUE;

INSERT INTO dim_customer (customer_key, customer_id, name, email, loyalty_tier, registration_date, effective_date, end_date, is_current)
SELECT 5, customer_id, name, email, 'Platinum', registration_date, '2024-04-01', NULL, TRUE
FROM dim_customer
WHERE customer_id = 'C1001';


SELECT * FROM dim_customer;