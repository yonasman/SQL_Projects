--1--
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProtfolioProjectOne..CovidDeathsAlex
ORDER BY 1,2

--Percentage of death vs total cases
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 PercentageDeath
FROM ProtfolioProjectOne..CovidDeathsAlex
WHERE location like '%thio%' --by country
ORDER BY 1,2

--percentage of population that got covid
SELECT location, date, total_cases, population, (total_cases /population) * 100 CasePerPopulation
FROM ProtfolioProjectOne..CovidDeathsAlex
WHERE location like '%thio%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX((total_cases /population) * 100) CasePerPopulation
FROM ProtfolioProjectOne..CovidDeathsAlex
GROUP BY location, population
ORDER BY 3 DESC

--showing the highest death count per population
SELECT location, population,COUNT((total_deaths)) DeathCount , MAX((total_deaths /population) * 100) DeathPerPopulation
FROM ProtfolioProjectOne..CovidDeathsAlex
GROUP BY location, population
ORDER BY 4 DESC

SELECT location, MAX(CAST(total_deaths AS int)) MaxDeathCount
FROM ProtfolioProjectOne..CovidDeathsAlex
WHERE continent IS NOT NULL --AND location = 'Canada'
GROUP BY location
ORDER BY 2 DESC

--BREAKING DOWN THINGS WITH CONTINENT
SELECT continent, MAX(CAST(total_deaths AS int)) MaxDeathCount
FROM ProtfolioProjectOne..CovidDeathsAlex
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--GLOBAL NUMS
SELECT date, SUM(new_cases) Total_new_cases, SUM(CAST(new_deaths AS INT)) Total_new_deaths,  (SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100) DeathPercentage
FROM ProtfolioProjectOne..CovidDeathsAlex
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 2 DESC

--Working with both tables

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) RollingVaccinated
FROM ProtfolioProjectOne..CovidDeathsAlex dea
LEFT JOIN ProtfolioProjectOne..CovidVaccinationsAlex vac
ON dea.location = vac.location AND dea.location = vac.location

--Using cte
WITH pv(continent, location, date, population, new_vaccinations, RollingVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) RollingVaccinated
FROM ProtfolioProjectOne..CovidDeathsAlex dea
LEFT JOIN ProtfolioProjectOne..CovidVaccinationsAlex vac
ON dea.location = vac.location AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
)
SELECT * FROM pv

--Creating views
CREATE VIEW TotalPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) RollingVaccinated
FROM ProtfolioProjectOne..CovidDeathsAlex dea
LEFT JOIN ProtfolioProjectOne..CovidVaccinationsAlex vac
ON dea.location = vac.location AND dea.location = vac.location
WHERE dea.continent IS NOT NULL

SELECT * FROM TotalPopVaccinated