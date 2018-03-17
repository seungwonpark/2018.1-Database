-- 3.14 the select clause [1/3]
select name from instructor;

-- 3.15 the select clause [2/3]
select distinct dept_name from instructor;
select all dept_name from instructor;
-- default is 'all'.

-- 3.16 the select clause [3/3]
select * from instructor; -- missing
select ID, name, salary/12 from instructor;

-- 3.17 the where clause
select name
from instructor
where dept_name = ‘Comp. Sci.’ and salary > 80000;

-- 3.18 the from clause
select * from instructor, teaches; -- missing

-- 3.20 joins [1/2]
select name, course_id
from instructor, teaches
where instructor.ID = teaches.ID;

-- 3.21 joins [2/2]
select section.course_id, semester, year, title
from section, course
where section.course_id = course_id and dept_name = ‘Comp. Sci.’;

-- 3.24 natural join
select * from instructor natural join teaches; -- missing

-- 3.25 natural join example
select name, course_id
from instructor, teaches
where instructor.ID = teaches.ID;
-- identical
select name, course_id
from instructor natural join teaches;

-- 3.26 the rename operation
select ID, name, salary/12 as monthly_salary from instructor;
--
select distinct T.name
from instructor as T, instructor as S
where T.salary > S.salary and S.dept_name = ‘Comp. Sci.’;
-- keyword 'as' is optional.

-- 3.27 string operations
select name
from instructor
where name like ‘%dar%’;

-- 3.29 ordering the display of tuples
select distinct name
from instructor order by name;

-- 3.30 where clause predicates
select name
from instructor
where salary between 90000 and 100000;
-- tuple comparison
select name, course_id
from instructor, teaches
where (instructor.ID, dept_name) = (teaches.ID, ‘Biology’);

-- 3.40 set operations
(select course_id from section where sem = ‘Fall’ and year = 2009) _
union _
(select course_id from section where sem = ‘Spring’ and year = 2010);
--
(select course_id from section where sem = ‘Fall’ and year = 2009) _
intersect _
(select course_id from section where sem = ‘Spring’ and year = 2010);
--
(select course_id from section where sem = ‘Fall’ and year = 2009) _
except _
(select course_id from section where sem = ‘Spring’ and year = 2010);

-- 3.44 null values
select name from instructor where salary is null;

-- 3.47 aggregate functions [1/3]
select avg (salary) from instructor where dept_name = ‘Comp. Sri.’;
select count (distinct ID) from teaches where semester = ‘Spring’ and year = 2010;
select count (*) from course;

-- 3.49 aggregate functions - group by [2/3]
select dept_name, avg (salary) as avg_salary from instructor group by dept_name;

-- 3.50 aggregation functions [3/3]
-- erroneous query
-- select dept_name, ID, avg (salary) from instructor group by dept_name;
select dept_name, avg (salary) from instructor group by dept_name having avg (salary) > 42000;

-- 3.51 null values and aggregates
select sum (salary) from instructor;

-- 3.53 nested subqueries
select distinct course_id
from section
where semester = ‘Fall’ and year = 2009 and
course_id in (select course_id
from section
where semester = ‘Spring’ and year = 2010);
-- in -> not in
select distinct course_id
from section
where semester = ‘Fall’ and year = 2009 and
course_id not in (select course_id
from section
where semester = ‘Spring’ and year = 2010);
-- 3.54 example
select count (distinct ID)
from takes
where (course_id, sec_id, semester, year) in 
(select course_id, sec_id, semester, year
from teaches
where teaches.ID = 10101);

-- 3.55 set comparison
select distint T.name
from instructor as T, instructor as S
where T.salary > S.salary and S.dept_name = ‘Biology’;
-- using “> some” clause
select name
from instructor
where salary > some (select salary
from instructor
where dept name = ‘Biology’);

-- 3.57 example query with > all
select name
from instructor
where salary > all (select salary
from instructor
where dept name = ‘Biology’);

-- 3.59 test for empty relations
select course_id
from section as S
where semester = ‘Fall’ and year = 2009 and
exists (select *
from section as T
where semester = ‘Spring’ and year = 2010
and S.course_id = T.course_id); 

-- 3.60 example query with not exists
select distinct S.ID, S.name
from student as S
where not exists ( (select course_id
from course
where dept_name = ‘Biology’)
except
(select T.course_id
from takes as T
where S.ID = T.ID));

-- 3.61 test for absence of duplicate tuples
select T.course_id
from course as T
where unique (select R.course_id
from section as R
where T.course_id = R.course_id
and R.year = 2009);

-- 3.62 subqueries in the form clause [1/2]
select dept_name, avg_salary
from (select dept_name, avg (salary) as avg_salary
from instructor
group by dept_name)
where avg_salary > 42000;

-- 3.63 subqueries in the form clause [2/2]
select name, salary, avg_salary
from instructor l1,
lateral (select avg(salary) as avg_salary
from instructor l2
where l2.dept_name = l1.dept_name);

-- 3.64 example query with “with clause”
with max_budget(value) as
(select max(budget)
from department)
select budget
from department, max_budget
where department.budget = max_budget.value;

-- 3.65 complex queries using with clause
with dept_total (dept_name, value) as
(select dept_name, sum(salary)
from instructor
group by dept_name),
dept_total_avg(value) as
(select avg(value)
from dept_total)
select dept_name
from dept_total, dept_total_avg
where dept_total.value >= dept_total_avg.value;

-- 3.66 scalar subquery
select dept_name,
(select count(*)
from instructor
where department.dept_name = instructor.dept_name)
as num_instructors
from department;

-- 3.69 deletion [1/2]
delete from instructor;
delete from instructor where dept_name = ‘Finance’;
delete from instructor where dept_name in (select dept_name
from department
where building = ‘Watson’);

-- 3.70 deletion [2/2]
delete from instructor
where salary < (select avg (salary) from instructor);

-- 3.71 insertion [1/2]
insert into course
values (‘CS-437’, ‘Database Systems’, ‘Comp. Sri.’, 4);
insert into course (course_id, title, dept_name, credits)
values (‘CS-437’, ‘Database Systems’, ‘Comp. Sri.’, 4);
insert into student
values (‘3003’, ‘Green’, ‘Finance’, null);

-- 3.72 insertion [2/2]
insert into student
select ID, name, dept_name, 0
from instructor
insert into table1 select * from table1

-- 3.73 updates
update instructor
set salary = salary * 1.03
where salary > 100000;
update instructor
set salary = salary * 1.05
where salary <= 100000;
-- with case statement
update instructor
set salary = case
when salary <= 100000 then salary * 1.05
else salary * 1.03
end

-- 3.74 updates with scalar subqueries
update student S
set tot_cred = (select sum(credits)
from takes natural join course
where S.ID = takes.ID and
takes.grade <> ‘F’ and
takes.grade is not null);
-- instead of sum(credits), use:
case
when sum(credits) is not null then sum(credits)
else 0
end
