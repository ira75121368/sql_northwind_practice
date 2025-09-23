-- union, intersect, except

-- 1. получить перечень всех стран, где есть клиенты или поставщики (без повторов), отсортировать по алфавиту.
select country from customers
union 
select country from suppliers
order by country

-- 2. найти страны, общие для трёх таблиц (где есть и клиенты, и поставщики, и сотрудники).
select country from customers
intersect 
select country from suppliers
intersect 
select country from employees

--3. найти страны, где есть и клиенты, и поставщики, но в которых нет сотрудников.
select country from customers
intersect 
select country from suppliers
except 
select country from employees