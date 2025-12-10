--- #### Amazon Sales Data Analysis #####
-- Overview Of Dataset --
-- The data consists of sales record of three cities/branch in Myanmar 
-- which are Naypyitaw, Yangon, Mandalay which took place in first quarter of year 2019 --
-- the data consists of 1000 rows and 17 columns --


-- Objective of Project --
-- The major aim of this project is to gain insight into the sales data of Amazon --
-- and to understand the different factors that affect sales of the different branches --
#-------------------------------------------------------------------------------------------------------#

-- Data Wrangling--
-- step.1] creating database and importing data using table data import wizard --
-- Database Name

create database amazon;

--Create the Table

create table amazon_sales
(invoice_id varchar(30) primary key not null,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
vat float not null,
total decimal(10,2) not null,
date date not null,
time time not null,
payment_method varchar(20) not null,
cogs decimal(10,2) not null,
gross_margin_percentage float not null,
gross_income decimal(10,2) not null,
rating decimal(3,1) not null
);

drop table if exists amazon_sales;
select * from amazon_sales
limit 10;

--step.2] checking null value and data typ of columns --

select count(*) as count_of_null_value from amazon_sales
where null;

#-------------------------------------------------------------------------------------------------------#

-- Feature Engineering --
-- adding new columns timeofday,dayname,monthname by extracting values from date and time columns --
-- this will help you to anallyse sales based on month, day of week, time oof day --

alter table amazon
add time_of_day varchar(15) not null;

update amazon_sales set time_of_day =
case 
when hour(time) between 06 and 11 then 'Morning'
when hour(time) between 12 and 17 then 'Afternoon'
else 'Evening'
end;

alter table amazon_sales
add day_name varchar(10);

update amazon_sales set day_name =
(select  dayname(date));

alter table amazon_sales
add month_name varchar(10);

update amazon_sales set month_name =
(select monthname(date)); 

select * from amazon_sales limit 10;

#-------------------------------------------------------------------------------------------------------#

-- step.2] checking size of table,count of null values,unique values in columns --

select count(*) as total_columns from information_schema.columns
where table_name='amazon_sales';

select count(*) as total_rows from amazon_sales;

select count(*) from amazon_sales
where null;

-- step.3] checking unique value in each categorical column --

select distinct(branch) branch from amazon_sales;
select distinct(city) city from amazon_sales;
select distinct(customer_type) customer_type from amazon_sales;
select distinct(gender) gender from amazon_sales;
select distinct(product_line) product_line from amazon_sales;
select distinct(payment_method) payment_method from amazon_sales;

#-------------------------------------------------------------------------------------------------------#

-- Answering Questions --

-- 1. What is the count of distinct cities in the dataset?
select count(distinct(city)) from amazon_sales;

-- 2. For each branch, what is the corresponding city?
select distinct(city), branch from amazon_sales;

-- 3. What is the count of distinct product lines in the dataset?
select count(distinct(product_line)) from amazon_sales; 

-- 4. Which payment method occur most frequently?
select payment_method,count(*) as occurance from amazon_sales
group by payment_method
order by occurance desc;

-- 5.Which product lines has the highest sales?
select product_line,sum(quantity) as highest_sale from amazon_sales
group by product_line
order by highest_sale desc;

-- 6.How much revenue is generated each month?
select * from amazon_sales
select extract(month from date),sum(total) as monthly_revenue from amazon_sales
group by date
order by monthly_revenue;

-- 7.Which product line generated the highest revenue?
select product_line,sum(total) as total_revenue 
from amazon_sales
group by product_line
order by total_revenue;

-- 8.In which city was the highest revenue recorded?
select city,sum(total) as highest_revenue from amazon_sales
group by city
order by highest_revenue desc;

-- 10. Which product line incurred the highest Value Added Tax?
select product_line,max(vat) as highest_vat from amazon_sales
group by product_line
order by highest_vat desc;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line,sum(total) as revenue,
case
when sum(total)>(select sum(total)/count(distinct(product_line)) from amazon_sales) then 'Good'
else 'Bad'
end performance
from amazon_sales
group by product_line;

-- 12.Identify the branch that exceeded the average number of products sold.
select * from amazon_sales
select branch,sum(quantity) as product_sold from amazon_sales
group by branch
having product_sold > (select sum(quantity)/count(distinct branch) as avg_quantity from amazon_sales);

-- 13. Which product line is most frequently associated with each gender?

with new as 
(select gender, product_line, count(*) as count from amazon_sales
group by gender, product_line),

max_count as 
(select max(count) from new group by gender)

select * from new 
where count in (select * from max_count) limit 2;

-- 14. Calculate the average rating for each product line.
select * from amazon_sales;
select  product_line,avg(rating) as avg_rating 
from amazon_sales
group by product_line
order by avg_rating desc;

-- 15. Count the sales occurrences for each time of day on every weekday.
select extract(day from date) as day_name,time as each_time,count(*) sales
from amazon_sales
group by day_name
order by field(day_name, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'), 
field(time_of_day, 'Morning', 'Afternoon', 'Evening');

-- 16. Identify the customer type contributing the highest revenue.
select customer_type,sum(total) as highest_revenue 
from amazon_sales
group by customer_type
order by highest_revenue desc;

-- 17. Determine the city with the highest VAT percentage.
select city,max(vat) as vat_percentage from amazon_sales
group by city
order by vat_percentage desc;

-- 18. Identify the customer type with the highest VAT payments.
select customer_type,max(vat) as highest_vat from amazon_sales
group by customer_type
order by highest_vat desc;

-- 19. What is the count of distinct customer types in the dataset?
select count(distinct(customer_type)) as customer_count 
from amazon_sales;

-- 20. What is the count of distinct payment methods in the dataset?

select count(distinct(payment_method)) from amazon_sales;

-- 21. Which customer type occurs most frequently?
select customer_type,count(*) as count 
from amazon_sales
group by customer_type
order by count desc;

-- 22. Identify the customer type with the highest purchase frequency.
select customer_type,sum(total) as highest_frequency
from amazon_sales
group by customer_type
order by highest_frequency desc;

-- 23. Determine the predominant gender among customers.
select gender,count(*) as count from amazon_sales
group by gender
order by count desc;

-- 24. Examine the distribution of genders within each branch. 
select branch,gender,count(*) as count 
from amazon_sales
group by branch.gender
order by branch,gender;

-- 25. Identify the time of day when customers provide the most ratings.
select * from amazon_sales
select extract(day from date) as time_of_day,count(rating) as rating_count
from amazon_sales
group by time_of_day
order by rating_count;

-- 26. Determine the time of day with the highest customer ratings for each branch.
select branch,extract(day from date) as time_of_day, max(rating) highest_rating from amazon_sales
group by branch, time_of_day
having highest_rating = (select max(x.max) from (select branch, time_of_day, max(rating) max from amazon_sales
group by branch, time_of_day) as x where x.branch= amazon_sales.branch)
order by branch;



#-------------------------------------------------------------------------------------------------------#

-- Key Findings from Amazon Sales Dataset --

-- #### Product Analysis: ###

-- Highest Sales Product Line: Electronic Accessories (Units Sold:971) --
-- Highest Revenue Product Line: Food and Beverages ($ 56144.96)--
-- Lowest Sales Product Line: Health and Beauty (Unit Sold: 854) --
-- Lowest Revenue Product Line: Health and Beauty ($ 49193.84) --

-- #### Sales Analysis: ####

-- Month With Highest Revenue: January ($ 116292.11) --
-- City & Branch With Highest Revenue: Naypyitaw[C] ($ 110568.86)--
-- Month With Lowest Revenue: February ($ 97219.58) --
-- City & Branch With Lowest Revenue: Mandalay[B] ($ 106198.00) --
-- Peak Sales Time Of Day: Afternoon --
-- Peak Sales Day Of Week: Saturday --

-- #### Customer Analysis: ####

-- Most Predominant Gender: Female --
-- Most Predominant Customer Type: Member --
-- Highest Revenue Gender: Female ($ 167883.26) --
-- Highest Revenue Customer Type: Member ($ 164223.81) --
-- Most Popular Product Line (Male): Health and Beauty --
-- Most Popular Product Line (Female): Fashion Accessories --
-- Distribution Of Members Based On Gender: Male(240) Female(261) --
-- Sales Male: 2641 units --
-- Sales Female: 2869 units --
-- #-------------------------------------------------------------------------------------------------------#

-- #Thank You#