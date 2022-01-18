select location, date, total_cases, total_deaths, population
from Mydatabase..CovidDeath$
where continent is not null
order by 1, 2


--- total cases vs total deaths
--- Shows the likelihood of dying if infected in Nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Mydatabase..CovidDeath$
where location = 'Nigeria'
order by 1, 2

--- total cases vs population
--- shows the poplation of infected individual
select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
from Mydatabase..CovidDeath$
where location = 'Nigeria'
order by 1, 2

--- Countries with highest infection rate to population
select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PopulationPercentageInfected
from Mydatabase..CovidDeath$
--where location = 'Nigeria'
group by location,population
order by PopulationPercentageInfected desc

-- Countries with highest death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Mydatabase..CovidDeath$
--where location = 'Nigeria'
where location is not null
group by location
order by TotalDeathCount desc


-- By Continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Mydatabase..CovidDeath$
--where location = 'Nigeria'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers

--Select date, SUM(new_cases) as total_cases, -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100
--as DeathPercentage
--From Mydatabase..CovidDeath$
--Where continent is not null
--Group by date
--Order by 1, 2

Select SUM(new_cases) as total_cases, -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
SUM(convert(int, new_deaths)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100
as DeathPercentage
From Mydatabase..CovidDeath$
Where continent is not null
--Group by date
Order by 1, 2

------------------------------------
select top(10) *
from Mydatabase..CovidVaccinations$
-------------------------------------

select top(10) *
from Mydatabase..CovidDeath$ dea
Join Mydatabase..CovidVaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date

-- Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) Over (partition by dea.location)-- order by dea.location, dea.date) 
as RollingPeopleVaccinated
from Mydatabase..CovidDeath$ dea
Join Mydatabase..CovidVaccinations$ vac 
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3


With CTE_PopVsVac (continent, location, date, population, new_vaccinations,
RollingPeopleVaccinated)
As
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) Over (partition by dea.location)-- order by dea.location, dea.date)
as RollingPeopleVaccinated
from Mydatabase..CovidDeath$ dea
Join Mydatabase..CovidVaccinations$ vac 
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *
From CTE_PopVsVac


-- Temp Table

Drop Table if exists #PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from Mydatabase..CovidDeath$ dea
Join Mydatabase..CovidVaccinations$ vac 
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated

-- Creation View to stored data for visualizations

Create View PercentagePopulationVaccinated as
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Mydatabase..CovidDeath$
--where location = 'Nigeria'
where continent is not null
group by continent
--order by TotalDeathCount desc

Select *
From PercentagePopulationVaccinated