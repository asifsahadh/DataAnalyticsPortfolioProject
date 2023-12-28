--Viewing Covid Deaths Table
SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

--Viewing Covid Vaccinations Table
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4

--Selecting Wanted Columns
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

--Percentage of Total Cases vs Total Deaths 
SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS deaths_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Arabia'
ORDER BY 1, 2

--Percentage of Population that got Infected in each Country
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Percentage of Population that got Infected in each Country per day
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, date, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY location

--Percentage of Total Cases vs Population (What Percentage of People got Covid)
SELECT location, date, total_cases, population, (total_cases/population)*100 AS population_percentage 
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Arabia'
ORDER BY 1, 2

--Global Death Percentage 
SELECT SUM(new_cases) AS total_Cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Countries with Highest Infection Rate
SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS infection_rate 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY infection_rate DESC

--Countries with Highest Death Count
SELECT location, MAX(CONVERT(float, total_deaths)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC

--Continents with Highest Death Count
SELECT continent, MAX(CONVERT(float, total_deaths)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC

--Countries with Highest Death Count in Asia
SELECT location, MAX(CONVERT(float, total_deaths)) AS highest_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent LIKE 'Asia'
GROUP BY location
ORDER BY highest_death_count DESC

--Global Numbers
SELECT date, SUM(new_cases) AS 'total_cases', SUM(new_deaths) AS 'total_deaths', 
	SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100 AS 'death_percentage'
FROM PortfolioProject..CovidDeaths
GROUP BY date
ORDER BY 1, 2

--Total Death Count in each Continent
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location

--Total Population vs Vaccination
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS 'rolling_vaccinations'
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2

--Using CTE to View Population vs Vaccination Percentage
WITH PopvsVac
AS
(
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS 'rolling_vaccinations'
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, rolling_vaccinations / population * 100 AS population_vs_vaccination_percentage
FROM PopvsVac

--Using Temp Table to View Population vs Vaccination Percentage
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Location nvarchar(255),
Continent nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinations numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS 'rolling_vaccinations'
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, rolling_vaccinations / population * 100 AS population_vs_vaccination_percentage
FROM #PercentagePopulationVaccinated

--Creating View for Later
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS 'rolling_vaccinations'
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
