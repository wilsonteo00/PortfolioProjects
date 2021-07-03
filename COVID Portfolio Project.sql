/*
COVID19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types

Dataset link: https://ourworldindata.org/covid-deaths

This project is meant to practise querying from multiple files and extracting useful information from a large database setting. 

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

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/cast(population as float)))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE (population is not null AND population != ' ')
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 


-- Showing Countries with Highest Death Count per Population
-- Total Deaths return as non-integer which is not useful for doing Max function

SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE (continent is not null AND continent != ' ')
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- Continue analysing by continent

-- Showing continents with the highest death count per popular

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE (continent is not null AND continent != ' ')
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- Global Numbers
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
