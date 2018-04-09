# Ch06 Practice Exercises

Answer: http://codex.cs.yale.edu/avi/db-book/db6/practice-exer-dir/6s.pdf

6.1 Write the following queries in relational algebra, using the university schema.

- a. Find the titles of courses in the Comp. Sci. department that have 3 credits. 

  - ```mysql
    select title
    from course
    where credits = 3, dept_name = 'Comp. Sci.';
    ```
  - $\Pi_{title}(\sigma_{credits=3 \and dept\_name = 'Comp. Sci.'}(course))$ 

- b. Find the IDs of all students who were taught by an instructor named Einstein; make sure there are no duplicates in the result.

  - ```sql
    select distinct ID
    from takes
    where course_id in (select course_id
                       from course natural join instructor
                       where name = 'Einstein');
    ```

  - $ \Pi_{ID}(\sigma_{course\_id \in \Pi_{course\_id}(\sigma_{name = 'Einstein'}(course \bowtie instructor)}(takes)) $ 

  - $ \Pi_{ID}(\sigma_{IID = 'Einstein'}(takes \bowtie \rho_{t1(IID, course\_id, section\_id, semester, year)}teaches)) $

- c. Find the highest salary of any instructor.

  - ```sql
    select salary
    from instructor
    where salary not in (select T.salary
                        from instructor as T, instructor as S
                        where T.salary < S.salary);
    ```

  - ```sql
    (select salary
    from instructor)
    except
    (select T.salary
    from instructor as T, instructor as S
    where T.salary < S.salary);
    ```

  - $ \Pi_{salary}(instructor) - \Pi_{instructor.salary}(\sigma_{instructor.salary < d.salary}(instructor \times \rho_{d}(instructor))) $

  - Or, simply… $ \mathcal{G}_{\text{max}(salary)}(instructor) $

- d. Find all instructors earning the highest salary (there may be more than one with the same salary).

  - ```sql
    select name
    from instructor
    where salary = (select salary
                    from instructor
                    where salary not in (select T.salary
                    from instructor as T, instructor as S
                    where T.salary < S.salary));
    ```

  - $ \Pi_{name}(\sigma_{salary \in \Pi_{salary}(instructor) - \Pi_{instructor.salary}(\sigma_{instructor.salary < d.salary}(instructor \times \rho_{d}(instructor)))}(instructor)) $

  - $ instructor \bowtie (\mathcal{G}_{\text{max}(salary)~\text{as}~salary}(instructor)) $ 

- e. Find the enrollment of each section that was offered in Autumn 2009.

  - ```sql
    select course_id, count(*) as enrollment -- Pi_{A,B} = select A,B
    from takes
    where (semester, year) = ('Fall', 2009)
    group by course_id, sec_id; -- prefix of \mathcal{G}
    ```

  - $ \Pi_{course\_id, enrollment}(_{course\_id, sec\_id}\mathcal{G}_{\text{count(*)}~\text{as}~enrollment}(\sigma_{year=2009 \and semester='Fall'}(takes))) $

  - (Projection is not included in intended answer)

- f. Find the maximum enrollment, across all sections, in Autumn 2009.

  - $ t1 \leftarrow  \Pi_{course\_id, enrollment}(_{course\_id, sec\_id}\mathcal{G}_{\text{count(*)}~\text{as}~enrollment}(\sigma_{year=2009 \and semester='Fall'}(takes)))  $
  - $ result = \mathcal{G}_{\text{max}(enrollment)}(t1) $

- g. Find the sections that had the maximum enrollment in Autumn 2009.

  - $ t2 \leftarrow \mathcal{G}_{\text{max}(enrollment)~\text{as}~enrollment}(t1) $
  - $ result = \sigma_{enrollment = t2}(t1) $
  - $ result = t1 \bowtie t2 $


6.2 Consider the relational database of Figure 6.22, where the primary keys are underlined. Give an expression in the relational algebra to express each of the following queries:

```
employee (*person_name*, street, city)
works (*person_name*, company_name, salary)
company (*company_name*, city)
manages (*person_name*, manager_name)
```



- a. Find the names of all employees who live in the same city and on the same street as do their managers.
  - ​


- b. Find the names of all employees in this database who do not work for "First Bank Corporation".
- c. Find the names of all employees who earn more than every employee of "Small Bank Corporation".