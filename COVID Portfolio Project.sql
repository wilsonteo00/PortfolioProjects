SELECT *
FROM dbo.CovidDeaths
ORDER BY 3,4

SELECT Location, CONVERT(DATETIME,date,103), total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2 

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in Singapore

SELECT Location, CONVERT(DATETIME,date,103), total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%singapore%'
ORDER BY 1,2 


-- Looking at Total Cases vs Population
-- Shows what percentage of population contract COVID in Singapore

SELECT Location, CONVERT(DATETIME,date,103), population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location like '%singapore%'
ORDER BY 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location like '%singapore%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 


-- Showing Countries with Highest Death Count per Population
-- Total Deaths return as non-integer which is not useful for doing Max function

SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE (continent is not null AND continent != ' ')
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- Analysing based on continent instead

SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE (continent is null OR continent = ' ')
GROUP BY location
ORDER BY TotalDeathCount DESC 

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
--HAVING SUM(cast(new_cases as int)) != 0
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
-- CTE to do additional division
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
--ORDER BY 2,3
)
SELECT *, CASE WHEN population = 0 THEN 0 ELSE (cast(RollingPeopleVaccinated as float)/population*100) END as VaccinatedPercent
FROM PopvsVac

-- Looking at Total Population vs Vaccinations
-- Temp Table

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
--ORDER BY 2,3

SELECT *, CASE WHEN population = 0 THEN 0 ELSE (cast(RollingPeopleVaccinated as float)/population*100) END as VaccinatedPercent
FROM #PercentPopulationVaccinated

-- Creating View to store data for visualisation

Create View PercentPopulationVaccinate as
SELECT dea.continent, dea.location, CONVERT(DATETIME,dea.date,103) as date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, 
CONVERT(DATETIME,dea.date,103)) as RollingPeopleVaccinated 
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE (dea.continent is not null AND dea.continent != ' ')
--ORDER BY 2,3

-- View

SELECT *
FROM PercentPopulationVaccinate