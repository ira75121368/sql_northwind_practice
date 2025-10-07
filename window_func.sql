set search_path to public;

-- Накопление суммы заказов у каждого сотрудника
select e.employee_id, 
	e.last_name, 
	o.order_date, 
	sum(od.unit_price * od.quantity)
		over (partition by e.employee_id order by o.order_id)
		as running_total
from employees e
join orders o using(employee_id)
join order_details od on o.order_id = od.order_id;

	
select e.employee_id, 
	e.last_name, 
	o.order_date, 
	sum(od.unit_price * od.quantity)
		over (partition by e.employee_id order by o.order_date rows between unbounded preceding and current row)
		as running_total
from employees e
join orders o using(employee_id)
join order_details od on o.order_id = od.order_id;


with order_sum as (
	select e.employee_id, 
		e.last_name, 
		o.order_date, 
		sum(od.unit_price * od.quantity) as order_total
	from employees e
	join orders o using(employee_id)
	join order_details od on o.order_id = od.order_id
	group by e.employee_id, o.order_id, o.order_date
)
select employee_id, 
	last_name, 
	order_date,
	sum(order_total) over (
	partition by employee_id order by order_date
	rows between unbounded preceding and current row
	)as running_total
from order_sum;


-- Вывод самого дорогого товара в категории и средней цены с округлением
select product_id, product_name, category_name, unit_price,
	max(unit_price) over (partition by category_name) as max_price_in_category,
	round(avg(unit_price) over (partition by category_name)::numeric, 2) as avg_price_in_category
from products
join categories using(category_id);


select product_id, product_name, category_name, unit_price,
	first_value(unit_price) over (partition by category_name order by unit_price desc) as max_price_in_category,
	round(avg(unit_price) over (partition by category_name)::numeric, 2) as avg_price_in_category
from products
join categories using(category_id);


select product_id, product_name, category_name, unit_price,
	last_value(unit_price) over (partition by category_name order by unit_price
	rows between unbounded preceding and unbounded following) as max_price_in_category,
	round(avg(unit_price) over (partition by category_name)::numeric, 2) as avg_price_in_category
from products
join categories using(category_id);

-- Вывод топ-3 товара по дороговизне в каждой категории
select category_name, product_name, unit_price, rn from
	(select category_name, product_name, unit_price,
		row_number() over 
		(partition by cat.category_id order by unit_price desc) as rn
	from products 
	join categories cat using(category_id)) е
where rn <= 3
order by category_name, rn;


-- Вывод топ-3 покупателя в каждой стране
with customer_sales as (
	select c.contact_name, o.ship_country, 
		sum(od.unit_price*od.quantity) as sum_total 
	from customers c
	join orders o using(customer_id)
	join order_details od on o.order_id = od.order_id
	group by c.contact_name, o.ship_country
),
ranked as (
	select contact_name, ship_country, sum_total,
		row_number() over (partition by ship_country order by sum_total desc) as rw
	from customer_sales
)
select * from ranked
where rw <= 3
order by ship_country, sum_total desc;
	

-- Вывод заказов клиентов и нумерование их в порядке даты
select o.customer_id, company_name, order_id, order_date,
	row_number() over 
	(partition by o.customer_id order by order_date, order_id) as num_order
from orders o
join customers using(customer_id);


-- Вывод разницы между датой текущего и предыдущего заказа для каждого клиента
select o.customer_id, company_name, order_id, order_date,
	order_date-lag(order_date, 1) over 
	(partition by o.customer_id order by order_date, order_id) as days_between_orders
from orders o
join customers using(customer_id);


-- Подсчет накопления стоимости заказов для
select o.customer_id, company_name, order_id, order_date,
	min(order_date) over (partition by o.customer_id) as first_order_date,
	order_date - min(order_date) over (partition by o.customer_id) as difference_in_orders
from orders o
join customers using(customer_id);


-- Заказы, которые были “аномально большими”
with order_total as (
	select c.contact_name, o.order_id, 
		round(sum(od.unit_price*od.quantity)::numeric, 2) as sum_order
	from orders o
	join order_details od using(order_id)
	join customers c using(customer_id)
	group by c.contact_name,o.order_id 
),
with_avg as (
	select contact_name, order_id, sum_order, 
		avg(sum_order) over (partition by contact_name) as avg_order
	from order_total
)
select * from with_avg
where sum_order >= avg_order
order by contact_name, sum_order desc;


-- Сравнение текущего и предыдущего заказа по стоимости
with total_order as (
	select contact_name, o.order_id, order_date, sum(unit_price*quantity) as sum_order
	from orders o
	join customers using(customer_id)
	join order_details using(order_id)
	group by contact_name, o.order_id, order_date
)
select contact_name, order_id, order_date, sum_order,
	lag(sum_order, 1) over (partition by contact_name) as last_order,
	sum_order - lag(sum_order, 1) over (partition by contact_name) as difference_orders
from total_order;


-- Позиция текущего заказа в общем потоке
with total_order as (
	select order_id, order_date,
		row_number() over (partition by order_date order by order_date) as rw_by_date
	from orders
) 
select order_id, order_date, rw_by_date,
	round(rw_by_date::numeric / count(rw_by_date) over (partition by order_date), 2) as priportion
from total_order
order by order_date, rw_by_date;


-- Определение “повторных” клиентов (заказали вновь в течении месяца)
with differance_in_date_of_orders as (
	select contact_name, order_date,
		lag(order_date, 1) over (partition by contact_name order by order_date) as displacement_of_one,
		order_date - lag(order_date, 1) over (partition by contact_name) as differance_in_date
	from orders o
	join customers using(customer_id)
)
select distinct(contact_name) from differance_in_date_of_orders
where differance_in_date <= 30;


-- Определение минимального срока перед повторным заказом у каждого клиента 
with differance_in_date_of_orders as (
	select contact_name, order_date,
		lag(order_date, 1) over (partition by contact_name order by order_date) as displacement_of_one,
		order_date - lag(order_date, 1) over (partition by contact_name order by order_date) as differance_in_date
	from orders
	join customers using(customer_id)
)
select contact_name, min(differance_in_date) 
from differance_in_date_of_orders
where differance_in_date is not null
group by contact_name;