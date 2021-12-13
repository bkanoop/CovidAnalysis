use PortfolioProject

--select *
--from sys.tables

select *
from CovidDeaths
where continent is not null
order by 3,4


--select *
--from CovidVaccinations 
--order by 3,4


--Select date that we are going to be using
select  location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


--Looking at total cases vs total deaths
--Shows the likelihood of dying by Covid in Nepal
select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'nepal'
order by 1,2


--Looking at total cases vs population
--shows what percentage of population got Covid
select  location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like 'nepal'
order by 1,2


--Looking at countries with highest infection rate compared to population
select  location,population,max(total_cases) as HghestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like 'nepal'
group by location, population
order by 4 desc;


--Showing countries with highest death count per population
select  location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like 'nepal'
where continent is not null
group by location
order by 2 desc;


--Showing Continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like 'nepal'
where continent is not null
group by continent
order by 2 desc;



--GLOBAL NUMBERS


--Death percentage grouped by date
select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'nepal'
where continent is not null
group by date
order by 1,2 desc


--total death percentage
select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'nepal'
where continent is not null
--group by date
order by 1,2 desc



--Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations  
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Looking at total population vs vaccinations


--with window function
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--use CTE
with PopvsVac as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)        "we cant use newly created column name. So, use either CTE or TEMP table"
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
) 
select *,(RollingPeopleVaccinated/population)*100 as VacPercent from PopvsVac 



--use TEMP TABLE

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
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100 as VacPercent from #PercentPopulationVaccinated 



--creating VIEW to store data for later visualizations


create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100 as VacPercent from PercentPopulationVaccinated