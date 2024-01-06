
select* from CapstoneProject..CovidDeaths$
where continent is not null
order by 3,4

--select * from CapstoneProject..CovidVaccinations$
--order by 3,4

--Data Being Viewed

select location, date, total_cases, new_cases, total_deaths, population
from CapstoneProject..CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, population) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from CapstoneProject..CovidDeaths$
order by 1,2

--Countries with highest infection rate vs population

SELECT location, population,
    MAX(total_cases) AS HighestInfectionCount,
    (CONVERT(float, population) / NULLIF(CONVERT(float, MAX(total_cases)), 0)) * 100 AS PopulationInfected
FROM CapstoneProject..CovidDeaths$
GROUP BY location, population
ORDER BY PopulationInfected desc

-- Countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CapstoneProject..CovidDeaths$
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CapstoneProject..CovidDeaths$
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from CapstoneProject..CovidDeaths$
where continent is not null
order by 1,2

--join the tables

select *
from CapstoneProject..CovidDeaths$ dea
join CapstoneProject..CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date

-- Total population vs vaccinations

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingNewVaccinations
FROM CapstoneProject..CovidDeaths$ dea
JOIN CapstoneProject..CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- CTE 
with PopvsVac (continent, location, date, population, new_vaccinations, RollingNewVaccinations)
as
(
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingNewVaccinations
FROM CapstoneProject..CovidDeaths$ dea
JOIN CapstoneProject..CovidVaccinations$ vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
select *, (RollingNewVaccinations/Population)*100
from PopvsVac

--Creating View to store for visualizations

create view RollingNewVaccinations as
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(ISNULL(vac.new_vaccinations, 0) AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingNewVaccinations
FROM CapstoneProject..CovidDeaths$ dea
JOIN CapstoneProject..CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--Query from new view
select *
from RollingNewVaccinations