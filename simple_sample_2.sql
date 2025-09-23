--- like, is null, group by, having ---
SELECT * FROM orders;
SELECT * FROM employees;
SELECT * FROM customers;
SELECT * FROM suppliers;

-- 1. найти все заказы, отправленные в страны, название которых начинается с U. Вывести колонки
select * from orders 
where ship_country like 'U%';

-- 2. найти 10 заказов с наибольшим freight для стран, начинающихся на N
select order_id, customer_id, freight, ship_country 
from orders 
where ship_country like 'N%' 
order by freight desc 
limit 10;

-- 3. найти контакты сотрудников с пустым region. Вывести имя и телефон.
select first_name, last_name, home_phone 
from employees 
where region is null; 

-- 4. подсчитать количество клиентов с указанным регионом.
select count(*) 
from customers 
where region is not null;

-- 5. получить распределение поставщиков по странам, отсортированное от страны с наибольшим числом поставщиков.
select country, count(*) 
from suppliers 
group by country 
order by count(*) desc;

-- 6. найти страны (для заказов, где указан ship_region), где суммарная стоимость доставки превышает 2750 единиц. Вывести страну и общую сумму доставки.
select ship_country, sum(freight) from orders
where ship_region is not null 
group by ship_country
having sum(freight) > 2750
order by sum(freight) desc;