-- Creating  a table to Look at the likelihood of dying in COVID-infected people by date and country
select location, date, total_cases, total_deaths, (convert(float,total_deaths)/nullif (convert(float, total_cases),0))*100 as DeathsPercentage
from COVID_DATA..CovidDeaths
order by 1,2

-- Creating  a table to determine the percentage of the population that got infected by date and country
select location, date,population, convert(float,total_cases), (convert(float,total_cases)/population)*100 as PercentPopulationInfected
from COVID_DATA..CovidDeaths
order by 1,2


-- Creating a table to look at the countries with the highest infection rate compared to the population
select location, population, MAX(convert(float,total_cases)) as HighestInfectionCount, MAX(convert(float,total_cases)/population)*100 as HighestPercentPopulationInfected
from COVID_DATA..CovidDeaths
group by location, population
order by HighestPercentPopulationInfected desc

-- Creating a table to look at the countries with the highest death count and percentage per population
select location, max(cast(total_deaths as int)) as highestDeathsCount, max(total_deaths/population)*100 as HighestPercentPopulationDied
from COVID_DATA..CovidDeaths
group by location
order by HighestPercentPopulationDied desc

-- Creating a table to look at the continents with the highest death count/percentage per population:
select continent, max(cast(total_deaths as int)) as highestDeathsCount, max(total_deaths/population)*100 as HighestPercentPopulationDied
from COVID_DATA..CovidDeaths
where continent is not null
group by continent
order by HighestPercentPopulationDied desc

--Creating a table to look at the total COVID infected cases/deaths in the world by date
select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(nullif (convert(float,new_cases),0))*100 as DeathPercentage
from COVID_DATA..CovidDeaths
where continent is not null
group by date
order by 1,2

--	Creating a table to look at the COVID death percentage in the world
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(nullif (convert(float,new_cases),0))*100 as DeathPercentage
from COVID_DATA..CovidDeaths
where continent is not null

-- Creating a table to look at the total population versus vaccinated population in each country over the dates
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from COVID_DATA..CovidDeaths as dea
join COVID_DATA..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Creating a table to look at the total population versus vaccinated population (rolling people vaccinated) in each country over the dates
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from COVID_DATA..CovidDeaths as dea
join COVID_DATA..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Creating a table to look at the percentage of rolling people vaccinated per population over the dates in each country
-- Using common table expression (CTE)
with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated

from COVID_DATA..CovidDeaths as dea
join COVID_DATA..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from PopvsVac
order by 1,2,3

-- Using Temporary Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population float,
new_vaccinations nvarchar(225),
RollingPeopleVaccinated float
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from COVID_DATA..CovidDeaths as dea
join COVID_DATA..CovidVaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated

