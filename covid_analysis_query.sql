SELECT *
FROM PortfolioProject..CovidDeaths;

--SELECT *
--FROM CovidVaccinations;

--Select data for use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Total cases vs total deaths
--Shows likelihood of dying if you get covid in Mexico
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Mexico'
ORDER BY 1,2;

--Total cases  vs population
--Shos percentage of population that got covid
SELECT location, date, population, total_cases, population, (total_cases / population)*100 AS infected_percentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'Mexico'
ORDER BY 1,2;

--Countries with highest infection rate compared to populations
SELECT location, population, MAX(total_cases) as highest_infection_count, population, MAX((total_cases / population)*100) AS infected_percentage
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Mexico'
GROUP BY population, location
ORDER BY infected_percentage DESC;

--Countries with highest percentage of deaths
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Mexico'
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY total_death_count DESC;

--sorted by continent
--continents with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Mexico'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;


--Global numbers
SELECT SUM(new_cases) AS total_cases,SUM(CAST (new_deaths AS INT)) AS total_deaths, SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage --total_deaths, (total_deaths / total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

--Total population vs vaccinations
--CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (total_vaccinations/population) * 100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
total_vaccinations NUMERIC
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (total_vaccinations/population) * 100
FROM #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VIZ
USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinatedd AS
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinatedd