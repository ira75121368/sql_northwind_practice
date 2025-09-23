-- DDL --
create table exam
(
	exam_id int generated always as identity primary key,
	exam_name varchar(60),
	exam_date date
)
-- Добавить ограничение уникальности с поля идентификатора
alter table exam
add unique (exam_name)

-- Вывести таблицу со всеми ограничениями
SELECT *
FROM information_schema.constraint_table_usage
WHERE table_name = 'exam';

-- Удалить ограничение уникальности с поля идентификатора
alter table exam 
drop constraint exam_exam_name_key 

-- Добавить ограничение первичного ключа на поле идентификатора
alter table exam
add primary key(exam_id)

create table person 
(
	person_id int primary key,
	first_name varchar(60),
	last_name varchar(60) 
);

create table passport 
(
	passport_id int primary key,
	serial_number int not null,
	register_date date,
	person_id int,
	foreign key (person_id) references person (person_id)
);

-- Добавить колонку веса
alter table person 
add column weight float check (weight > 0 and weight < 100);

-- Убедиться в том, что ограничение на вес работает
insert into person
values (1, 'Bob', 'Smith', 101);

create table student 
(
	student_id int generated always as identity primary key,
	full_name varchar(60),
	course int default '1'
);

-- Убедиться в том, что ограничение на вставку значения по умолчанию работает
insert into student (full_name)
values ('Bob');

-- Удалить ограничение "по умолчанию" из таблицы студентов
alter table student
alter column course drop default

alter table passport
alter column passport_id add generated always as identity

insert into passport (serial_number, register_date, person_id)
values (1234511234, '2025-05-01', 1);


create or replace view test4 as
select * from exam
where exam_id <= 7
with local check option

 
select * from test4

insert into exam (exam_name, exam_date)
values ('Math', '2025-06-01');
insert into exam (exam_name, exam_date)
values ('Ru', '2025-06-05');
insert into exam (exam_name, exam_date)
values ('En', '2025-05-01');

delete from exam
where exam_id = 5
	
delete from test4
where exam_id = 6