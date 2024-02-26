select *
from PortfolioProject..CovidDeaths$
order by 3,4

--select *
--from PortfolioProject..CovidVaccination$
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in ypur country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at total cases vs. population
--shows hwat percentage of population got Covid
select location, date, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
order by 1,2

--Looking at Countires with highest infection Rate

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Population

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by Location, Population
order by TotalDeathCount desc


-- lets break things down by content, change location into continent

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--showing the continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--global numbers

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc


newwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww


--global numbers, cannot group by date

select date, sum(new_cases), sum(cast(new_deaths as int))--total_cases, total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

--global death numbers, cannot group by date

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage--total_cases, total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in ypur country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

select *
from PortfolioProject..CovidVaccination$ vac
join PortfolioProject..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date

--looking at total Population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidVaccination$ vac
join PortfolioProject..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--looking at total Population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--cannot execute because the RollingPeopleVaccinated is not yet created
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location

--CTE must have the same number of columns with and select
With PopsvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac



--temp table


drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated

--creating view to store data for later Visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date

select *
from PercentPopulationVaccinated