select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- looking at total cases vs total deaths of United States
-- shows likelihood of dying if you contract COVID in United States
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- looking at total cases vs population of United States
-- shows percentage of population got COVID
select location, date, total_cases, population, (total_cases/population)*100 as ConfirmedCases_Percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- looking at countries with highest infection rate compared to population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as ConfirmedCases_Percentage
from PortfolioProject..CovidDeaths
group by location, population
order by 4 desc


-- showing countries with highest death count per population
select location, population, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 as TotalDeath_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- showing continent with highest death count
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by 2 desc


-- showing continent with highest death count
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1


-- Joining 2 tables

Select * 
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date


-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Find out daily cumulative vaccination per country

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccination
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Find out cumulative vaccination per population using CTE or temp table
-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, CumulativeVaccination)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccination 
-- (CumulativeVaccination/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (CumulativeVaccination/population)*100
from PopvsVac


-- Use Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
CumulativeVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccination 
-- (CumulativeVaccination/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (CumulativeVaccination/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccination 
-- (CumulativeVaccination/population)*100
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated