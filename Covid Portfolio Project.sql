select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

-- select *
-- from PortfolioProject..CovidVaccinations
-- order by 3,4 

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

-- total cases vs total deaths
select Location, date, total_cases, total_deaths, (cast (total_deaths as float)/cast (total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'united states'
order by 1, 2

-- total cases vs population
select Location, date, total_cases, Population, (cast (total_cases as float)/cast (population as float))*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeaths
where location like 'united states'
order by 1, 2

-- highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, (max(cast (total_cases as float))/cast (population as float))*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeaths
--where location like 'united states'
group by location, population
order by PopulationPercentageInfected desc;

-- countries with highest death count per population
select Location, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'united states'
where continent is not null
group by location
order by TotalDeathCount desc;

-- by continent
select location, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'united states'
where continent is not null and location not like '%income%'
group by location
order by TotalDeathCount desc; 

-- showing contintent with highest death count
select continent, max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'united states'
where continent is not null and location not like '%income%'
group by continent
order by TotalDeathCount desc; 

-- global numbers
select date, 
		sum(new_cases) as NewCases, 
		sum(cast(new_deaths as int)) as TotalDeaths,
		sum(cast (new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and location not like '%income%' and new_cases != 0
group by date
order by 1,2

-- total population vs vaccinations

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVacinated)
as
(
select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = dea.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVacinated/population)*100
from popvsvac

-- temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = dea.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- create view to store data for later viz

Create View PercentPopulationVaccinated as
select dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = dea.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated