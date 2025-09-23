-- Функции --

-- Функция для исправления NULL в колонке region
create or replace function func_fix_region() returns void as $$
	update cus_tmp
	set region = 'Unknown'
	where region is null
$$ language sql

select func_fix_region()

-- Функция для нахождения минимальной и максимальной цены
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
