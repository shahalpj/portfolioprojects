SELECT *
FROM portfolioproject..[covid deaths]
where continent is not null
order by 3,4

--SELECT *
--FROM portfolioproject..[covid vaccinations]
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..[covid deaths]
order by 1,2

-- looking at total cases vs total deaths
-- show likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..[covid deaths]
where location like '%states%'
order by 1,2

-- looking at the total case vs populations
-- show what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as deathpercentage
from portfolioproject..[covid deaths]
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compare to population

select location, population, MAX(total_cases) as highestinfectioncountry, MAX((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..[covid deaths]
--where location like '%states%'
group by location, population
order by percentpopulationinfected desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as INT)) as totaldeathcount
from portfolioproject..[covid deaths]
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

--showing the continents with highest death count per population

select continent, MAX(cast(total_deaths as INT)) as totaldeathcount
from portfolioproject..[covid deaths]
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as deathpercentage
from portfolioproject..[covid deaths]
--where location like '%states%'
where continent is not null
group by date
order by 1,2

-- looking at total population vs total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..[covid deaths] dea
join portfolioproject..[covid vaccinations] vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3



--USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..[covid deaths] dea
join portfolioproject..[covid vaccinations] vac
    on dea.location = vac.location
	and dea.date = vac.date
   where dea.continent is not null
--order by 2,3
	)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- TEMP TABLE

DROP  table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..[covid deaths] dea
join portfolioproject..[covid vaccinations] vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated



--creating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..[covid deaths] dea
join portfolioproject..[covid vaccinations] vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated
