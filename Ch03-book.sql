-- 3.3.1 queries on a single relation (63p.)
select name from instructor;
select dept_name from instructor;
select distinct dept_name from instructor;
select all dept_name from instructor;
select ID, name, dept_name, salary*1.1 from instructor;
--
select name
from instructor
where dept_name = 'Comp. Sci.' and salary > 70000;

-- 3.3.2 queries on multiple relations (66p.)
select name, instructor.dept_name, building
from instructor, department
where instructor.dept_name = department.dept_name;
--
select name, course_id
from instructor, teaches
where instructor.ID = teaches.ID;
--
select name, course_id
from instructor, teaches
where instructor.ID = teaches.ID and _
instructor.dept_name = 'Comp.Sci.';

-- 3.3.3 the natural join (71p.)
select name, course_id
from instructor, teaches
where instructor.ID = teaches.ID;
-- identical
select name, course_id
from instructor natural join teaches;
--
select name, title
from instructor natural join teaches, course
where teaches.course_id = course.course_id;
-- identical
select name, title
from instructor natural join teaches natural join course;
--
select name, title
from (instructor natural join teaches) join course using (course_id);

-- 3.4.1 the rename operation (74p.)
select name, course_id
from instructor, teaches
where instructor.ID = teaches.ID;
--
select name as instructor_name, course_id
from instructor, teaches
where instructor.ID = teaches.ID;
--
select T.name, S.course_id
from instructor as T, teaches as S
where T.ID = S.ID;
--
select distinct T.name
from instructor as T, instructor as S
where T.salary > S.salary and S.dept_name = 'Biology';

-- 3.4.2 string operations (p.76)
select dept_name
from department
where building like '%Watson%';

-- 3.4.3 attribute specification in select clause (p.77)
select instructor.*
from instructor, teaches
where instructor.ID = teaches.ID;

-- 3.4.4 ordering the display of tuples (p.77)
select name
from instructor
where dept_name = 'Physics'
order by name;
--
select *
from instructor
order by salary desc, name asc;

-- 3.4.5 where clause predicates (p.78)
select name
from instructor
where salary between 90000 and 100000;
-- instead of:
select name
from instructor
where salary <= 100000 and salary >= 90000;
-- "not between" is also possible.
select name, course_id
from instructor, teaches
where instructor.ID = teaches.ID and dept_name = 'Biology';
-- tuple comparison
select name, course_id
from instructor, teaches
where (instructor.ID, dept_name) = (teaches.ID, 'Biology')

-- 3.5 set operations (p.79)
select course_id
from section
where semester = 'Fall' and year = 2009;
--
select course_id
from section
where semester = 'Spring' and year = 2010;

-- 3.5.1 the union operation (p.80)
(select course_id
from section
where semester = 'Fall' and year = 2009)
union
(select course_id
from section
where semester = 'Spring' and year = 2010);
-- retain all duplicates
(select course_id
from section
where semester = 'Fall' and year = 2009)
union all
(select course_id
from section
where semester = 'Spring' and year = 2010);

-- 3.5.2 the intersect operation (p.81)
(select course_id
from section
where semester = 'Fall' and year = 2009)
intersect
(select course_id
from section
where semester = 'Spring' and year = 2010);
-- retain all duplicates
(select course_id
from section
where semester = 'Fall' and year = 2009)
intersect all
(select course_id
from section
where semester = 'Spring' and year = 2010);

-- 3.5.3 the except operation (p.82)
(select course_id
from section
where semester = 'Fall' and year = 2009)
except
(select course_id
from section
where semester = 'Spring' and year = 2010);
-- retain all duplicates
(select course_id
from section
where semester = 'Fall' and year = 2009)
except all
(select course_id
from section
where semester = 'Spring' and year = 2010);

-- 3.6 null values (p.83)
select name
from instructor
where salary is null;

-- 3.7 aggregate functinos (p.84)
-- 3.7.1 basic aggregation (p.85)
select avg(salary)
from instructor
where dept_name = 'Comp. Sci.';
-- 
select avg(salary) as avg_salary
from instructor
where dept_name = 'Comp. Sci.';
--
select count(distinct ID)
from teaches
where semester = 'Spring' and year = 2010;
--
select count(*)
from course;

-- 3.7.2 aggregation with grouping (p.86)
select dept_name, avg(salary) as avg_salary
from instructor
group by dept_name;
--
select avg(salary)
from instructor;
--
select dept_name, count(distinct ID) as instr_count
from instructor natural join teaches
where semester = 'Spring' and year = 2010
group by dept_name;
-- erroneous query
/*
select dept_name, ID, avg (salary)
from instructor
group by dept_name;
*/

-- 3.7.3 the having clause (p.88)
select dept_name, avg(salary) as avg_salary
from instructor
group by dept_name
having avg(salary) > 42000;
--
select course_id, semester, year, sec_id, avg(tot_cred)
from takes natural join student
where year = 2009
group by course_id, semester, year, sec_id
having count(ID) >= 2;

-- 3.7.4 aggregation with null and boolean values (p.89)
select sum(salary)
from instructor;

-- 3.8 nested subqueries (p.90)
-- 3.8.1 set membership (p.90)
(select course_id
from section
where semester = 'Spring' and year = 2010)
-- nesting subquery in where clause
select distinct course_id
from section
where semester = 'Fall' and year = 2009 and
	course_id in (select course_id
				from section
				where semester = 'Spring' and year = 2010);
-- not in
select distinct course_id
from section
where semester = 'Fall' and year = 2009 and
	course_id not in (select course_id
					from section
					where semester = 'Spring' and year = 2010);
--
select distinct name
from instructor
where name not in ('Mozart', 'Einstein');
--
select count(distinct ID)
from takes
where (course_id, sec_id, semester, year)
	in (select course_id, sec_id, semester, year
		from teaches
		where teaches.ID = 10101);

-- 3.8.2 set comparison (p.91)
select distinct T.name
from instructor as T, instructor as S
where T.salary > S.salary and S.dept_name = 'Biology';
-- using '> some'
select name
from instructor
where salary > some (select salary
					from instructor
					where dept_name = 'Biology');
-- subquery
(select salary
from instructor
where dept_name = 'Biology');
-- using '> all'
select name
from instructor
where salary > all (select salary
					from instructor
					where dept_name = 'Biology');
-- dept.s for which the avg. salary is >= avg of all
select dept_name
from instructor
group by dept_name
having avg(salary) >= all (select avg(salary)
							from instructor
							group by dept_name);

-- 3.8.3 test for empty relations (p.93)
-- find all courses taught in both fall 2009 and spring 2010
select course_id
from section as S
where semester = 'Fall' and year = 2009 and
	exists (select *
		from section as T
		where semester = 'Spring' and year = 2010 and
		S.course_id = T.course_id);
-- using 'except'
select distinct S.ID, S.name
from student as S
where not exists ((select course_id
				from course
				where dept_name = 'Biology')
				except
				(select T.course_id
				from takes as T
				where S.ID = T.ID));
-- subquery
(select course_id
from course
where dept_name = 'Biology')
-- subquery // not executable by alone
/*
(select T.course_id
from takes as T
where S.ID = T.ID)
*/
-- 3.8.4 test for the absence of duplicate tuples (p.94)
-- find all courses that were offered at most once in 2009
select T.course_id
from course as T
where unique (select R.course_id
			from section as R
			where T.course_id = R.course_id and
			R.year = 2009);
--
select T.course_id
from course as T
where 1 >= (select count(R.course_id) -- errata reported in http://db-book.com/
			from section as R
			where T.course_id = R.course_id and
			R.year = 2009);
--
select T.course_id
from course as T
where not unique (select R.course_id
				from section as R
				where T.course_id = R.course_id and
					R.year = 2009);

-- 3.8.5 subqueries in the from clause (p.95)
select dept_name, avg_salary
from (select dept_name, avg(salary) as avg_salary
	from instructor
	group by dept_name)
where avg_salary > 42000;
--
select dept_name, avg_salary
from (select dept_name, avg(salary)
	from instructor
	group by dept_name)
	as dept_avg (dept_name, avg_salary)
where avg_salary > 42000;
--
select max(tot_salary)
from (select dept_name, sum(salary)
	from instructor
	group by dept_name) as dept_total (dept_name, tot_salary);
-- "lateral"
select name, salary, avg_salary
from instructor I1, lateral (select avg(salary) as avg_salary
							from instructor I2
							where I2.dept_name = I1.dept_name);

-- 3.8.6 the with clause (p.97)
-- find dept.s with the max. budget
with max_budget (value) as
	(select max(budget)
	from department)
select budget
from department, max_budget
where department.budget = max.budget.value;
--
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

-- 3.8.7 scalar subqueries (p.97)
select dept_name,
	(select count(*)
	from instructor
	where department.dept_name = instructor.dept_name)
	as num_instructors
from department;

-- 3.9 modification of the database (p.98)
-- 3.9.1 deletion (p.98)
delete from instructor;
--
delete from instructor
where dept_name = 'Finance';
--
delete from instructor
where salary between 13000 and 15000;
--
delete from instructor
where dept_name in (select dept_name
					from department
					where building = 'Watson');
--
delete from instructor
where salary < (select avg(salary)
				from instructor);

-- 3.9.2 insertion (p.100)
insert into course
	values ('CS-437', 'Database Systems', 'Comp. Sci.', 4);
insert into course (course_id, title, dept_name, credits)
	values ('CS-437', 'Database Systems', 'Comp. Sci.', 4);
insert into course (title, course_id, credits, dept_name)
	values ('Database Systems', 'CS-437', 4, 'Comp.Sci.');
--
insert into instructor
	select ID, name, dept_name, 18000
	from student
	where dept_name = 'Music' and tot_cred > 144;
-- Warning! this may insert an infinite number of tuples
/*
insert into student
	select *
	from student;
*/
insert into student
	values ('3003', 'Green', 'Finance', null);
--
select ID  -- errata reported in http://db-book.com/
from student
where tot_cred > 45;

-- 3.9.3 updates (p.101)
update instructor
set salary = salary * 1.05;
--
update instructor
set salary = salary * 1.05
where salary < 70000;
--
update instructor
set salary = salary * 1.05
where salary < (select avg(salary)
				from instructor);
--
update instructor
set salary = salary * 1.03
where salary > 100000;
update instructor
set salary = salary * 1.05
where salary <= 100000;
--
update instructor
set salary = case
				when salary <= 100000 then salary * 1.05
				else salary * 1.03
			end
--
update student S
set tot_cred = (
	select sum(credits)
	from takes natural join course
	where S.ID = takes.ID and
		takes.grade <> 'F' and
		takes.grade is not null);
--
select case
	when sum(credits) is not null then sum(credits)
	else 0
	end
