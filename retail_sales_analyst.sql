-- SQL Retail Sales Analysis - P1

create database retail_sales_analyst;
use retail_sales_analyst;

drop table if exists retail_sales;
create table retail_sales(
transactions_id int primary key,
sale_date date,
sale_time time,
customer_id int,
gender varchar(15),
age int,
category varchar(15),
quantity int,
price_per_unit float,
cogs float,
total_sale float
);
select count(*) from retail_sales;

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
select * from retail_sales where sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022

select category, sum(quantity) as total_quantity
from retail_sales
where
    category = 'Clothing'
    and quantity > 10
    -- and sale_date between '2022-11-01' and '2022-11-30'
    and DATEDIFF('2022-11-01', '2022-11-30')
group by
    category;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select
    category,
    sum(total_sale) as total_sales,
    COUNT(*) as total_orders
from retail_sales
group by
    category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select category, round(avg(age), 2) as avg_age
from retail_sales
where
    category = 'beauty'
group by
    category;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from retail_sales where total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select
    category,
    gender,
    count(transactions_id) as total_transaction
from retail_sales
group by
    category,
    gender
order by total_transaction desc;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT year, month, avg_sale, `rank`
FROM (
        SELECT YEAR(sale_date) AS year, MONTH(sale_date) AS month, ROUND(AVG(total_sale), 2) AS avg_sale, RANK() OVER (
                PARTITION BY
                    YEAR(sale_date)
                ORDER BY AVG(total_sale) DESC
            ) AS `rank`
        FROM retail_sales
        GROUP BY
            YEAR(sale_date), MONTH(sale_date)
    ) AS t1
WHERE
    `rank` = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
select customer_id, sum(total_sale) as total_sale
from retail_sales
group by
    customer_id
order by total_sale desc
limit 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select category, count(distinct customer_id) as unique_customer
from retail_sales
group by
    category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
select
    transactions_id,
    sale_date,
    sale_time,
    category,
    CASE
        WHEN hour(sale_time) < 12 THEN 'morning'
        WHEN hour(sale_time) BETWEEN 12 and 17  THEN 'afternoon'
        ELSE 'evening'
    END as shift
from retail_sales
limit 10;

-- also find total orders along the shift
with
    hourly_sales as (
        select
            transactions_id,
            sale_date,
            sale_time,
            category,
            CASE
                WHEN hour(sale_time) < 12 THEN 'morning'
                WHEN hour(sale_time) BETWEEN 12 and 17  THEN 'afternoon'
                ELSE 'evening'
            END as shift
        from retail_sales
    )
select shift,count(*) as total_sales from hourly_sales group by shift;