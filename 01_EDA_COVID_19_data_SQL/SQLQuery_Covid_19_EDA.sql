/*
Covid-19 data exploration

Will be exploring Covid-19 data, looking at infection, deaths and vacinations across the world

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


-- Select Data for this analysis

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2



-- COUNTRY BREAKDOWN

-- Looking at Total Cases vs Total Deaths
-- Likelyhood of death if you contract covid during a certain date in a certain country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Canada'
WHERE continent is not null 
ORDER BY 1,2



-- Looking at Total Cases vs Population 
-- Shows what perecentage of the population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location ='Canada' AND  continent is not null 
WHERE continent is not null 
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- Looking at countries whith highest death count per population 

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount

FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC


-- CONTINENT BREAKDOWN


--Looking at continents with highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, population
FROM PortfolioProject..CovidDeaths
WHERE continent is  null AND location not in ('World','International','European Union')
GROUP BY location, population
ORDER BY TotalDeathCount DESC


-- Likelyhood of death if you contract covid during a certain date in a certain continent

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is  null AND location not in ('World','International','European Union')
ORDER BY 1,2


-- Looking at percentage population that contracted covid during a certain date in a certain continent

SELECT location, date, population, (total_cases/population)*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is  null AND location not in ('World','International','European Union')
Order By 1,2


-- Looking at continent with highest infection rate compared to the population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is  null AND location not in ('World','International','European Union')
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC



--GLOBAL NUMBERS


SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null






--VACCINE DATA ANALYSIS 
-- COUNTRY BREAKDOWN

SELECT dea.continent, dea.location, dea.population, MAX(CAST(vac.total_vaccinations AS int)) AS total_vaccianted, dea.population, 
ROUND(MAX(CAST(vac.total_vaccinations AS int))/dea.population*100,2) AS PercentageVac, MAX(CAST(vac.people_fully_vaccinated AS int)) AS fully_vaccianted,
ROUND(MAX(CAST(vac.people_fully_vaccinated AS int))/dea.population*100,2)AS PercentageFullyVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null --and dea.location ='Canada'
GROUP BY dea.continent, dea.location, dea.population
ORDER BY 3 DESC


-- Total population vs vaccinations
-- Shows percentage of population that has recieved at least one Covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


--looking at total population vs vaccinations 
-- Using CTE to find the rolling total of vaccines recieved 
with PopVac as (
	SELECT dea.continent, dea.location, vac.date,vac.population, new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths AS dea
		JOIN PortfolioProject..CovidVaccinations AS vac
		ON dea.location=vac.location 
		AND dea.date = vac.date
	WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentageVaccinated
FROM PopVac


-- Using Temp Table to perform calculation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


SELECT *, (RollingPeopleVaccinated/Population)*100 RollingPercentageVaccinated
FROM #PercentPopulationVaccinated


--CONTINENT BREAKDOWN


SELECT dea.location, dea.population, MAX(CAST(vac.total_vaccinations AS int)) AS total_vaccianted, 
ROUND(MAX(CAST(vac.total_vaccinations AS int))/dea.population*100,2) AS PercentageVac, MAX(CAST(vac.people_fully_vaccinated AS int)) AS fully_vaccianted,
ROUND(MAX(CAST(vac.people_fully_vaccinated AS int))/dea.population*100,2)AS PercentageFullyVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is  null AND dea.location not in ('World','International','European Union')
GROUP BY dea.location, dea.population
ORDER BY 3 DESC


--GLOBAL BREAKDOWN

SELECT dea.location, dea.population, MAX(CAST(vac.total_vaccinations AS int)) AS total_vaccianted, 
ROUND(MAX(CAST(vac.total_vaccinations AS int))/dea.population*100,2) AS PercentageVac, MAX(CAST(vac.people_fully_vaccinated AS int)) AS fully_vaccianted,
ROUND(MAX(CAST(vac.people_fully_vaccinated AS int))/dea.population*100,2)AS PercentageFullyVac
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is  null AND dea.location ='World'
GROUP BY dea.location, dea.population
ORDER BY 3 DESC


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 


