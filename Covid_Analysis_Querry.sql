SELECT *
FROM PortfolioProject..Covid_Deaths
ORDER BY 2

--SELECT *
--FROM PortfolioProject..Covid_Vaccinations
--ORDER BY 3,4

--Select Data that we are gonna use

--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM PortfolioProject..Covid_Deaths
--ORDER BY 1,2

--Focusing at Total Cases and Total Deaths 

SET ANSI_WARNINGS OFF
-- Set divide by zero warnings off

ALTER TABLE PortfolioProject..Covid_Deaths
ALTER COLUMN total_cases FLOAT NULL;

ALTER TABLE PortfolioProject..Covid_Deaths
ALTER COLUMN total_deaths FLOAT NULL;


ALTER TABLE PortfolioProject..Covid_Deaths
ALTER COLUMN new_cases FLOAT NULL;

ALTER TABLE PortfolioProject..Covid_Deaths
ALTER COLUMN new_deaths FLOAT NULL;

ALTER TABLE PortfolioProject..Covid_Deaths
ALTER COLUMN population FLOAT NULL;

-- Change data type because we use it for math operations

SELECT location, date, total_cases, total_deaths, (total_deaths /total_cases)*100 AS Death_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE location = 'Turkey'
ORDER BY 1,2

-- Focusing at Total Cases and Population

SELECT location, date, population, total_cases, (total_cases/ population)*100 AS Infection_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE location = 'Turkey'
ORDER BY 1,2

-- Focusing at Countries with Highest Infection Rate 
SELECT location, population, MAX(total_cases) AS Highest_Infection, MAX((total_cases/ population))*100 AS Highest_Infection_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Focusing at Countries with Highest Death Rate
SELECT location, population, MAX(total_deaths) AS Total_Death, MAX((total_deaths/ population))*100 AS Highest_Death_Percentage
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC


--Global Deaths and Cases
SELECT SUM(new_cases) AS Total_cases , SUM(CAST(new_deaths AS FLOAT)) AS Total_Death, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 AS Death_Per_Case_Percentage_in_World
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1

-- JOIN TWO TABLE

SELECT D.location, D.date, D.population, V.new_vaccinations
, SUM(CAST(V.new_vaccinations AS FLOAT)) OVER (PARTITION BY V.location ORDER BY D.location, D.date) AS Total_Vaccinated_People
--, (Total_Vaccinated_People/population)*100 -- ERROR let's go to CTE's
FROM PortfolioProject..Covid_Deaths D
JOIN PortfolioProject..Covid_Vaccinations V
	ON D.location = V.location AND D.date= V.date
WHERE D.continent IS NOT NULL 
ORDER BY 1,2 

-- CTE

With Population_and_Vaccination (Location, Date, Population, New_Vaccinations, Total_Vaccinated_People)
as
(
SELECT D.location, D.date, D.population, V.new_vaccinations
, SUM(CAST(V.new_vaccinations AS FLOAT)) OVER (PARTITION BY V.location ORDER BY D.location, D.date) AS Total_Vaccinated_People
--, (Total_Vaccinated_People/population)*100 -- ERROR let's go to CTE's
FROM PortfolioProject..Covid_Deaths D
JOIN PortfolioProject..Covid_Vaccinations V
	ON D.location = V.location AND D.date= V.date
WHERE D.continent IS NOT NULL 
)
Select *, (Total_Vaccinated_People/Population)*100 AS Vaccinated_Percentage
From Population_and_Vaccination
ORDER BY 1,2

--Temp Table 


DROP Table if exists #Vaccinated_Percentage
Create Table #Vaccinated_Percentage
(
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations float,
Total_Vaccinated_People float
)

Insert into #Vaccinated_Percentage
SELECT D.location, D.date, D.population, V.new_vaccinations
, SUM(CAST(V.new_vaccinations AS FLOAT)) OVER (PARTITION BY V.location ORDER BY D.location, D.date) AS Total_Vaccinated_People
--, (Total_Vaccinated_People/population)*100 -- ERROR let's go to CTE's
FROM PortfolioProject..Covid_Deaths D
JOIN PortfolioProject..Covid_Vaccinations V
	ON D.location = V.location AND D.date= V.date
WHERE D.continent IS NOT NULL 

Select *, (Total_Vaccinated_People/Population)*100 AS Vaccinated_Percentage
From #Vaccinated_Percentage
ORDER BY 1,2



Create View Vaccinated_Percentage as
SELECT D.location, D.date, D.population, V.new_vaccinations
, SUM(CAST(V.new_vaccinations AS FLOAT)) OVER (PARTITION BY V.location ORDER BY D.location, D.date) AS Total_Vaccinated_People
--, (Total_Vaccinated_People/population)*100 -- ERROR let's go to CTE's
FROM PortfolioProject..Covid_Deaths D
JOIN PortfolioProject..Covid_Vaccinations V
	ON D.location = V.location AND D.date= V.date
WHERE D.continent IS NOT NULL 

SELECT*
FROM Vaccinated_Percentage