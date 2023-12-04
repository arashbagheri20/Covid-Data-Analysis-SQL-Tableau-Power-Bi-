-- Calculating World Total cases and Total deaths

Create view World_Cases_n_Deaths_In_Total as
select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths , sum(new_deaths)/sum(new_cases)*100 as World_Death_Percentage
from COVID_DATA..CovidDeaths
where continent is not null


-- Calculating World Total Deaths by Continent
Create view World_Cases_n_Deaths_By_Continents as
select location, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths
from COVID_DATA..CovidDeaths
where continent is null
	and
	location not in ('Lower middle income','World','Low income', 'European Union', 'Upper middle income','High income')
group by location


-- Calculating Percentage of population infected by country

create view World_InfectedCases_n_PercentPopulationInfected_By_Country as
select location, population, ISNULL(max(convert(int,total_cases)),0) as Highest_Infected_Cases, isnull(max(convert(int,total_cases)),0)/population*100 as Percentage_Population_Infected
from COVID_DATA..CovidDeaths
where continent is not null
group by location, population


-- Calculating Percentage of population infected by country & date
create view World_InfectedCases_n_PercentPopulationInfected_By_Country_n_Date as
select location, population, date, ISNULL(max(convert(int,total_cases)),0) as Highest_Infected_Cases, isnull(max(convert(int,total_cases)),0)/population*100 as Percentage_Population_Infected
from COVID_DATA..CovidDeaths
where continent is not null
group by location, population, date
