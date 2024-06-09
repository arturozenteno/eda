-- Exploratory Data Analysis
-- Investigating data for trends, patterns, and outliers

-- Initial data exploration
SELECT * 
FROM world_layoffs.layoffs_staging_two;

-- Finding maximum total layoffs
SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging_two;

-- Analyzing layoff percentages
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging_two
WHERE percentage_laid_off IS NOT NULL;

-- Identifying companies with complete layoffs
SELECT *
FROM world_layoffs.layoffs_staging_two
WHERE percentage_laid_off = 1;
-- Mostly startups that went out of business

-- Sorting by funds raised to assess company sizes
SELECT *
FROM world_layoffs.layoffs_staging_two
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- Notable findings: BritishVolt, Quibi

-- Companies with the largest single layoffs
SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;

-- Companies with the most total layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_two
GROUP BY company
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;

-- Layoffs by location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_two
GROUP BY location
ORDER BY SUM(total_laid_off) DESC
LIMIT 10;

-- Total layoffs by country
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_two
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

-- Layoffs trend over years
SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_two
GROUP BY YEAR(date)
ORDER BY YEAR(date) ASC;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_two
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

-- Layoffs by company stage
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_two
GROUP BY stage
ORDER BY SUM(total_laid_off) DESC;

-- Companies with highest layoffs per year
WITH Company_Year AS (
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
), Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- Rolling total of layoffs per month
WITH DATE_CTE AS (
  SELECT SUBSTRING(date, 1, 7) AS dates, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging_two
  GROUP BY dates
  ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
