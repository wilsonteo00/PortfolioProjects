/*
COVID19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Function, Aggregate Functions, Creating Views, Converting Data Types

Dataset link: https://ourworldindata.org/covid-deaths

This project has 2 parts 
First Part: Meant to practise querying from multiple files and extracting useful information from a large database setting. 
Second Part: Meant to practise querying specific information to be visualised using Tableau Public
Link to second part can be found in my tableau public: https://public.tableau.com/app/profile/wilson.teo/viz/CovidDashboard_16253811445760/Dashboard1

*/

-- Initial Look

SELECT *
FROM dbo.CovidDeaths
ORDER BY 3,4


-- Select out the data
-- Use CONVERT to change date column into datetime and specify initial format as "dd/mm/yyyy"

SELECT Location, CONVERT(DATETIME,date,103), total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2 

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if someone contracts COVID in Singapore

SELECT Location, CONVERT(DATETIME,date,103), total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%singapore%'
ORDER BY 1,2 


-- Total Cases vs Population
-- Shows what percentage of population contract COVID in Singapore
-- Cast population as float instead of int (To avoid getting all zeros in the calculated column)

SELECT Location, CONVERT(DATETIME,date,103), population, total_cases, (total_cases/cast(population as float))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location like '%singapore%'
ORDER BY 1,2 

-- Countries with Highest Infection Rate compared to Population
-- Filter out the data points with population as zero

SELECT Location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((total_cases/cast(population as float)))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE (population is not null AND population != ' ')
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 


-- Countries with Highest Death Count per Population
-- Total Deaths return as non-integer which is not useful for doing Max function

SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE (continent is not null AND continent != ' ')
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- Specific datas from countries of interest
-- New cases, new death and new vaccination for the past 10 days

SELECT CONVERT(DATETIME,dea.date,103) as date, dea.location, dea.population, dea.total_cases, dea.new_cases, dea.new_deaths, vac.new_vaccinations_smoothed
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE (dea.continent is not null AND dea.continent != ' ')
and dea.location in ('Singapore', 'Malaysia', 'Thailand', 'Indonesia')
and CONVERT(DATETIME,dea.date,103) >= DATEADD(day, -10, GETDATE())
ORDER BY location, CONVERT(DATETIME,dea.date,103) DESC

-- New cases, total cases and percentage of total population infected till date for the past 10 days

SELECT  CONVERT(DATETIME,date,103) as date, Location, population, MAX(cast(new_cases as int)) as NewCaseCount, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((total_cases/cast(population as float)))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE (population is not null AND population != ' ')
and location in ('Singapore', 'Malaysia', 'Thailand', 'Indonesia')
and CONVERT(DATETIME,date,103) >= DATEADD(day, -10, GETDATE())
GROUP BY location, population, CONVERT(DATETIME,date,103)
ORDER BY PercentPopulationInfected DESC 


-- Continue analysing by continent

-- Showing continents with the highest death count per popular

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE (continent is not null AND continent != ' ')
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- Global Numbers by date
-- NULLIF/ISNULL method to bypass divide by zero error

SELECT CONVERT(DATETIME,date,103), SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as float)) as total_death,
       ISNULL(SUM(cast(new_deaths as float))/NULLIF(SUM(cast(new_cases as int)),0),0)*100 as DeathPercent
FROM dbo.CovidDeaths
WHERE (continent is not null AND continent != ' ')
GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Using partition to generate a counter by individual country

SELECT dea.continent, dea.location, CONVERT(DATETIME,dea.date,103) as date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
CONVERT(DATETIME,dea.date,103)) as RollingPeopleVaccinated 
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE (dea.continent is not null AND dea.continent != ' ')
ORDER BY 2,3


-- 1st method: Using CTE to do additional division on Partition created in the previous query
-- Showing percentage of population vaccinated
-- Case method to bypass divide by zero error

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, CONVERT(DATETIME,dea.date,103) as date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
CONVERT(DATETIME,dea.date,103)) as RollingPeopleVaccinated 
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE (dea.continent is not null AND dea.continent != ' ')
)
SELECT *, CASE WHEN population = 0 THEN 0 ELSE (cast(RollingPeopleVaccinated as float)/population*100) END as VaccinatedPercent
FROM PopvsVac


-- 2nd method: Using Temp table to do additional division on Partition created in the previous query
-- Showing percentage of population vaccinated 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population nvarchar(255),
New_vaccinations nvarchar(255),
RollingPeopleVaccinated nvarchar(255),
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, CONVERT(DATETIME,dea.date,103) as date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
CONVERT(DATETIME,dea.date,103)) as RollingPeopleVaccinated 
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE (dea.continent is not null AND dea.continent != ' ')

SELECT *, CASE WHEN population = 0 THEN 0 ELSE (cast(RollingPeopleVaccinated as float)/population*100) END as VaccinatedPercent
FROM #PercentPopulationVaccinated



-- Creating View to store data for visualisation

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, CONVERT(DATETIME,dea.date,103) as date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
CONVERT(DATETIME,dea.date,103)) as RollingPeopleVaccinated 
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE (dea.continent is not null AND dea.continent != ' ')




-- SQL enquries for Tableau Visualisation
-- Below are queries linked to visualisation on Tableau Public
-- Output will be copied to excel before uploading to Tableau Public

-- Tableau visualisation table 1 
-- Global Numbers

SELECT SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as float)) as total_death,
       ISNULL(SUM(cast(new_deaths as float))/NULLIF(SUM(cast(new_cases as int)),0),0)*100 as DeathPercent
FROM dbo.CovidDeaths
WHERE (continent is not null AND continent != ' ')
ORDER BY 1,2

-- Tableau visualisation table 2
-- Death count by continent (Sorting by continent will not give the correct numbers)
-- Removing European union as it is part of Europe

SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE (continent is null OR continent = ' ')
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- Tableau visualisation table 3
-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((cast(total_cases as int)/cast(population as float)))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE (population is not null AND population != ' ')
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 

-- Tableau visualisation table 4
-- Total infection count and percentage of population infected

SELECT Location, population, CONVERT(DATETIME,date,103) as date, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((total_cases/cast(population as float)))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE (population is not null AND population != ' ')
GROUP BY location, population, CONVERT(DATETIME,date,103)
ORDER BY PercentPopulationInfected DESC 



