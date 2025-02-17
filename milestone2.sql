use salary;
select * from salary1;

-- Average Salary by Industry and Gender  
SELECT Industry, Gender, round(AVG(Annual_Salary_USD),2) AS Average_Salary
FROM salary1
GROUP BY Industry, Gender
ORDER BY Industry, Gender;
    
-- Total salary compensation by job title
SELECT 
    Job_Title, 
    SUM(Annual_Salary_USD + COALESCE(Additional_Monetary_Compensation_USD, 0)) AS Total_Compensation
FROM salary1
GROUP BY Job_Title
ORDER BY Total_Compensation DESC;

-- Salary distribution by heighest level of education completed
SELECT 
    Highest_Level_Of_Education_Completed, 
    round(AVG(Annual_Salary_USD),2) AS Average_Salary, 
    MIN(Annual_Salary_USD) AS Minimum_Salary, 
    MAX(Annual_Salary_USD) AS Maximum_Salary
FROM salary1
GROUP BY Highest_Level_Of_Education_Completed
ORDER BY Average_Salary DESC;

-- Number of employees by industry and year of experience
SELECT 
    Industry, 
    Years_of_Professional_Experience_Overall, 
    COUNT(*) AS Employee_Count
FROM salary1
GROUP BY Industry, Years_of_Professional_Experience_Overall
ORDER BY Industry, Years_of_Professional_Experience_Overall;

-- Median salary by age range and gender
WITH SalaryRanked AS (
    SELECT Age_Range, Gender, 
        Annual_Salary_USD,
        ROW_NUMBER() OVER (PARTITION BY Age_Range, Gender ORDER BY Annual_Salary_USD) AS row_num,
        COUNT(*) OVER (PARTITION BY Age_Range, Gender) AS total_rows
    FROM salary1
    WHERE Annual_Salary_USD IS NOT NULL
)
SELECT 
    Age_Range, 
    Gender, 
    round(AVG(Annual_Salary_USD),2) AS Median_Salary
FROM SalaryRanked
WHERE row_num IN ((total_rows + 1) / 2, (total_rows + 2) / 2)  -- Picks the middle value(s)
GROUP BY Age_Range, Gender
ORDER BY Age_Range, Gender;

-- Job title with heighest sal in each country
WITH RankedSalaries AS (
    SELECT Country, Job_Title, Annual_Salary_USD, 
        RANK() OVER (PARTITION BY Country ORDER BY Annual_Salary_USD DESC) AS rank_num
    FROM salary1
    WHERE Annual_Salary_USD IS NOT NULL
)
SELECT Country, Job_Title, Annual_Salary_USD
FROM RankedSalaries
WHERE rank_num = 1
ORDER BY Country, Annual_Salary_USD DESC;

-- Average Salary by City and Industry  
SELECT City, Industry, 
    round(AVG(Annual_Salary_USD),2) AS Avg_Salary
FROM salary1
WHERE Annual_Salary_USD IS NOT NULL
GROUP BY City, Industry
ORDER BY City, Avg_Salary DESC;

-- % of emp with additional man comp with gender
SELECT 
    Gender, 
    COUNT(CASE WHEN Additional_Monetary_Compensation_USD > 0 THEN 1 END) * 100.0 / COUNT(*) AS Percentage_With_Compensation
FROM salary1
WHERE Gender IS NOT NULL
GROUP BY Gender
ORDER BY Percentage_With_Compensation DESC;

-- Total comp by job title and year of experience
SELECT Job_Title, Years_of_Professional_Experience_Overall, 
  SUM(Annual_Salary_USD + IFNULL(Additional_Monetary_Compensation_USD, 0)) AS Total_Compensation
FROM salary1
WHERE Job_Title IS NOT NULL AND Years_of_Professional_Experience_Overall IS NOT NULL
GROUP BY Job_Title, Years_of_Professional_Experience_Overall
ORDER BY Total_Compensation DESC;

-- Average Salary by Industry, Gender, and Education Level 
SELECT Industry, Gender, Highest_Level_Of_Education_Completed, 
    round(AVG(Annual_Salary_USD),2) AS Average_Salary
FROM salary1
WHERE Annual_Salary_USD IS NOT NULL
GROUP BY Industry, Gender, Highest_Level_Of_Education_Completed
ORDER BY Industry, Gender, Highest_Level_Of_Education_Completed;
