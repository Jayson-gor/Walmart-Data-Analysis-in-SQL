-- viewing data in sales table
SELECT * FROM walmart.sales;

-- Checking the format and description of columns in the sales table
desc walmart.sales_new;

-- creating a new table with my desired format
CREATE TABLE walmart.sales_new (
    `Invoice ID` VARCHAR(30) NOT NULL,
    `Branch` VARCHAR(30) NOT NULL,
    `City` VARCHAR(30) NOT NULL,
    `Customer type` VARCHAR(30) NOT NULL,
    `Gender` VARCHAR(10) NOT NULL,
    `Product line` VARCHAR(100) NOT NULL,
    `Unit price` DECIMAL(10, 2) NOT NULL,
    `Quantity` INT NOT NULL,
    `Tax 5%` DECIMAL(10, 4) NOT NULL,
    `Total` DECIMAL(10, 2) NOT NULL,
    `Date` DATE NOT NULL,
    `Time` TIMESTAMP NOT NULL,
    `Payment` VARCHAR(30) NOT NULL,
    `cogs` DECIMAL(10, 2) NOT NULL,
    `gross margin percentage` DECIMAL(11, 9) NOT NULL,
    `gross income` DECIMAL(10, 2) NOT NULL,
    `Rating` DECIMAL(2, 1) NOT NULL,
    PRIMARY KEY (`Invoice ID`)
);

-- viewing the new table
select * from sales_new;

-- matching date column format 
-- Update the data in the "Time" column to merge it with the "Date" column
UPDATE walmart.sales
SET `Time` = CONCAT(`Date`, ' ', `Time`);


-- Update the "Rating" column in the sales_new table to have 5 decimal places
UPDATE walmart.sales_new
SET `Rating` = ROUND(`Rating`, 5);

-- Update the "Rating" column in the sales table to have 5 decimal places
UPDATE walmart.sales
SET `Rating` = ROUND(`Rating`, 5);


-- Update the "Rating" column in the sales table to have 2 decimal places
UPDATE walmart.sales
SET `Rating` = ROUND(`Rating`, 2);


-- copying data from sales table to sales_new table
INSERT INTO walmart.sales_new SELECT * FROM walmart.sales;

-- note make sure the formating of the columns are aligned

-- description of the columns
desc walmart.sales_new;

-- viewing data in sales_new table
SELECT * FROM walmart.sales_new;

-- checking the number of rows available
SELECT COUNT(*) FROM walmart.sales_new;

-- checking the number of columns available:
SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'sales_new' AND table_schema = 'walmart';

select time from walmart.sales_new;


-- Time category using feature engineering 
SELECT
    time,
    CASE
        WHEN CAST(time AS TIME) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN CAST(time AS TIME) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN CAST(time AS TIME) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
    END AS time_category
FROM
    walmart.sales_new;

-- create a new column time_category
alter table sales_new add column time_category VARCHAR(20);

-- adding data to the new time_category column
update sales_new
set time_category =(
    CASE
        WHEN CAST(time AS TIME) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN CAST(time AS TIME) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        WHEN CAST(time AS TIME) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
    END
    );

select time_category from sales_new;

select date, dayname(date) from sales_new;

-- adding day_of_the_week column
alter table sales_new add day_of_the_week varchar(20);

update sales_new
set day_of_the_week = dayname(date);

select day_of_the_week from sales_new;

-- adding month name column
select date, monthname(date) from sales_new;
alter table sales_new add month_name varchar(20);

update sales_new
set month_name = monthname(date);

select month_name from sales_new;


-- How many unique cities does the data have?
select count(distinct City) from sales_new;
select distinct(City) from sales_new;

-- In which city is each branch?
SELECT branch, city
FROM sales_new
GROUP BY branch, city
LIMIT 0, 10000;

select branch, max(city) as city from sales_new
group by branch;


-- How many unique product lines does the data have?
select count(distinct `Product line`) as Number_of_product_line from sales_new;

-- What is the most common payment method?
select payment, count(payment) from sales_new
group by payment;

-- What is the most selling product line?
select `Product line`, count(`Product line`) as number_of_sales from sales_new
group by `Product line`
order by number_of_sales DESC;

-- What is the total revenue by month?
select month_name, sum(Total) as revenue
from sales_new
group by month_name
order by revenue DESC;

-- What month had the largest COGS?
select month_name, max(COGS) FROM sales_new
group by month_name
order by max(COGS) desc;

-- What product line had the largest revenue?
select `Product line`, sum(Total) as revenue
from sales_new
group by `Product line`
order by revenue DESC;

-- What is the city with the largest revenue?
select city, sum(Total) as revenue
from sales_new
group by city
order by revenue DESC;

-- What product line had the largest VAT?
select `Product line`, max(`Tax 5%`) as VAT
from sales_new
group by `Product line`
order by VAT DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
alter table sales_new add product_condition varchar(20);

update sales_new
set product_condition = (
SELECT
    CASE
        WHEN sum(Total) > avg(Total) THEN 'GOOD'
        ELSE 'BAD'
    END 
);

select product_condition from sales_new;
where product_condition = 'GOOD';

UPDATE sales_new
SET product_condition = NULL;

-- Which branch sold more products than average product sold?
select branch, sum(quantity) as product_sold
from sales_new
group by branch
having sum(quantity) > (select avg(quantity) from sales_new);


-- What is the most common product line by gender?
select `Product line`, Gender, count(Gender) as Number
from sales
group by `Product line`, Gender
order by Number DESC;

-- What is the average rating of each product line?
select `Product line`, avg(Rating)
from sales_new
group by `Product line`
order by avg(Rating) DESC;

-- Number of sales made in each time of the day per weekday
select time_category, count(*) as saless
from sales_new
group by time_category
order by saless DESC;

-- Which of the customer types brings the most revenue?
select `Customer type`, sum(Total) as revenue
from sales_new
group by `Customer type`
order by revenue DESC;


-- Which city has the largest tax percent/ VAT (Value Added Tax)?

select city, max(`Tax 5%`) as VAT
from sales_new
group by city
order by VAT DESC;

-- Which customer type pays the most in VAT?

select `Customer type`, sum(`Tax 5%`) as VAT
from sales_new
group by `Customer type`
order by VAT DESC;

-- How many unique customer types does the data have?
select count(distinct `Customer type`) 
from sales_new;

select distinct `Customer type`
from sales_new;

-- How many unique payment methods does the data have?
select distinct `Payment`
from sales_new;

-- What is the most common customer type?
select `Customer type`, count(*) as CNT
from sales_new
group by `Customer type`
order by CNT DESC;

-- Which customer type buys the most?
select `Customer type`, sum(Quantity) as most
from sales_new
group by `Customer type`
order by most DESC;

-- What is the gender of most of the customers?
select gender, count(*) as MST
from sales_new
group by gender
order by MST DESC;

-- What is the gender distribution per branch?

select branch, gender, count(gender) as number
from sales_new
group by branch, gender
order by number DESC;

-- Which time of the day do customers give most ratings?
select time_category, avg(Rating) as RATINGS
from sales_new
group by time_category
order by RATINGS DESC;

-- Which time of the day do customers give most ratings per branch?
select branch, time_category, avg(Rating) as RATINGS
from sales_new
group by branch,  time_category
order by RATINGS DESC;

-- Which day fo the week has the best avg ratings?
select day_of_the_week, avg(Rating) as BEST_RATING
from sales_new
group by day_of_the_week
order by BEST_RATING DESC;

-- Which day of the week has the best average ratings per branch?
-- for individual branch
select day_of_the_week, avg(Rating) as BEST_RATING
from sales_new
where branch = "c"
group by day_of_the_week
order by BEST_RATING DESC;