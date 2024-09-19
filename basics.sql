-- create salesorder dataset 4 tables
drop table if exists products;

create table products
(
	id				    int generated always as identity primary key,
	name			    varchar(100),
	price			    float,
	release_date 	date
);


insert into products 
values(default,'iPhone 15', 800, to_date('22-08-2023','dd-mm-yyyy'));
insert into products 
values(default,'Macbook Pro', 2100, to_date('12-10-2022','dd-mm-yyyy'));
insert into products 
values(default,'Apple Watch 9', 550, to_date('04-09-2022','dd-mm-yyyy'));
insert into products 
values(default,'iPad', 400, to_date('25-08-2020','dd-mm-yyyy'));
insert into products 
values(default,'AirPods', 420, to_date('30-03-2024','dd-mm-yyyy'));

drop table if exists customers;

create table customers
(
    id         int generated always as identity primary key,
    name       varchar(100),
    email      varchar(30)
);

insert into customers values(default,'Meghan Harley', 'mharley@demo.com');
insert into customers values(default,'Rosa Chan', 'rchan@demo.com');
insert into customers values(default,'Logan Short', 'lshort@demo.com');
insert into customers values(default,'Zaria Duke', 'zduke@demo.com');

drop table if exists employees;

create table employees
(
    id         int generated always as identity primary key,
    name       varchar(100)
);

insert into employees values(default,'Nina Kumari');
insert into employees values(default,'Abrar Khan');
insert into employees values(default,'Irene Costa');

drop table if exists sales_order;

create table sales_order
(
	order_id		  int generated always as identity primary key,
	order_date	  date,
	quantity		  int,
	prod_id			  int references products(id),
	status			  varchar(20),
	customer_id		int references customers(id),
	emp_id			  int,
	constraint fk_so_emp foreign key (emp_id) references employees(id)
);

insert into sales_order 
values(default,to_date('01-01-2024','dd-mm-yyyy'),2,1,'Completed',1,1);
insert into sales_order 
values(default,to_date('01-01-2024','dd-mm-yyyy'),3,1,'Pending',2,2);
insert into sales_order 
values(default,to_date('02-01-2024','dd-mm-yyyy'),3,2,'Completed',3,2);
insert into sales_order 
values(default,to_date('03-01-2024','dd-mm-yyyy'),3,3,'Completed',3,2);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,1,'Completed',3,2);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,3,'completed',2,1);
insert into sales_order 
values(default,to_date('04-01-2024','dd-mm-yyyy'),1,2,'On Hold',2,1);
insert into sales_order 
values(default,to_date('05-01-2024','dd-mm-yyyy'),4,2,'Rejected',1,2);
insert into sales_order 
values(default,to_date('06-01-2024','dd-mm-yyyy'),5,5,'Completed',1,2);
insert into sales_order 
values(default,to_date('06-01-2024','dd-mm-yyyy'),1,1,'Cancelled',1,1);

SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM sales_order;


-- 1. Identify the total no of products sold
SELECT SUM(quantity) from  sales_order where status='Completed'

-- 2. Other than Completed, display the available delivery status's
SELECT status from sales_order where status not like '%ompleted'

-- 3. Display the order id, order_date and product_name for all the completed orders.
SELECT s.order_id, s.order_date, p.name
FROM sales_order as s JOIN products as p
ON (s.prod_id=p.id)
WHERE lower(s.status) = 'completed'

-- 4. Sort the above query to show the earliest orders at the top. 
--    Also, display the customer who purchased these orders.
SELECT s.order_id, s.order_date, p.name,c.name
FROM sales_order as s JOIN products as p  ON (s.prod_id=p.id) 
JOIN customers as c ON  (s.customer_id=c.id)
WHERE lower(s.status) = 'completed'
ORDER BY s.order_date

-- 5. Display the total no of orders corresponding to each delivery status
create table  dummy  as select * from sales_order
select * from dummy
alter status where status='completed' as status='Completed' from dummy
update dummy
set status ='Completed'
where status='completed'


SELECT count(quantity),lower(status)
FROM dummy
GROUP BY status


-- 6. How many orders are still not completed for orders purchasing more than 1 item?
select count(quantity)
from sales_order
where status not like '%ompleted' 
and quantity >1

-- 7. Find the total number of orders corresponding to each delivery status by ignoring the case in
--    the delivery status. The status with highest no of orders should be at the top.
SELECT count(quantity),lower(status)
FROM sales_order
GROUP BY lower(status) 
order by count(quantity) desc

-- 8. Write a query to identify the total products purchased by each customer 
SELECT sum(quantity),c.name
FROM sales_order s join customers c on s.customer_id=c.id
GROUP by c.name

-- 9. Display the total sales and average sales done for each day. 
SELECT sum(quantity*p.price),avg(quantity*p.price),s.order_date
from sales_order s join products p on s.prod_id=p.id
group by s.order_date 
order by s.order_date

-- 10. Display the customer name, employee name, and total sale amount of all orders which 
--     are either on hold or pending.
select c.name,e.name,sum(quantity*p.price)
from sales_order s 
join employees e on e.id=s.emp_id
join customers c on c.id=s.customer_id
join products p on  p.id =s.prod_id
where status in ('Pending','On Hold')
group by c.name,e.name

-- 11. Fetch all the orders which were neither completed/pending or were handled by the employee Abrar.
--     Display employee name and all details of order.
SELECT e.name,s.*
FROM sales_order s JOIN employees e on e.id=s.emp_id
WHERE lower(status) not in ('completed','pending') or e.name like '%brar%'

-- 12. Fetch the orders which cost more than 2000 but did not include the MacBook Pro. 
--     Print the total sale amount as well.
SELECT s.*,(p.price*quantity) as total_sales
FROM sales_order s JOIN products p on s.prod_id=p.id 
WHERE (p.price*quantity)>2000 and lower(p.name) not like '%pro%'

-- 13. Identify the customers who have not purchased any product yet.
SELECT * from customers
where id not in (select distinct customer_id from sales_order);

select c.name from customers c left join sales_order s on c.id=s.customer_id where order_id is null

-- 14. Write a query to identify the total products purchased by each customer.
--     Return all customers irrespective of whether they have made a purchase or not. 
--     Sort the result with the highest no of orders at the top.
SELECT c.name,coalesce(sum(quantity),0)
FROM sales_order s right join customers c on s.customer_id=c.id
group by c.name
order by coalesce(sum(quantity),0) desc

-- 15. Corresponding to each employee, display the total sales they made of all the completed orders.
--     Display total sales as 0 if an employee made no sales yet.
SELECT e.name,coalesce(sum(quantity*price),0)
FROM sales_order s
join products p on p.id=s.prod_id 
right join employees e on e.id=s.emp_id and s.status like '%omplete%'
group by e.name

-- 16. Re-write the above query to display the total sales made by each employee corresponding to each
--     customer. If an employee has not served a customer yet then display "-" under the customer.
SELECT e.name,coalesce(c.name,'-'), coalesce(sum(quantity*price),0)
FROM sales_order s
join products p on p.id=s.prod_id 
join customers c on c.id=s.customer_id
right join employees e on e.id=s.emp_id and s.status like '%omplete%'
group by e.name,c.name
order by 1,2

-- 17. Re-write the above query to display only those records where the total sales are above 1000
SELECT e.name,coalesce(c.name,'-'), coalesce(sum(quantity*price),0)
FROM sales_order s
join products p on p.id=s.prod_id 
join customers c on c.id=s.customer_id
right join employees e on e.id=s.emp_id and s.status like '%omplete%'
group by e.name,c.name
having  coalesce(sum(quantity*price),0)>1000
order by 1,2

-- 18. Identify employees who have served more than 2 customers.
SELECT e.name,count(distinct c.name)
FROM sales_order s 
join employees e  on e.id=s.emp_id
join customers c  on c.id=s.customer_id
group by e.name
having count(distinct c.name)>2


-- 19. Identify the customers who have purchased more than 5 products
SELECT c.name, sum( quantity)
FROM sales_order s 
join customers c  on c.id=s.customer_id
group by c.name
having sum(quantity)>5


-- 20. Identify customers whose average purchase cost exceeds the average sale of all the orders.
SELECT c.name, avg(p.price*s.quantity)
from sales_order  s 
join customers c on s.customer_id=c.id
join products p on s.prod_id=p.id
group by c.name
having avg(p.price*s.quantity)
>
(select avg(quantity*p.price) from sales_order s join products p on s.prod_id=p.id)



