/*-------------------------------------------------------------------------------------*
   | Name:      Data Cleaning Project
   | Author:    Steven Haden                                                            |
   | Date:      1-16-2025                                                               |
   |------------------------------------------------------------------------------------|
   | Purpose:   This script has been created to practice data cleaning using MySQL      |
   |                                                                                    |
   *-------------------------------------------------------------------------------------
   */
   
   #Create a working table
   CREATE TABLE layoffs_stage
   Like layoffs;
   
   INSERT INTO layoffs_stage
   SELECT *
   FROM layoffs;
   
   SELECT * 
   FROM layoffs_stage;
   
   #Check for duplicates
   
  WITH duplicate_cte AS
   (
   SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions, 
   ROW_NUMBER() Over(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
   FROM layoffs_stage
   )
   
   SELECT *
   FROM duplicate_cte
   Where row_num > 1;
   
   #Create a table to work with duplicates
   
   CREATE TABLE `layoffs_stage2` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#Populate the duplicates table

   INSERT INTO layoffs_stage2
   SELECT *,
   ROW_NUMBER() Over(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
   FROM layoffs_stage;

select *
From layoffs_stage2
WHERE row_num>1;

select *
From layoffs_stage2
WHERE company like 'hib%';

#Remove duplicates

DELETE
FROM layoffs_stage2
WHERE row_num > 1;

#Standardize data/fix errors

UPDATE layoffs_stage2
set company = trim(company);

UPDATE layoffs_stage2
set country = trim(trailing '.' from country)
WHERE country LIKE 'United States%';

UPDATE layoffs_stage2
SET date = str_to_date(date, '%m/%d/%YYYY');

#Evaluate/fix blanks

UPDATE layoffs_stage2
SET industry = 'Travel'
WHERE company Like 'airbnb'
AND Industry = '';

UPDATE layoffs_stage2
SET industry = 'Tranportation'
WHERE company Like 'carvana'
AND Industry = '';

UPDATE layoffs_stage2
SET industry = 'Consumer'
WHERE company Like 'juul'
AND Industry = '';   

#Evaluate/fix nulls
select *
From layoffs_stage2
where total_laid_off is null
and percentage_laid_off is null;

DELETE
FROM layoffs_stage2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

select *
From layoffs_stage2
where funds_raised_millions is null;  

#Remove unneccesary column

ALTER TABLE layoffs_stage2
DROP COLUMN row_num;

select *
From layoffs_stage2