-- 4.1 join expressions (p.113)
---  4.1.1 join conditions (p.114)
select *
from student join takes on student.ID = takes.ID;

select *
from student, takes
where student.ID = takes.ID;

select student.ID as ID, name, dept_name, tot_cred,
	course_id, sec_id, semester, year, grade
from student join takes on student.ID = takes.ID;

--- 4.1.2 outer joins (p.115)
select *
from student natural join takes;

select *
from student natural left outer join takes;

select ID
from student natural left outer join takes
where course_id is null;

select *
from takes natural right outer join student;

select *
from (select *
	from student
	where dept_name = 'Comp. Sci')
	natural full outer join
	(select *
	from takes
	where semester = 'Spring' and year = 2009);

select *
from student left outer join takes on student.ID = takes.ID;

select *
from student left outer join takes on true
where student.ID = takes.ID;

--- 4.1.3 join types and conditions (p.120)
select *
from student join takes using (ID);

select *
from student inner join takes using (ID);

select ID, name, dept_name
from instructor;

select course.course_id, sec_id, building, room_number
from course, section
where course.course_id = section.course_id
	and course.dept_name = 'Physics'
	and section.semester = 'Fall'
	and section.year = '2009';


-- 4.2 views (p.120)
--- 4.2.1. view definition (p.121)
create view faculty as
select ID, name, dept_name
from instructor;

create view physics_fall_2009 as
	select course.course_id, sec_id, building, room_number
	from course, section
	where course.course_id = section.course_id
		and course.dept_name = 'Physics'
		and section.semester = 'Fall'
		and section.year = '2009';

--- 4.2.2 using views in sql queries (p.122)
select course_id
from physics_fall_2009
where building = 'Watson';

create view depatments_total_salary(dept_name, total_salary) as
	select dept_name, sum(salary)
	from instructor
	group by dept_name;

create view physics_fall_2009_watson as
	select course_id, room_number
	from physics_fall_2009
	where building = 'Watson';

create view physics_fall_2009_watson as
	(select course_id, room_number)
	from (select course.course_id, building, room_number
		from course, section
		where course.course_id = section.course_id
			and course.dept_name = 'Physics'
			and section.semester = 'Fall'
			and section.year = '2009')
	where building = 'Watson';

--- 4.2.3 materialized views (p.123)
--- 4.2.4 update of a view (p.124)
insert into faculty
	values ('30765', 'Green', 'Music');

create view instructor_info as
select ID, name, building
from instructor, department
where instructor.dept_name = department.dept_name;

insert into instructor_info
	values ('69987', 'White', 'Taylor');

create view history_instructors as
select *
from instructor
where dept_name = 'History';


-- 4.3 transactions (p.127)
-- 4.4 integrity constraints (p.128)
--- 4.4.1 constraints on a single relation (p.129)
--- 4.4.2 not null constraint (p.129)
--- 4.4.3 unique constraint (p.130)
--- 4.4.4 the check clause (p.130)
create table section
	(course_id	varchar(8),
	sec_id		varchar(8),
	semester	varchar(8),
	year		numeric(4,0),
	building	varchar(15),
	room_number	varchar(7),
	time_slot_id	varchar(4),
	primary key (course_id, sec_id, semester, year),
	check (semester in ('Fall', 'Winter', 'Spring', 'Summer')));

--- 4.4.5 referential integrity (p.131)
--- 4.4.6 integrity constraint violation during a transaction (p.133)
--- 4.4.7 complex check conditions and assertions (p.134)
check (time_slot_id in (select time_slot_id from time_slot))

create assertion credits_earned_constraint check
(not exists (select ID
			from student
			where tot_cred <> (select sum(credits)
			from takes natural join course
			where student.ID = takes.ID
				and grade is not null and grade<>'F')))


-- 4.5 sql data types and schemas (p.136)
--- 4.5.1 date and time types in sql (p.136)
date '2001-04-25'
time '09:30:00'
timestamp '2001-04-25 10:29:01.45'

--- 4.5.2 default values (p.137)
create table student
	(ID			varchar(5),
	name		varchar(20) not null,
	dept_name	varchar(20),
	tot_cred	numeric(3,0) default 0,
	primary key (ID));

insert into student(ID, name, dept_name)
	values ('12789', 'Newman', 'Comp. Sci.');

--- 4.5.3 index creation (p.137)
create index studentID_index on student(ID);

--- 4.5.4 large-object types (p.138)
--- 4.5.5 user-defined types (p.138)
create table Dollars as numeric(12,2) final;
create table Pounds as numeric(12,2) final;

create table department
	(dept_name	varchar(20),
	building 	varchar(15),
	budget		Dollars);

cast (department.budget to numeric(12,2));

create domain DDollars as numeric(12,2) not null;
create domain YearlySalary numeric(8,2)
			constraint salary_value_test check(value >= 29000.00);

create domain degree_level varchar(10)
	constraint degree_level_test
		check (value in ('Bachelors', 'Masters', or 'Doctorate'));

--- 4.5.6 create table extensions (p.141)
create table temp_instructor like instructor;

create table t1 as
	(select *
	from instructor
	where dept_name = 'Music')
with data;

--- 4.5.7 schemas, catalogs, and environments (p.142)


-- 4.6 authorization (p.143)
--- 4.6.1 granting and revoking of privileges (p.142)
grant select on department to Amit, Satoshi;
grant update (budget) on department to Amit, Satoshi;

revoke select on department from Amit, Satoshi;
revoke update (budget) on department from Amit, Satoshi;

--- 4.6.2 roles (p.145)
create role instructor;

grant select on takes
to instructor;

grant dean to Amit;
create role dean;
grant instructor to dean;
grant dean to Satoshi;

--- 4.6.3 authorization on views (p.146)
create view geo_instructor as
	(select *
	from instructor
	where dept_name = 'Geology');

select *
from geo_instructor;

--- 4.6.4 authorizations on schema (p.147)
grant references (dept_name) on department to Mariano;

--- 4.6.5 transfer of privileges (p.148)
grant select on department to Amit with grant option;

--- 4.6.6 revoking of privileges (p.149)
revoke select on department from Amit, Satoshi restrict;
revoke grant option for select on department from Amit;
