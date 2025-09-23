set search_path to public;

--- Задание 1 ---
SELECT distinct *
from customers;

SELECT contact_name, city
FROM customers;

SELECT order_id, shipped_date - order_date FROM orders;

SELECT DISTINCT city FROM customers;

SELECT DISTINCT city, country FROM customers;

SELECT COUNT(DISTINCT contact_name) FROM customers;

SELECT COUNT(DISTINCT country) FROM customers;


--- Задание 2 ---
SELECT * FROM orders;
SELECT * FROM orders WHERE ship_country IN ('France', 'Austria', 'Spain');

SELECT * FROM orders ORDER BY required_date DESC, shipped_date;

SELECT * FROM products;
SELECT MIN(unit_price) FROM products WHERE units_on_order > 30;

SELECT MAX(unit_price) FROM products WHERE units_on_order > 30;

SELECT AVG(required_date - order_date) FROM orders WHERE ship_country = 'USA';

SELECT SUM(unit_price * units_in_stock) FROM products WHERE discontinued <> 1;

SELECT ship_country, COUNT(*)
FROM orders
WHERE freight > 50


--- Задание 3 ---
SELECT * FROM orders;
SELECT * FROM employees;
SELECT * FROM customers;
SELECT * FROM suppliers;

select * from orders where ship_country like 'U%';

select order_id, customer_id, freight, ship_country from orders where ship_country like 'N%' order by freight desc limit 10;

select first_name, last_name, home_phone from employees where region is null; 

select count(*) from customers where region is not null;

select country, count(*) from suppliers group by country order by count(*) desc;

select ship_country, sum(freight) from orders
where ship_region is not null 
group by ship_country
having sum(freight) > 2750
order by sum(freight) desc;

select country from customers
union 
select country from suppliers
order by country

select country from customers
intersect 
select country from suppliers
intersect 
select country from employees

select country from customers
intersect 
select country from suppliers
except 
select country from employees


select product_name, company_name, units_in_stock
from products
inner join suppliers on products.supplier_id = suppliers.supplier_id

select category_name, sum(unit_price * units_in_stock)
from products
inner join categories on products.category_id = categories.category_id
where discontinued = 0
group by category_name 
having sum(unit_price * units_in_stock) > 5000
order by sum(unit_price * units_in_stock) desc;

--- Задание 4 ---
SELECT * FROM orders;
SELECT * FROM employees;
SELECT * FROM customers;
SELECT * FROM suppliers;
SELECT * FROM shippers;

select customers.company_name, last_name from orders
join employees using(employee_id)
join customers using(customer_id)
join shippers on orders.ship_via = shippers.shipper_id
where employees.city = 'London' and customers.city = 'London' 
	and shippers.company_name = 'Speedy Express';

select product_name, units_in_stock, contact_name, phone
from products
join suppliers using(supplier_id)
join categories using(category_id)
where discontinued = 0 and category_name in 
	('Beverages', 'Seafood') and units_in_stock < 20
order by units_in_stock;

select contact_name, order_id from customers
left join orders using(customer_id)
where order_id is null

select contact_name, order_id from orders
right join customers using(customer_id)
where order_id is null

--- Задание 5 ---
SELECT * FROM orders;
SELECT * FROM employees;
SELECT * FROM customers;
SELECT * FROM suppliers;
SELECT * FROM shippers;
SELECT * FROM order_details;

select product_id, avg(quantity) from order_details
group by product_id
	
select product_name, units_in_stock from products
where units_in_stock < all(select avg(quantity) from order_details
						 group by product_id)

select avg(freight) from orders
group by customer_id
	
select customer_id, sum(freight) as freight_sum from orders
join (select customer_id, avg(freight) from orders
	  group by customer_id) 
using(customer_id)
where freight > avg(freight)
	  and shipped_date between '1996-07-16' and '1996-07-31'
group by customer_id
order by freight_sum

select order_id, sum(unit_price*quantity-unit_price*discount)
from order_details
group by order_id

select customer_id, ship_country, order_price 
from orders
join (select order_id, sum(unit_price*quantity-unit_price*quantity*discount) as order_price
	  from order_details
	  group by order_id) 
using(order_id)
where order_date >= '1997-09-01'
	and ship_country in ('Argentina', 'Venezuela', 'Brazil')
order by order_price desc
limit 6

select product_id from order_details
where quantity = 10
	
select product_name from products
where product_id = any (select product_id from order_details
	   where quantity = 10);

select distinct(product_name) from products
join order_details 
using(product_id)
where quantity = 10



-- VIEWS
create view test1 as
select * from orders
order by customer_id

select * from test3

create view test2 as
select customer_id, count(*) as count_order from orders
group by customer_id
order by customer_id

ALTER VIEW test3 RENAME COLUMN customers_id to customer_id

create or replace view test4 as
select * from region
where region_id <= 4
with cascaded check option

select * from region

select * from test4
	
insert into test4
values (5, 'Ft')

delete from region
where region_id = 4

delete from region
where region_id = 5

-- Задание 6 
create view view1 as
select order_date, required_date, shipped_date, ship_postal_code, company_name, contact_name, phone, last_name, first_name, title
from orders
join customers using(customer_id)
join employees using (employee_id)

select * from view1
where order_date > '1997-01-01'

select * from customers;

select customer_id, contact_name,
	case when phone like '(5)%' then 'Germany'
		 else 'unknown'
	end as country_name
from customers

-- Задание 7
insert into customers(customer_id, contact_name, city, country, company_name)
values 
('AAAAA', 'Alfred Mann', NULL, 'USA', 'fake_company'),
('BBBBB', 'Alfred Mann', NULL, 'Austria','fake_company');

select contact_name, city, country 
from customers
order by contact_name, coalesce (city, country)

select product_name, unit_price, 
	case when unit_price >= 100 then 'too expensive'
		 when unit_price between 50 and 99.99 then 'average'
		 when unit_price between 0 and 49.99 then 'low price'
		 else 'VALUE ERROR'
	end as price_product
from products

select contact_name , coalesce(order_id::text, 'no orders') as orders_c
from orders
right join customers using(customer_id)
order by orders_c desc

select first_name, last_name, title
from employees
	
select first_name, last_name, coalesce(nullif(title, 'Sales Representative'), 'Sales Stuff')
from employees

select * from customers
	 
 

select * into cus_tmp from customers

create or replace function func_fix_region() returns void as $$
	update cus_tmp
	set region = 'Unknown'
	where region is null
$$ language sql

select func_fix_region()

create or replace function min_max_price(is_discont int, out min_price real, out max_price real) as $$
	select min(unit_price), max(unit_price)
	from products
	where discontinued = is_discont
$$ language sql

select * from min_max_price(1)

select * from products

-- Выведи список всех товаров (Products), где в названии встречается слово "Chef", и выведи название в верхнем регистре.
create or replace function list_prod_name_chef() 
		returns setof varchar as $$
	select upper(product_name)
	from products
	where product_name like '%Chef%'
$$ language sql

select * from list_prod_name_chef();

-- Создай функцию get_total_customers() → возвращает общее количество клиентов
create or replace function get_total_customers() returns smallint as $$
	select count(*) from customers
$$ language sql

select get_total_customers() as count_customers

-- Напиши функцию get_max_price() → возвращает максимальную цену товара из таблицы Products
create or replace function get_max_price(out smallint) as $$
	select max(unit_price) from products
$$ language sql

select get_max_price()

-- Функция get_customer_name() → возвращает название компании
create or replace function get_customer_name(cust_id text) returns varchar as $$
	select max(company_name) from customers
	where customer_id = cust_id
$$ language sql

-- Функция get_order_total() → возвращает сумму заказа
create or replace function get_order_total(is_order_id smallint) returns float as $$
	select sum(unit_price * quantity * (1-discount)) from order_details
	where order_id = is_order_id
$$ language sql

DROP FUNCTION get_order_total(smallint)
select * from order_details
select get_order_total(10256)

-- возвращает название, цену и остаток по товару.
create or replace function get_product_info(is_product_id int, out is_product_name varchar, out is_unit_price real, out is_units_in_stock smallint) as $$
	select product_name, unit_price, units_in_stock from products
	where product_id = is_product_id
$$ language sql

select * from public.products
select * from get_product_info(1)

-- возвращает даты заказа, доставки и число дней между ними.
create or replace function get_order_dates(is_order_id int, out is_order_date date, out is_shipped_date date, out delivedy_day int) as $$
	select order_date, shipped_date, shipped_date - order_date from orders
	where order_id = is_order_id
$$ language sql

select * from get_order_dates(10256)

-- Функция products_in_category(cat_id INT) → возвращает список названий товаров в категории (ProductName)
create or replace function products_in_category(cat_id int) returns setof varchar as $$
	select product_name from products
	where category_id = cat_id
$$ language sql

select * from products_in_category(1) as name_products

-- Функция customer_orders(cust_id) → возвращает список номеров заказов клиента (OrderID).
create or replace function customer_orders(is_customer_id char) returns setof text as $$
	select coalesce(order_id::text, 'No orders') from orders
	where customer_id = is_customer_id
$$ language sql

DROP FUNCTION customer_orders(character)

select * from customers
select * from customer_orders('AAAAA')

-- Функция all_suppliers() → возвращает все строки из таблицы Suppliers.
create or replace function all_suppliers() returns setof suppliers as $$
	select * from suppliers
$$ language sql

select * from all_suppliers()
select company_name, contact_name, phone, fax 
from all_suppliers()

-- Функция employees_from_city(city TEXT) → возвращает всех сотрудников из указанного города.
create or replace function employees_from_city(is_city text) returns setof employees as $$
	select * from employees
	where city = is_city
$$ language sql

select * from employees_from_city('London')

-- Функция late_orders() → возвращает все заказы, где ShippedDate > RequiredDate
create or replace function late_orders() returns table (order_id int, customer_id char, ship_country varchar) as $$
	select order_id, customer_id, ship_country from orders
	where shipped_date > required_date
$$ language sql

select * from late_orders()

-- Функция expensive_products(min_price NUMERIC) → возвращает все товары дороже указанной цены.
create or replace function expensive_products(price numeric) returns table (product_name varchar, category_id int, unit_price numeric) as $$
	select product_name, category_id, unit_price 
	from products
	where unit_price > price
$$ language sql

select * from expensive_products(105)

-- Функция orders_summary_by_customer(cust_id TEXT) → возвращает OrderID, OrderDate, TotalAmount.
create or replace function orders_summary_by_customer(is_customer_id char, out order_id int, out order_date date, out total_amound int) returns setof record as $$
	select order_id, order_date, count(*)
	from orders
	where customer_id = is_customer_id
	group by order_id
$$ language sql

select * from orders_summary_by_customer('ANTON')

-- Сделать бэкап таблицы клиентов, если бекап уже был сделан, сделать новый, удалив предыдущий
create or replace function backup_customers() returns void as $$
	drop table if exists backup_customers;
	create table backup_customers as
	select * from customers
$$ language sql

select backup_customers()

-- Создать функцию, которая возвращает средний freight
create or replace function avg_freight() returns float8 as $$
	select avg(freight) from orders
$$ language sql

select * from avg_freight()

-- Создать функцию, которая принимает два int пар-ра (нижн и верхн граница для генерации числа включая значения)
-- необходимо вычислить разницу между границами и +1, получ число умножить на функцию random прибав к рез-ту значение
-- нижн границы применить ф-ю floor
create or replace function random_between(low int, high int) returns int as $$
begin
	return floor(random() * (high-low+1) + low);	
end;
$$ language plpgsql

select random_between(1,5)
from generate_series(1,10)

-- Возвращает самую низкую и самую высокую зарплату по заданному городу
create or replace function get_min_max_birth_date(is_city varchar, out min_birth_date date, out max_birth_date date) as $$
	select min(birth_date), max(birth_date) 
	from employees
	where city = is_city
$$ language sql

select * from get_min_max_birth_date('London')




-- DCL
-- Создай нового пользователя report_user и дай ему только право SELECT на таблицу Products
CREATE USER report_user WITH PASSWORD 'pass'; 
grant select on products to report_user;
revoke all privileges on products from report_user;


-- TCL
-- Добавление клиента 
begin;
select 

