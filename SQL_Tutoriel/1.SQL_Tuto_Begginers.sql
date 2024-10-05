------- SQL For Begginers -------

-- Select Clause
Select * From parks_and_recreation.employee_demographics;

Select first_name,
last_name,
birth_date,
age,
(age + 10) * 10 + 10 # Follow the rules of PEMDAS (Pr - exp - mult - div - add - subs)
From parks_and_recreation.employee_demographics;

Select Distinct gender, first_name 
From parks_and_recreation.employee_demographics;

Select Distinct gender From parks_and_recreation.employee_demographics;



-- WHERE Clause

--- Comparison operators
Select *
From employee_salary
Where first_name = "Leslie"
;

Select *
From employee_salary
Where salary >= 50000 # greater than or equal to
;

Select *
From employee_demographics
Where gender != 'MALE' # don't care about case (low / up)
;
Select *
From employee_demographics
Where birth_date < '1985-01-01' # less than
;

--- Logical operators
Select *
From employee_demographics
Where birth_date < '1985-01-01'
And gender = 'male'
;

Select *
From employee_demographics
Where birth_date < '1985-01-01'
Or gender = 'male'
;

Select *
From employee_demographics
Where birth_date < '1985-01-01'
Or Not gender = 'male'
;

Select *
From employee_demographics
Where (first_name = 'April' and age = 29) or age > 37
;

--- Patterns
Select *
From employee_demographics
Where first_name Like 'Jer%'
;

Select *
From employee_demographics
Where first_name Like '%er%' 
;

Select *
From employee_demographics
Where first_name Like 'a__'  # underscore for a character
;

Select *
From employee_demographics
Where first_name Like 'a___%' # we can combine them
;

Select *
From employee_demographics
Where birth_date Like '1989%' 
;

-- Group By

Select gender
From employee_demographics
Group by gender
;

#  if not in group by or not an agregate function as following we get an error
Select first_name
From employee_demographics
Group by gender
;

Select gender, round(avg(age)) # rounded age for each gender
From employee_demographics
Group by gender
;

Select occupation, salary
From employee_salary
Group by occupation, salary
;

Select gender, AVG(age), MAX(age), min(age),
count(age) # count when grouping by gender
From employee_demographics
Group by gender
;

-- Order by
Select *
From employee_demographics
Order by first_name DESC # ASC by default
;

Select *
From employee_demographics
Order by gender, age DESC
;

# The order of columns matters a lot in the order by clause
Select *
From employee_demographics
Order by age, gender # the gender is useless as age only has unique values
;

# It's not best practice but we can use the position of columns instead of names
# Removing or adding columns could create mistakes
Select *
From employee_demographics
Order by 5, 4
;


-- Having Vs Where

# The aggregate function occurs only after the group by
# This is why the following where clause can not work properly
# as it happens before the group by
Select gender, AVG(age)
From employee_demographics
Where AVG(age) > 40
Group by gender
;

# The Having clause is the solution
Select gender, AVG(age)
From employee_demographics
Group by gender
Having AVG(age) > 40
;

# We can use both clauses
Select occupation, AVG(salary)
From employee_salary
Where occupation Like '%director%'
Group by occupation
Having AVG(salary) > 73000
;


-- Limit & Aliasing

--- Limit
Select *
From employee_demographics
Limit 3;

Select *
From employee_demographics
Order by age DESC
Limit 3
;

Select *
From employee_demographics
Order by age DESC
Limit 2, 1 # Start at position 2 and take the next (only) 1 observation
;


--- Aliasing
Select gender, AVG(age) as avg_age
From employee_demographics
Group by gender
Having avg_age > 40
;