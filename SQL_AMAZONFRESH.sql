create database Amazon_Fresh;
use Amazon_Fresh;

#TASK 3.1 Retrive all customers from a speecific Place

select * from customers;

select * from customers
where state = "Florida";

#TASK 3.2 Retrive all products under the "Fruits" category

select * from products;

select * from products
where category = "Fruits";
#AFTER NORMALIZATION
select * from products
where categoryid = 1;

#DDL constraints
# Task 4 Recreate the Customers table with the specified constraints

CREATE TABLE New_Customers (
    CustomerID INT PRIMARY KEY,                 #Primary Key constraint
    Name VARCHAR(255) UNIQUE NOT NULL,          #Unique constraint for Name
    Age INT NOT NULL CHECK (Age > 18),          #Age must be greater than 18 and cannot be NULL
    Gender VARCHAR(10),  
    City VARCHAR(100),  
    State VARCHAR(100),  
    Country VARCHAR(100),  
    SignUpDate DATE,  
    PrimeMember BOOLEAN  
);

#Output for both the possible cases

insert into New_Customers (CustomerID, Name, Age, Gender, City, State, Country, SignUpDate, PrimeMember)
VALUES (1001, 'John Doe', 25, 'Male', "Brooklyn", "NY", "USA", '2024-01-01', TRUE);

select * from new_customers;

insert into New_Customers (CustomerID, Name, Age, Gender, City, State, Country, SignUpDate, PrimeMember)
VALUES (1002, 'John Doe', 17, 'Male', "Brooklyn", "NY", "USA", '2024-01-01', TRUE);                                    #Constraint is violated

#Task 5 Insert 3 new rows into the Products table using INSERT statements(DML)

select * from products;

insert into products(ProductID,Productname,Category,SubCategory,priceperunit,StockQuantity,SupplierID)
values (12001, "Farm Apple", "Fruits", "Sub-fruits-4", 308, 150, 1000051),
(12051, "Meat Mash", "Meat", "Sub-Meat-1", 765, 100, 1234512),
(15501, "Snackzo", "Snacks", "Sub-Snacks-1", 251, 547, 1887641);

select * from products;

#Task 6 -Update the stock quantity of a product where ProductID matches a specific ID

update Products
set stockquantity = 120
where productId = 12001;

#Task 7- Delete a supplier from the Suppliers table where their city matches a specific value

select * from suppliers;

delete from suppliers
where city="New James";

select * from suppliers where city="New James";

#TASK 8 Sql constraints(reviews between 1 to 5, PrimeMember column in the Customers table to default NO)

update customers														    #since primemember column was by default in text datatype, to change it to boolean/tinyint(1)
set primemember=
	case
    when primemember="yes" then 1
	when primemember="no" then 0
    else 0
    end;

alter table customers 
modify column PrimeMember 
TINYINT(1) NOT NULL DEFAULT 0;

alter table customers													#PrimeMember column in the Customers table to default NO
alter column primemember
set default 0; 

#Altering table reviews

alter table Reviews
add constraint check_rating check (rating BETWEEN 1 AND 5);

insert into reviews(reviewID,productid,customerid,rating,reviewtext)
values(21676371,50000001,1000123,6,"Exceellent");						#Constraint is violated

#TASK 9- Clauses and Aggregations(where orders placed after 2024-01-01,having products average ratings greater than 4,group by & order rank prducts by total sales)

select * from orders
where orderdate > '2024-01-01';

select productID, avg(rating) as Average_Rating 
from reviews
group by productID 
having avg(rating) > 4;

select
p.ProductID,
p.ProductName,
sum(od.Quantity*(od.Unitprice-od.discount)) as Total_sales
from order_details od
join products p on od.ProductID = p.ProductID
group by p.ProductID,p.ProductName
Order by Total_sales desc;

#Task 10: Identifying High-Value Customers based on their total spending

#Calculating each customer's total spending,Ranking them, Identify customers who have spent more than 5,000

select 
o.customerID,c.name,
sum(o.orderamount) as Total_Spending
from orders o
join customers c on o.CustomerID = c.CustomerID
group by c.name,o.CustomerID
having total_Spending > 5000
order by total_spending desc;


#Task 11 Complex Aggregations and Joins

#Join the Orders and OrderDetails tables to calculate total revenue per order

select
o.orderID,
sum(od.quantity * (od.unitprice - od.discount)) as Revenue_per_order
from orders o
join order_details od on o.OrderID = od.OrderID
group by o.orderID
order by revenue_per_order desc;

#Identify customers who placed the most orders in a specific time period.
select * from orders;

select
o.customerid,c.name, count(o.orderID) as Total_orders
from orders o
join customers c on o.CustomerID = c.CustomerID
where OrderDate="2025-01-01"     	#since orderdate only has one value i.e 2025-01-01 changed the between operator to =
group by o.CustomerID,c.name
order by Total_orders desc;

#Find the supplier with the most products in stock.

select s.supplierID,s.suppliername,
sum(p.stockquantity) as Total_stock
from products p
join suppliers s on p.supplierID = s.supplierID
group by s.supplierID,s.suppliername
order by Total_stock desc;			#Result is none since both the tables doesnt have any matching values

#Cross check
SELECT p.supplierID, s.supplierID
FROM products p
JOIN suppliers s
ON p.supplierID = s.supplierID;

#Task 13 Subqueries
#Identify the top 3 products based on sales revenue.

select ProductID,ProductName,Total_revenue
from(
select od.ProductID as productID,
p.ProductName as ProductName,
sum(od.quantity * (od.unitprice - od.discount)) as Total_revenue
from order_details od
join products p on od.productID = p.ProductID
group by p.ProductName,od.ProductID
order by Total_revenue desc
limit 3
)
As Top_Product;

#Find customers who haven’t placed any orders yet

select CustomerID,Name
from customers
where CustomerID not in (select distinct CustomerID from orders);


#Task 14
#Which cities have the highest concentration of Prime members

select city,
count(customerID) as Prime_Members_city
from customers
where PrimeMember = 1
group by city
order by Prime_members_city desc; 

select state,
count(customerID) as Prime_Members
from customers
where PrimeMember = 1
group by state
order by Prime_members desc; 

#What are the top 3 most frequently ordered categories

select p.category,
sum(od.quantity) as Total_quantity
from order_details od
join products p on p.ProductID =  od.productID
group by p.category
order by total_quantity desc
limit 3;


#Task Normalization

create table categories(											#Creating a new table for categories and  sub-categories
	categoryID int primary key auto_increment,
    category varchar(100) not null,
    subCategory varchar(100) not null
    );

ALTER TABLE Products ADD COLUMN CategoryID INT;

insert into categories (category,subcategory)
select distinct category,subcategory from products;

select * from categories;

update products p
join categories c on p.category = c.category and p.subcategory = c.Subcategory
set p.categoryID = c.categoryID;

alter table products
drop column category,
drop column subcategory;

select * from products;

select * from products 
where CategoryID=1;

# BUSINESS USE CASES
#Analyzing Top customers and cities for targeted marketing

Select c.Name, c.City, c.customerID,
sum(o.OrderAmount) as TotalSpent
from orders o
join customers c on o.CustomerID = c.CustomerID
group by c.CustomerID,c.Name, c.City
order by TotalSpent desc
limit 10;

Select c.Gender, COUNT(distinct c.CustomerID) as CustomerCount, 
       SUM(o.OrderAmount) as TotalSpent
from orders o
join customers c on o.CustomerID = c.CustomerID
group by c.Gender
order by TotalSpent desc;

select
    Case 
        when c.Age < 18 then 'Under 18'
        when c.Age between 18 and 25 then '18-25'
        when c.Age between 26 and 35 then '26-35'
        when c.Age between 36 and 50 then '36-50'
        else '50+'
    end as AgeGroup,
    count(distinct c.CustomerID) as CustomerCount,
    sum(o.OrderAmount) as TotalSpent
from orders o
join customers c on o.CustomerID = c.CustomerID
group by AgeGroup
order by TotalSpent desc;

#Top selling product category

select p.productname, c.category, sum(od.quantity) as totalquantitysold
from order_details od
join products p on od.productid = p.productid
join categories c on c.categoryID = p.categoryID
group by p.productname, c.category
order by totalquantitysold desc
limit 10;

#Stock Availability per supplier

select s.suppliername, sum(p.stockquantity) as totalstock           #Doesnt gie results since supplierID in product category doesnt match with the supplier iD in suppliers table
from products p
join suppliers s on p.supplierid = s.supplierid
group by s.suppliername
order by totalstock desc
limit 10;

#Key Suppliers

select p.supplierid, count(p.productid) as productssupplied, sum(p.stockquantity) as totalstock
from products p
group by p.supplierid
order by totalstock desc
limit 10;

#Revenue by product Category
select c.category, sum(o.orderamount) as totalrevenue
from orders o
join order_details od on o.orderid = od.orderid
join products p on od.productid = p.productid
join categories c on c.categoryID = p.categoryID
group by c.category
order by totalrevenue desc;

#Customer Satisfaction by ratings

select c.category, avg(r.rating) as avgrating
from reviews r
join products p on r.productid = p.productid
join categories c on c.categoryID = p.CategoryID
group by c.category
order by avgrating desc;

select * from orders;
select * from products;
select * from order_details;
