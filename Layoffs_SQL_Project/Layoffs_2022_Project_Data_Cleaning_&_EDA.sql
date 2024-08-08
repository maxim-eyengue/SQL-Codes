####### 2022 Layoffs Data Cleaning & EDA #######

------- Data Cleaning -------

# The data comes from: https://www.kaggle.com/datasets/swaptr/layoffs-2022
# Let's create the database and then load the dataset using the interface
CREATE DATABASE `world_layoffs`;
# To visualize the table
Select *
From layoffs
;

# Cleaning steps:
-- 1. Remove Duplicaltes
-- 2. Standardize the Data (issues with spellling...)
-- 3. Null / Blank Values
-- 4. Remove unuseful columns (especially with massive datasets to save computational time)

# It's important to keep a copy of the raw data in case something wrong happens
# during the data preprocessing.
# Creating another table from the original one
CREATE TABLE layoffs_staging
LIKE layoffs
;
INSERT layoffs_staging
Select *
From layoffs;

Select *
From layoffs_staging
; # The new table is okay


--- 1. Remove duplicates ---

# Assign kind of ids for occurences
Select *,
row_number() over(
Partition by company, industry, total_laid_off, percentage_laid_off, `date`
) as row_num # if we get 2 then it's a duplicate
# `date` as date is a keyword in SQL
From layoffs_staging
; 

# Show the duplicates
With duplicate_cte as
(
Select *,
row_number() over(
Partition by company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions
) as row_num # if we get 2 then it's a duplicate
# `date` as date is a keyword in SQL
From layoffs_staging
)
Select *
From duplicate_cte
Where row_num > 1
;

# Always check to make sure the code works well
Select *
From layoffs_staging
Where company = "Casper"
; # The codes identified duplicates well

# Create another table, insert data and remove duplicates
# Another idea would be to alter the previous table by adding a colun row_num
# then insert the data and filter duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

Select *
From layoffs_staging2
; # we get an empty table

INSERT Into layoffs_staging2
Select *,
row_number() over(
Partition by company, location, industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions
) as row_num # if we get 2 then it's a duplicate
# `date` as date is a keyword in SQL
From layoffs_staging
;

# Fist identify what we delete
Select *
From layoffs_staging2
Where row_num != 1
; 
# Then delete it
Delete
From layoffs_staging2
Where row_num != 1
; # No more duplicates


--- 2. Data Standardization ---

# Remove spaces in the beginning and end of each company
Select company, trim(company) trimmed_comp
From layoffs_staging2
;

Update layoffs_staging2
Set company = trim(company)
;

Select distinct(industry)
From layoffs_staging2
Order by 1
; # we can see there are even nulls and blanks 
# and same companies are written differently (Crypto)

# Visualize the occurences for the industry Crypto
Select *
From layoffs_staging2
Where industry like 'Crypto%'
;

# Make sure all the cryto companies are written the same way
Update layoffs_staging2
Set industry = 'Crypto'
Where industry like 'Crypto%'
;

Select distinct(country)
From layoffs_staging2
Order by 1
; # we got an issue with use

# Make sure all the cryto companies are written the same way
Update layoffs_staging2
Set country = 'United States'
Where country like 'United States%'
; # It fixed it
# We could also have update it using a trailing:
Select distinct(country), trim(Trailing '.' From country)
From layoffs_staging # use the old table as the current has already been updated
Order by 1
;

#  Reformatting the date column from text to date
Select `date`,
str_to_date(`date`, '%m/%d/%Y')
From layoffs_staging2
;

Update layoffs_staging2
Set `date` = str_to_date(`date`, '%m/%d/%Y')
; 

# Changing the type of the date column
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` date
;


--- 3. Null / Blanks Values ---

# There are blanks and nulls in the industry column
Select *
From layoffs_staging2
Where industry is null or industry = ''
;

# Replace blanks by nulls to ease the process
Update layoffs_staging2
Set industry = null
Where industry = ''
;

# We can look at a particular company with null for the industry column
# to verify if we can populate data
Select *
From layoffs_staging2
Where company = 'Airbnb'
; # 'Airbnb' is in the 'Travel' industry. We can populate data to replace the missing values

# Check the industry we can populate in function of companies
Select t1.industry, t2.industry
From layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company and t1.location = t2.location
Where t1.industry is null and t2.industry is not null
;

# Populate data
Update layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company and t1.location = t2.location
Set t1.industry = t2.industry
Where t1.industry is null and t2.industry is not null
;

Select *
From layoffs_staging2
Where industry is null or industry = ''
; # we can see that the missing values have reduced

Select *
From layoffs_staging2
Where company = "Bally's Interactive"; 
# we cannot populate data for this observation as there is only one

# That is all we can do about populating values because the other columns do not allow use
# to populate more

# Some observations have at least 2 columns with nulls. They might be dispensable
Select *
From layoffs_staging2
Where total_laid_off is null and percentage_laid_off is null
;
# Let's delete them
Delete
From layoffs_staging2
Where total_laid_off is null and percentage_laid_off is null
;


--- 4. Remove unusefull columns ---

Select *
From layoffs_staging2
;

# Drop the row_num column as it doesn't serve anymore
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

# Now, we can explore the data get more insights from them.

------- Exploratory Data Analysis -------

# Visualize the data
Select *
From layoffs_staging2
;

# Maximum number and percentage of employees laid off
Select MAX(total_laid_off), MAX(percentage_laid_off)
From layoffs_staging2
;

# Company that laid off all their employees
# --> ordered by number of employees
Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by total_laid_off DESC
;
# --> ordered by funding in millions
Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by funds_raised_millions DESC
;

# Sum of the total layoffs per company
Select company, sum(total_laid_off) all_layoffs
From layoffs_staging2
Group by company
Order by all_layoffs DESC
; # We can recognize the top 3: Amazon, Google and Meta

# Date Range
Select min(`date`), MAX(`date`)
From layoffs_staging2
; # the data was recorded approximately during the covid period
# from its begginning to three years later

# Industries with the most layoffs
Select industry, sum(total_laid_off) all_layoffs
From layoffs_staging2
Group by industry
Order by all_layoffs DESC
; # the industry of consumption, retail,... as from the beginning of COVID people
# were not going out easily. Less people were then required to serve for example in restaurants.
# the industries with less layoffs are the ones which requires less physical contacts 
# between customers and companies

# Countries with the most layoffs
Select country, sum(total_laid_off) all_layoffs
From layoffs_staging2
Group by country
Order by all_layoffs DESC
; # Of course the USA, country the most touched by COVID is also
# the one with the highest number of layoffs

# layoffs by date
Select `date`, sum(total_laid_off) all_layoffs
From layoffs_staging2
Group by `date`
Order by `date` DESC
; # Hard to see the trend but this data can be used for forecasting

# layoffs by year
Select year(`date`) years, sum(total_laid_off) all_layoffs
From layoffs_staging2
Group by years
Order by years DESC
; # the layoffs roughly increase with time

# layoffs per stage 
Select stage, sum(total_laid_off) all_layoffs
From layoffs_staging2
Group by stage
Order by all_layoffs DESC
; # The companies post-ipo (after the initial public offering) such as Amazon
# are the ones with more layoffs.

# Average Percentages of layoffs per company
Select company, avg(percentage_laid_off) avg_percent_layoffs
From layoffs_staging2
Group by company
Order by avg_percent_layoffs DESC
;

# Total layoffs based on years and months
Select substring(`date`, 1, 7) as `year_month`, sum(total_laid_off) all_layoffs
From layoffs_staging2
Where substring(`date`, 1, 7) is not null
Group by `year_month`
Order by `year_month` ASC
;

# Rolling total layoffs based on years and months
With Rolling_Total as
(
Select substring(`date`, 1, 7) as `year_month`, sum(total_laid_off) all_layoffs
From layoffs_staging2
Where substring(`date`, 1, 7) is not null
Group by `year_month`
Order by `year_month` ASC
)
Select `year_month`, all_layoffs,
sum(all_layoffs) over(order by `year_month`) Rolling_total_layoffs
From Rolling_Total
; # We have a month by month progression of layoffs
# In three years, from March 2020 to March 2023, 381_159 employees were laid off
# and this is just the data reported from large companies.

# Sum of the total layoffs per company by year
Select company, Year(`date`) years, sum(total_laid_off) all_layoffs
From layoffs_staging2
Group by company, years
Order by all_layoffs DESC
;

# Total layoffs per company by year with layoffs ranks for each year
With Company_Year (company, years, all_layoffs) as
(
Select company, Year(`date`), sum(total_laid_off)
From layoffs_staging2
Group by company, Year(`date`)
)
Select *,
dense_rank() over(Partition by years order by all_layoffs DESC) layoffs_rank
From Company_Year
Where years is not null
Order by layoffs_rank ASC # by default it's ascending
;

# Top 5 total layoffs ranking of companies by year
With Company_Year (company, years, all_layoffs) as
(
Select company, Year(`date`), sum(total_laid_off)
From layoffs_staging2
Group by company, Year(`date`)
),
Company_Year_Rank as
(
Select *,
dense_rank() over(Partition by years order by all_layoffs DESC) layoffs_rank
From Company_Year
Where years is not null
)
Select *
From Company_Year_Rank
Where layoffs_rank <= 5
; # Great companies such as Amazon, Microsoft, Google, Uber, ...

# This exploration helped us to understand that there was a significant correlation 
# between COVID 19 effects and worldwide layoffs. It is not surprising as a lot of people
# could no longer work properly or consume the way they used to, because of the disease.