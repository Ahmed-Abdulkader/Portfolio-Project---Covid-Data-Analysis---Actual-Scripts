SELECT *
	FROM	PortfolioProject1..CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 3, 4

--SELECT *
--	FROM	PortfolioProject1..CovidVaccinations
--	ORDER BY 3, 4

-- Selecting all releavnt data 
SELECT  [location] , [date], total_cases, new_cases, total_deaths, [population]
		FROM PortfolioProject1..CovidDeaths
		ORDER BY 1,2 

-- Looking at Total Cases Vs Total Deaths --
-- Showing the likliehood of dying if contracting covid in X country

SELECT  [location], [date], total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 AS DeathPercentage
		FROM PortfolioProject1..CovidDeaths
		--WHERE [location] like '%Kingdom%'
		ORDER BY 1,2

-- Looking at Total_cases vs Population --
-- Shows what percentage of population contracted covid

SELECT  [location], [date], [population], total_cases, (total_cases/population)*100 AS PercentageInfected
		FROM PortfolioProject1..CovidDeaths
		--WHERE [location] like '%cyprus'
		ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT  [location], [population], MAX(total_cases) AS 'Highest Infection Count', (Max((total_cases/population))*100) AS 'Percentage Population Infected'
		FROM PortfolioProject1..CovidDeaths
		--WHERE [location] like '%states%'
		GROUP BY [location], [population]
		ORDER BY 'Percentage Population Infected' DESC

-- Showing countries with Highest death count per population

SELECT  [location], MAX(total_deaths) AS TotalDeathCount
		FROM PortfolioProject1..CovidDeaths
		--WHERE [location] like '%states%'
		WHERE continent IS NOT NULL
		GROUP BY [location], [population]
		ORDER BY TotalDeathCount DESC


-- Showing continents with Highest death count per continent

SELECT  [location], MAX(total_deaths) AS TotalDeathCount
		FROM PortfolioProject1..CovidDeaths
		WHERE [location] NOT IN ('Lower middle income', 'Low income', 'High income', 'Upper middle income')
		AND continent IS NULL 
		GROUP BY [location] 
		ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

-- Showing daily fatality rate vs new cases

SELECT  [date], SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
		FROM PortfolioProject1..CovidDeaths
		WHERE continent IS NOT NULL AND new_cases IS NOT NULL AND new_deaths IS NOT NULL AND new_cases > 0
		GROUP BY date
		ORDER BY date


		SELECT  [date], SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
		FROM PortfolioProject1..CovidDeaths
		WHERE continent IS NOT NULL
		GROUP BY date
		ORDER BY date

 -- Showing Total fatality rate vs new cases

 SELECT  SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
		FROM PortfolioProject1..CovidDeaths
		WHERE continent IS NOT NULL --AND new_cases IS NOT NULL AND new_deaths IS NOT NULL AND new_cases > 0
		ORDER BY 1,2

-- Exploring Vaccination data

SELECT *
		FROM PortfolioProject1..CovidDeaths dea
		JOIN PortfolioProject1..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date

-- Looking at total Population vs Vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
		FROM PortfolioProject1..CovidDeaths dea
		JOIN PortfolioProject1..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		ORDER BY 2, 3
		

---------------USE CTE

WITH PopvsVac (continent, location, date, population, RollingPeopleVaccinated, new_vaccinations) AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
		FROM PortfolioProject1..CovidDeaths dea
		JOIN PortfolioProject1..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS Percentage
		FROM PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
		FROM PortfolioProject1..CovidDeaths dea
		JOIN PortfolioProject1..CovidVaccinations vac
		ON dea.location = vac.location AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100 AS Percentage
		FROM #PercentPopulationVaccinated
		ORDER BY Location



-- Creating View to store data for later visualisation 

	CREATE VIEW PercentPopulationVaccinated AS 
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		FROM PortfolioProject1..CovidDeaths dea
		JOIN PortfolioProject1..CovidVaccinations vac
			ON dea.location = vac.location AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		--ORDER BY 2, 3

	CREATE VIEW TotalCasesVsTotalDeaths AS
	SELECT  [location], [date], total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 AS DeathPercentage
		FROM PortfolioProject1..CovidDeaths
		--WHERE [location] like '%Kingdom%'
		--ORDER BY 1,2

	CREATE VIEW PercentageOfPopulationInfected AS
		SELECT  [location], [date], [population], total_cases, (total_cases/population)*100 AS PercentageInfected
		FROM PortfolioProject1..CovidDeaths

		
		


