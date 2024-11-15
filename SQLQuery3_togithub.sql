select *
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 3,4

select *
from PortfolioProject.dbo.CovidVaccinations$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths$
order by 1, 2

-- Looking at total cases vs total deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where location like '%Hungary%'
order by 1, 2


--looking at the local cases vs the polulation
-- shows what percentage of population got covid and *CasePercentage
-- show what percentage of population died in covid *DeathPercentage
-- shows what percentage of infections ended in death *InfectedDeaths
select location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 as CasePercentage, (total_deaths/population)*100 as DeathPercentage, (total_deaths/total_cases)*100 as InfectedDeaths
from PortfolioProject.dbo.CovidDeaths$
where date = '2021-04-30' and (location like '%Hungary%' or location like '%states%') 
order by 1, 2

-- this is a good subquary but i want to combine with CasePercentage and DeathPercentage too
with assistant as (select (total_deaths/total_cases)*100 as InfectedDeaths
from PortfolioProject.dbo.CovidDeaths$)
select * from assistant
where InfectedDeaths > 4

-- my idea to see the data
select*
from ( 
		select location, date, total_deaths, total_cases, (total_cases/population)*100 as CasePercentage, (total_deaths/population)*100 as DeathPercentage, (total_deaths/total_cases)*100 as InfectedDeaths_percentage
		from PortfolioProject.dbo.CovidDeaths$
		) as subquary
--where InfectedDeaths_percentage between 2 and 3 and date = '2021-04-30'
where date = '2021-04-30'
order by 7 desc


-- Looking at countries with high infectin rate compared to population

select location, population, MAX(total_cases) as HighesInfectionCont, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
--where date = '2021-04-30' and (location like '%Hungary%' or location like '%states%') 
group by location, population
order by PercentPopulationInfected desc

-- Showing contries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Now by continent

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

--showing the continents with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
--where location like '%Hungary%'
where continent is not null -- and date = '2021-04-30'
--group by date 
order by 1, 2  


-- valami tovább

select *
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date



	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- sum(cast(vac.new_vaccinations as int)) = sum(convert(int, vac.new_vaccinations))

--use cte

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--	(RollingPeopleVaccinated/Population)*100
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated_Population
from PopvsVac

--temp table
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
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated_Population
from #PercentPopulationVaccinated




--creating view to store data for visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated