SELECT *
FROM PortfolioProject..['Covid deaths$']
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..['Covid Vaccination$']
--WHERE continent IS NOT NULL
--ORDER BY 3,4

SELECT Location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProject..['Covid deaths$']
ORDER BY 1,2

--Looking at total cases vs total deaths

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percent
FROM PortfolioProject..['Covid deaths$']
WHERE location = 'India'
ORDER BY 1,2


--Looking at total cases vs population

SELECT Location, date, total_cases,population , (total_cases/population)*100 AS cases_percent
FROM PortfolioProject..['Covid deaths$']
WHERE location = 'India'
ORDER BY 1,2

--Looking for the highest number of infection across the globe

SELECT Location,population, MAX(total_cases) AS highest_number_cases, MAX(total_cases/population)*100 AS highest_percent
FROM PortfolioProject..['Covid deaths$']
--WHERE location = 'India'
GROUP BY location, population
ORDER BY highest_percent DESC


--Showing the country with highest number of deaths per population

SELECT Location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..['Covid deaths$']
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing the highest number of deaths in continents

SELECT continent, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..['Covid deaths$']
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths , SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percent
FROM PortfolioProject..['Covid deaths$']
--WHERE location = 'India'
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking for the total population vs vaccination



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid deaths$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3 

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid deaths$'] dea
Join PortfolioProject..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percent_people_vaccinated
From PopvsVac