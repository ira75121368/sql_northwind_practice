-- VIEWS
-- Создай представление test1, которое содержит все данные из таблицы orders, отсортированные по customer_id.
create view test1 as
select * from orders
order by customer_id

select * from test3

-- Создай представление test2, где для каждого клиента (customer_id) считается количество заказов (count_order). Данные должны быть отсортированы по customer_id.
create view test2 as
select customer_id, count(*) as count_order from orders
group by customer_id
order by customer_id

-- В представлении test3 измени название колонки customers_id на customer_id.
ALTER VIEW test3 RENAME COLUMN customers_id to customer_id

-- Создай (или замени, если существует) представление test4, которое содержит все записи из таблицы region, где region_id <= 4
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


-- Создай представление view1, которое объединяет таблицы orders, customers и employees по ключам (customer_id, employee_id).
create view view1 as
select order_date, required_date, shipped_date, ship_postal_code, company_name, contact_name, phone, last_name, first_name, title
from orders
join customers using(customer_id)
join employees using (employee_id)

select * from view1
where order_date > '1997-01-01'

select * from customers;

-- Для таблицы customers выведи customer_id и contact_name, а также новый столбец country_name
select customer_id, contact_name,
	case when phone like '(5)%' then 'Germany'
		 else 'unknown'
	end as country_name
from customers