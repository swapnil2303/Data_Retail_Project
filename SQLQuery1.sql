use sqlplacementproject

select * from Data_retail


--Check the column name and its data type
select column_name, Data_type from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Data_retail'

--Check any column has null value or not
select 
( case when (sum(case when product_ID is null then 1 else 0 end))>0 then 1 else 0 end) as is_product_ID_null,
( case when (sum(case when Product_Name is null then 1 else 0 end))>0 then 1 else 0 end) as is_product_Name_null,
( case when (sum(case when Category is null then 1 else 0 end))>0 then 1 else 0 end) as is_Category_null,
( case when (sum(case when Stock_Quantity is null then 1 else 0 end))>0 then 1 else 0 end) as is_Stock_Quantity_null,
( case when (sum(case when Supplier is null then 1 else 0 end))>0 then 1 else 0 end) as is_Supplier_null,
( case when (sum(case when Discount is null then 1 else 0 end))>0 then 1 else 0 end) as is_Discount_null,
( case when (sum(case when Rating is null then 1 else 0 end))>0 then 1 else 0 end) as is_Rating_null,
( case when (sum(case when Reviews is null then 1 else 0 end))>0 then 1 else 0 end) as is_Reviews_null,
( case when (sum(case when SKU is null then 1 else 0 end))>0 then 1 else 0 end) as is_SKU_null,
( case when (sum(case when Warehouse is null then 1 else 0 end))>0 then 1 else 0 end) as is_Warehouse_null,
( case when (sum(case when Return_Policy is null then 1 else 0 end))>0 then 1 else 0 end) as is_Return_Policy_null,
( case when (sum(case when Brand is null then 1 else 0 end))>0 then 1 else 0 end) as is_Brand_null,
( case when (sum(case when Supplier_contact is null then 1 else 0 end))>0 then 1 else 0 end) as is_Supplier_contact_null,
( case when (sum(case when Placeholder is null then 1 else 0 end))>0 then 1 else 0 end) as is_Placeholder_null,
( case when (sum(case when Price is null then 1 else 0 end))>0 then 1 else 0 end) as is_Price_null
from Data_retail

-- Data has no null value 

-- Cheack 1st five records from data
select Top 5 * from Data_retail
order by Product_ID asc

--Check last 5 records from data
select Top 5 * from Data_retail
order by Product_ID desc

--Cheacking random 5 records from data
select  Top 5 * from Data_retail
order by newid()

-- Checking the size of the dataset
select count(*) from Data_retail		-- Total 5000 rows present in dataset

-- Checking the number of column in dataset
select count(*) from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Data_retail'		-- Total 15 column present in dataset


-- checking unique product name from data
select distinct(PRODUCT_name) from Data_retail		-- 3 unique product names, Product A, Product B, Product C

-- checking unique category from data
select distinct(Category) from Data_retail			-- 3 unique category namely Clothing,Electronics,Home

-- checking unique Supplier from the data
select distinct(Supplier) from Data_retail			-- 3 unique supplier from the data Supplier X,Y,Z

-- checking unique sku from the data
select distinct(SKU) from Data_retail				-- 3 unique SKU namely sku001,002,003

-- checking unique Warehouse from the data
select distinct(Warehouse) from Data_retail				-- 3 unique Warehouse namely Warehouse A,B,C

-- checking unique Brands from the data
select distinct(Brand) from Data_retail				-- 3 unique Brand namely Brand X,Y,Z

-- checking unique Return_policy from the data
select distinct(Return_Policy) from Data_retail				-- 3 unique return policy namely 7 days, 15 days, 30 days

-- checking avg price of each product
select PRODUCT_Name, AVG(Price) as Avg_price_product from Data_retail
group by Product_Name

-- checking avg price of each category
select Category, AVG(Price) as Avg_price_product from Data_retail
group by Category

-- cheacking avg price of each product category wise
select Product_Name,Category, AVG(Price) as Avg_price_product from Data_retail
group by Product_Name,Category
order by Product_Name

--Queries
-- Identifies products with prices higher than the average price within their category.
with cte as 
(
select Category, avg(price) as avgprice from Data_retail
group by Category
)

select PRODUCT_ID,Price,d.Product_Name,c.Category,c.avgprice from Data_retail d
join cte c
on  d.Category=c.Category
where Price>avgprice


--Finding Categories with Highest Average Rating Across Products.
with avgrating as
(
select product_name,category, avg(Rating) as avgrating from Data_retail
group by Product_name,Category
),

maxavgrating as
(
select Product_Name,
	   category,
	   avgrating,
	   Row_number() OVER (partition by category ORDER BY avgrating DESC  ) AS Rank from avgrating
)

select Product_Name,category,avgrating from maxavgrating
where rank=1

--Find the most reviewed product in each warehouse
with product_review as 
(
select Product_Name,warehouse,count(Reviews) as most_reviewed from Data_retail
group by Product_Name,Warehouse
),
most_review as
(
select product_name,warehouse,most_reviewed,ROW_NUMBER()over(partition by warehouse order by most_reviewed desc) as ranks from product_review
)
select product_name,warehouse,most_reviewed from most_review
where ranks=1


-- find products that have higher-than-average prices within their category, along with their discount and supplier.
with cte as
(
select category, AVG(price) as avgprice from Data_retail
group by Category
)
select product_ID,PRODUCT_name,d.category,price,discount,supplier,c.avgprice from Data_retail d
join cte c
on c.Category=d.category
where Price>avgprice

--Query to find the top 2 products with the highest average rating in each category
with avg_rating as
(
select Category,avg(rating) as avg_rating from Data_retail
group by Category
),

top2 as
(
select product_ID,product_name,d.category,a.avg_rating,ROW_NUMBER()over(partition by d.category order by a.avg_rating desc) as ranks from Data_retail d
join avg_rating a
on d.Category=a.Category
)

select * from top2
where ranks<=2
order by Category

--Analysis Across All Return Policy Categories(Count, Avgstock, total stock, weighted_avg_rating, etc)
select count(product_ID) as product_count,return_policy from Data_retail
group by Return_Policy		

-- 1697 product has 07 day return policy
-- 1639 product has 15 days return policy
-- 1664 product has 30 days return policy

select category,return_policy,avg(stock_Quantity) as avgstock from Data_retail
group by Category,Return_Policy
order by Category

-- clothing with 7 days return policy having avg stock of 50
-- clothing with 15 days return policy having avg stock of 50
-- clothing with 30 days return policy having avg stock of 50
-- Electronics with 07 days return policy having avg stock of 50
-- Electronics with 15 days return policy having avg stock of 50
-- Electronics with 30 days return policy having avg stock of 48
-- Home with 07 days return policy having avg stock of 50
-- Home with 15 days return policy having avg stock of 47
-- Home with 30 days return policy having avg stock of 48


select category,return_policy,sum(stock_Quantity) as total_stock from Data_retail
group by Category,Return_Policy
order by Category

-- clothing with 7 days return policy having total stock of 27720
-- clothing with 15 days return policy having total stock of 28372
-- clothing with 30 days return policy having total stock of 30159
-- Electronics with 07 days return policy having total stock of 28493
-- Electronics with 15 days return policy having total stock of 26371
-- Electronics with 30 days return policy having total stock of 25527
-- Home with 07 days return policy having total stock of 29496
-- Home with 15 days return policy having total stock of 26001
-- Home with 30 days return policy having total stock of 26099

select category,return_policy,round(AVG(Rating),2) as weighted_avg_rating from Data_retail
group by Category,Return_Policy
order by Category

-- clothing with 7 days return policy having weighted_avg_rating of 2.94
-- clothing with 15 days return policy having weighted_avg_rating of 2.96
-- clothing with 30 days return policy having weighted_avg_rating of 3.02
-- Electronics with 07 days return policy having weighted_avg_rating of 2.98
-- Electronics with 15 days return policy having weighted_avg_rating of 3.00
-- Electronics with 30 days return policy having weighted_avg_rating of 2.95
-- Home with 07 days return policy having weighted_avg_rating of 3.03
-- Home with 15 days return policy having weighted_avg_rating of 2.99
-- Home with 30 days return policy having total stock of 2.96



