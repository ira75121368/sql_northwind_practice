-- JOIN --

-- 1. вывести список продуктов с указанием поставщика и количества на складе
select product_name, company_name, units_in_stock
from products
inner join suppliers on products.supplier_id = suppliers.supplier_id

-- 2. определить категории с высокой суммарной стоимостью на складе (только активные товары)
select category_name, sum(unit_price * units_in_stock)
from products
inner join categories on products.category_id = categories.category_id
where discontinued = 0
group by category_name 
having sum(unit_price * units_in_stock) > 5000
order by sum(unit_price * units_in_stock) desc;

-- 3. Найти заказчиков и обслуживающих их заказы сотрудников таких, что и заказчики и сотрудники из города London, а доставка идёт компанией Speedy Express. Вывести компанию заказчика и ФИО сотрудника.
select customers.company_name, last_name from orders
join employees using(employee_id)
join customers using(customer_id)
join shippers on orders.ship_via = shippers.shipper_id
where employees.city = 'London' and customers.city = 'London' 
	and shippers.company_name = 'Speedy Express';

-- 4. Найти активные (см. поле discontinued) продукты из категории Beverages и Seafood, которых в продаже менее 20 единиц. Вывести наименование продуктов, кол-во единиц в продаже, имя контакта поставщика и его телефонный номер.
select product_name, units_in_stock, contact_name, phone
from products
join suppliers using(supplier_id)
join categories using(category_id)
where discontinued = 0 and category_name in 
	('Beverages', 'Seafood') and units_in_stock < 20
order by units_in_stock;

-- 5. Найти заказчиков, не сделавших ни одного заказа. Вывести имя заказчика и order_id.
select contact_name, order_id from customers
left join orders using(customer_id)
where order_id is null

-- 6. Переписать предыдущий запрос, использовав симметричный вид джойна.
select contact_name, order_id from orders
right join customers using(customer_id)
where order_id is null