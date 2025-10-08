-- Вывод среднего времени между заказами для каждого клиента
with total_difference_between_orders as (
	select contact_name, order_date,
		order_date - lag(order_date) over(partition by contact_name order by order_date) as difference_orders
	from customers
	join orders using(customer_id)		
)
select contact_name, round(avg(difference_orders), 2)
from total_difference_between_orders
group by contact_name
order by contact_name;


-- Вывод месяца, в который у компании было больше всего заказов
select 
	extract(year from order_date) as year_order,
	extract(month from order_date) as month_order,
	count(order_id) as count_orders
from orders
group by 1, 2
order by count_orders desc
limit 1;
	

-- Вывод распределения заказов по кварталам (1,2,3,4)
select 
	extract(year from order_date) as extr_year,
	extract(quarter from order_date) as extr_quarter,
	count(order_id) as total_orders
from orders
group by 1, 2
order by 1, 2;


select 
	extract(year from order_date) as extr_year,
	sum(case when extract(quarter from order_date) = 1 then 1 else 0 end) as q1,
	sum(case when extract(quarter from order_date) = 2 then 1 else 0 end) as q2,
	sum(case when extract(quarter from order_date) = 3 then 1 else 0 end) as q3,
	sum(case when extract(quarter from order_date) = 4 then 1 else 0 end) as q4
from orders
group by 1
order by 1;


-- Вывод сотрудников, у которых средняя скорость обработки заказов (от order_date до shipped_date) — лучше, чем средняя по компании
with avg_times as (
	select distinct
		concat(last_name, ' ', first_name) as full_name, 
		round(avg(shipped_date - order_date) over (partition by employee_id), 2) as avg_order_processing_time,
		round(avg(shipped_date - order_date) over (), 2) as avg_order_full_table
	from orders
	join employees using(employee_id)
)
select full_name, avg_order_processing_time
from avg_times
where avg_order_processing_time < avg_order_full_table
order by full_name;
