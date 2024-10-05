------- SQL For Intermediate -------

-- Joins

Select *
From employee_demographics
;

Select *
From employee_salary
;

--- Inner Join
# The data resulting from this join are the data common to both tables 
Select *
From employee_demographics as dem
Inner Join employee_salary as sal # By default it's an inner join
	On dem.employee_id = sal.employee_id
;

Select dem.employee_id, age, occupation
From employee_demographics as dem
Inner Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

Select dem.employee_id, age, occupation
From employee_demographics as dem
Inner Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

--- Outer Join (Left/ Right)
# The resulting data comes from the first (left) table and add the observations 
# of the 2nd (right) one which were already in the first
# The opposite for the right outer join
# Note that it help to add columns from the right table to observations of the left one
Select dem.employee_id, age, occupation
From employee_demographics as dem
Left Outer Join employee_salary as sal # the clause 'left join' can also work
	On dem.employee_id = sal.employee_id
;

Select *
From employee_demographics as dem
Right Join employee_salary as sal # the clause 'left join' can also work
	On dem.employee_id = sal.employee_id
; # When there is no match it populates a NULL


--- Self Join
# Joining a table to itself
Select *
From employee_salary as emp1
Join employee_salary emp2 # 'as' is optional
	On emp1.employee_id = emp2.employee_id
;

Select *
From employee_salary emp1
Join employee_salary emp2
	On emp1.employee_id + 1 = emp2.employee_id # match each id to the next one 
;

Select emp1.employee_id as emp_santa,
emp1.first_name as first_name_santa,
emp1.last_name as last_name_santa,
emp2.employee_id as emp,
emp2.first_name as first_name_emp,
emp2.last_name as last_name_emp
From employee_salary emp1
Join employee_salary emp2
	On emp1.employee_id + 1 = emp2.employee_id 
;

# To join many tables together
Select *
From employee_demographics as dem
Inner Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

Select *
From parks_departments # reference table which doesn't change that much easily
;

Select *
From employee_demographics as dem
Inner Join employee_salary as sal
	On dem.employee_id = sal.employee_id
Inner Join parks_departments as pd
	On sal.dept_id = pd.department_id
;

-- Unions
# combine rows together by using select statements

Select age, gender
From employee_demographics;

Select first_name, last_name
From employee_salary
;

Select age, gender
From employee_demographics
UNION # this union however is not good
# mixing age and gender with names gives bad data 
Select first_name, last_name
From employee_salary
;

Select first_name, last_name
From employee_demographics
UNION # union distinct by default
# duplicates are removed 
Select first_name, last_name
From employee_salary
;

Select first_name, last_name
From employee_demographics
UNION ALL # to keep all results including duplicates
Select first_name, last_name
From employee_salary
;

Select first_name, last_name, 'Old' as label
From employee_demographics
Where age > 50
;

Select first_name, last_name, 'Old Man' as label
From employee_demographics
Where age > 40 and gender = 'Male'
UNION
Select first_name, last_name, 'Old Female' as label
From employee_demographics
Where age > 40 and gender = 'Female'
UNION  
Select first_name, last_name, 'Highly Paid Employee' as label
From employee_salary
Where salary > 70000
Order by first_name, last_name
;

-- String Functions

--- Length
Select length('Skyfall');
Select first_name, length(first_name)
From employee_demographics
Order by 2
;

--- Upper and Lower
Select upper('ManitoBa') up, lower('SAN ANtonio') low;
Select first_name, Upper(first_name)
From employee_demographics
;

--- Trim
# to get rid of the white space at the front and end of strings
Select rtrim('                    Sky            ') as rtrim,
Ltrim('                    Sky            ') as ltrim,
trim('                    Sky            ') as trim, 
('                    Sky            ') as untrimmed
;

--- substring, left and right
Select first_name, 
left(first_name, 4), # 4 characters from the left
right(first_name, 4), # 4 characters from the right
substring(first_name, 3, 2), # take 2 characters from the third position
substring(birth_date, 6, 2) # pull out month number from date
From employee_demographics
;

--- Replace
Select first_name, replace(first_name, 'a', 'z') # cares about case
From employee_demographics
;

--- Locate
Select locate('x', 'Alexander');
Select first_name, locate('An', first_name)
From employee_demographics
;

--- Concat
Select first_name, last_name,
concat(first_name, ' ', last_name) as full_name
From employee_demographics
;


-- Case statement
# allows to add logic as if else statement
Select first_name, last_name, age,
CASE
	When age <= 30 Then 'Young'
    When age between 31 and 50 Then 'Old' # between is inclusive
    When age > 50 Then "On Death's door"
END as age_bracket
From employee_demographics
;

# Pay increase and bonus
# < 50000 = 5%
# > 50000 = 7%
# Finance = 10%
Select first_name, last_name, salary,
CASE
	When salary < 50000 Then salary * 1.05
    When salary > 50000 Then salary + (salary * 0.07)
END new_salary,
CASE
	When dept_id = 6 Then salary * .1
END bonus
From employee_salary
;

# Last task with a join to improve the department condition
Select first_name, last_name, salary,
CASE
	When salary < 50000 Then salary * 1.05
    When salary > 50000 Then salary + (salary * 0.07)
END new_salary,
CASE
	When pd.department_name = 'finance' Then salary * .1
END bonus
From employee_salary as sal
Left Join parks_departments as pd 
# A left join to make sure all data of the left table is kept
	On sal.dept_id = pd.department_id
;

-- Subqueries
# A subquery is a query within another one

--- In the Where clause
Select * # outer query
From employee_demographics
Where employee_id in 
				(Select employee_id # subquery
                # this operand / select clause should contain only 1 column
					From employee_salary
					Where dept_id = 1)
; # takes everything from the outer table whose id is in the subtable

--- In the Select clause
Select first_name, salary, 
# avg requires a group by when used in the select clause with other columns
# a subquery can help to get the desired result
(Select avg(salary) From employee_salary) avg_salary
From employee_salary
;

--- In the From clause
Select gender, avg(age), max(age), min(age), count(age)
From employee_demographics
Group by gender
;

Select gender, avg(`max(age)`)
From 
(Select gender, avg(age), max(age), min(age), count(age)
From employee_demographics
Group by gender) as agg_table
Group by gender
;

Select avg(max_age)
From 
(Select gender, 
avg(age) as avg_age,
max(age) as max_age,
min(age) as min_age,
count(age) as count_age
From employee_demographics
Group by gender) as agg_table
;


-- Window Functions
# somewhat like a group by but allows to look at a partition or a group 
# that each keeps their own unique rows in the output

Select gender, avg(salary) avg_salary
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
Group by gender # rolls everything up into one row
;

Select gender, avg(salary) over() # window function
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

Select gender, avg(salary) over(Partition by gender)
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
; # gives the same information as the previous group by but with more occurences

Select dem.first_name, dem.last_name, gender,
avg(salary) over(Partition by gender)
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
; # it allows to add additional information so that they are not taken
# into account as they would for the group by operation

Select dem.first_name, dem.last_name, gender,
sum(salary) over(Partition by gender)
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

# For a rolling total
Select dem.first_name, dem.last_name, gender, salary,
sum(salary) over(Partition by gender Order by dem.employee_id) as rolling_total
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

Select dem.first_name, dem.last_name, gender, salary,
sum(salary) over(Order by dem.employee_id) as rolling_total
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

-- Row number
Select dem.employee_id, dem.first_name, dem.last_name, gender, salary,
Row_number() over() # without duplicates
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

Select dem.employee_id, dem.first_name, dem.last_name, gender, salary,
Row_number() over(Partition by gender) # we can now have duplicates for row numbers
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

Select dem.employee_id, dem.first_name, dem.last_name, gender, salary,
Row_number() over(Partition by gender Order by salary DESC)
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;

-- RANK and DENSE_RANK
Select dem.employee_id, dem.first_name, dem.last_name, gender, salary,
Row_number() over(Partition by gender Order by salary DESC) as row_num,
# row_number has no duplicates numbers in each partition
Rank() over(Partition by gender Order by salary DESC) as rank_num,
# rank assigns the same number when encounting a duplicate based on order by
# and the next number is the next positionally (eventually skipping numbers)
Dense_rank() over(Partition by gender Order by salary DESC) as rank_num
# the difference with rank is that the next number in case of duplicates is 
# the next one numerically
From employee_demographics as dem
Join employee_salary as sal
	On dem.employee_id = sal.employee_id
;
