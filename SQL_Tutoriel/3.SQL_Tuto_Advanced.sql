------- SQL For Advanced -------

-- CTEs
# Common Table Expression to define a subquery block that
# can be referenced within the main query
# useful for better readability in comparison to subquery in From 
# or to perform more advanced calculations
With CTE_Example_1 AS
(
Select gender,
avg(salary) avg_salary,
MAX(salary) max_salary,
min(salary) min_salary,
count(salary) count_salary
From employee_demographics dem
Join employee_salary sal
	On dem.employee_id = sal.employee_id
Group by gender
)
Select *
From CTE_Example_1
;

# The aliasing can be done differently
With CTE_Example_1_bis (gender, avg_salary, max_salary, min_salary, count_salary) AS
(
Select gender, avg(salary), MAX(salary), min(salary), count(salary)
From employee_demographics dem
Join employee_salary sal
	On dem.employee_id = sal.employee_id
Group by gender
)
Select *
From CTE_Example_1_bis
;

With CTE_Example_2 AS
(
Select gender,
avg(salary) avg_salary,
MAX(salary) max_salary,
min(salary) min_salary,
count(salary) count_salary
From employee_demographics dem
Join employee_salary sal
	On dem.employee_id = sal.employee_id
Group by gender
)
Select avg_salary
From CTE_Example_2
; # Note that a cte can only be used by the request following it immediately

Select avg_salary
From (
Select gender,
avg(salary) avg_salary,
MAX(salary) max_salary,
min(salary) min_salary,
count(salary) count_salary
From employee_demographics dem
Join employee_salary sal
	On dem.employee_id = sal.employee_id
Group by gender
) corresponding_subquery
;

# Multiple CTEs within just one:
With CTE_Example_A AS
(
Select employee_id, gender, birth_date
From employee_demographics 
Where birth_date > '1985-01-01'
),
CTE_Example_B AS
(
Select employee_id, salary
From employee_salary
Where salary > 50000
)
Select *
From CTE_Example_A CTE_A
Join CTE_Example_B CTE_B
	On CTE_A.employee_id = CTE_B.employee_id
;


-- Temporary Tables
# tables only visible to the session that created them
# to manipulate data before storing it in a permanent table
# for intermediate results and calculations...

Create Temporary Table temp_table
(first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
)
;

Select *
From temp_table
;

Insert Into temp_table
Values ('Maxim', 'Eyengue', "Love don't cost a thing")
;

Select *
From temp_table
;

Select *
From employee_salary
;

Create Temporary Table salary_over_50k
Select *
From employee_salary
Where salary >= 50000
;

Select *
From salary_over_50k
;
# Temp tables are generally used for more advanced stuff than CTEs
# such as stored procedures

-- Stored Procedures
# helps to save sql code in order to re-use it over and over

Select *
From employee_salary
Where salary  >= 50000
;

Use parks_and_recreation; # to specify the database
Create Procedure large_salaries()
Select *
From employee_salary
Where salary  >= 50000
;

Call large_salaries(); # stored procedure call

# Changing the delimiter for the stored procedure to contain the 2 requests
DELIMITER $$
Create Procedure large_salaries2()
BEGIN
	Select *
	From employee_salary
	Where salary  >= 50000
	;
	Select *
	From employee_salary
	Where salary  >= 10000
	;
END $$
DELIMITER ;

Call large_salaries2();

# We can also generate the code using the interface. 
# We will only have to write the request
# The resulting code is as follows:

USE `parks_and_recreation`;
DROP procedure IF EXISTS `new_procedure`;

DELIMITER $$
USE `parks_and_recreation`$$
CREATE PROCEDURE `new_procedure` ()
BEGIN
	Select *
	From employee_salary
	Where salary  >= 50000
	;
	Select *
	From employee_salary
	Where salary  >= 10000
	;
END$$

DELIMITER ;

# We want to pass in an employee_id and get as output the corresponding salary
# We will use parameters
DELIMITER $$
USE `parks_and_recreation`$$
CREATE PROCEDURE large_salaries3(p_emp_id Int)
BEGIN
	Select salary
	From employee_salary
    Where employee_id = p_emp_id
	;
END$$
DELIMITER ;
Call large_salaries3(1)


-- Triggers and Events

--- Trigger
# A trigger is a block of code that executes automatically
# when an event takes place on a specific table

# Update the demographics table based on insertion of new employees in the salary table
Select *
From employee_demographics
;

Select *
From employee_salary
;

# Changing the delimiter to have multiple queries within our trigger
DELIMITER $$
Create Trigger employee_insert
	After Insert on employee_salary # after: as update dem after new info is put into sal
    # Before is also possible: before data is deleted for example
    For Each Row # a trigger will be activated for each row inserted
    # With some servers such as  Ms server there is batch trigger and table level trigger
    # which triggers only once
BEGIN
	Insert Into employee_demographics (employee_id, first_name, last_name)
    Values (New.employee_id, New.first_name, New.last_name);
    # `New` for the rows inserted and `Old` for the deleted \ updated ones
END $$
DELIMITER ;

Insert Into employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
Values (17, "Michael-Antony", "Escobar", "Intern Manager", 100000, NULL);

Select *
From employee_salary
;

Select *
From employee_demographics
;

--- Events
# an event takes place when it is scheduled (daily, monthly, yearly, ...)
# Event to retire people over the age of 60 and give them lifetime pay
Select *
From employee_demographics
;

DELIMITER $$
Create Event delete_retirees
On Schedule Every 30 Second
Do
BEGIN
	Delete
    From employee_demographics
    Where age >= 60
    ;
END $$
DELIMITER ;

Select *
From employee_demographics
; # Jerry has been deleted

# When it does not work check if the event is off as follows:
Show Variables Like 'event%'; # and update it as on if yes
# If the permission to delete is not granted
# go to edit --> preferences --> sql editor
# uncheck the box safe updates

