# Covid-Data-Analysis-SQL-Tableau-Power-Bi-

## Project objective:
Creating a Tableau and Power BI dashboard to Analyse COVID cases and deaths in the world using SQL for data cleaning
##Tools:
--	Data Cleaning: SQL Server (Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types)
--	Visualization: Tableau & Power Bi
### 1	Questions to answer/KPIs
      1.1	What is the total number of COVID cases and deaths in the world?
      1.2	What is the deaths percentage of COVID cases in the world?
      1.3	What is the total number of COVID cases and deaths by continent?
      1.4	What is the trend of COVID cases and deaths over time?
      1.5	What is the percentage of the population infected in each country?

### 2	Data Importing
      2.1	Downloading COVID data from https://ourworldindata.org/covid-deaths in CSV format
      2.2	Cutting the data into two separate Excel files named “CovidDeaths .xlsx” and “CovidVaccinations .xlsx”.
      2.3	Making a new Database in SQL server, naming it “COVID_DATA”
      2.4	Importing the Excel files into the database created
      
### 3	Data Exploration
      3.1	Creating a table to Determine the likelihood of dying in COVID-infected people by date and country.
          •	SQL Query used:
              select location, date, total_cases, total_deaths, (convert(float,total_deaths)/nullif (convert(float, total_cases),0))*100 as DeathsPercentage
              from COVID_DATA..CovidDeaths
              order by 1,2
              
      3.2	Creating a table to determine the percentage of the population that got infected by date and country
          •	SQL Query used:
              select location, date,population, convert(float,total_cases), (convert(float,total_cases)/population)*100 as PercentPopulationInfected
              from COVID_DATA..CovidDeaths
              order by 1,2
              
      3.3	Creating a table to look at the countries with the highest infection rate compared to the population
          •	SQL Query used:
              select location, population, MAX(convert(float,total_cases)) as HighestInfectionCount, MAX(convert(float,total_cases)/population)*100 as HighestPercentPopulationInfected
              from COVID_DATA..CovidDeaths
              group by location, population
              order by HighestPercentPopulationInfected desc
              
      3.4	Creating a table to look at the countries with the highest death count/percentage per population:
          •	SQL Query used:
              select location, max(cast(total_deaths as int)) as highestDeathsCount, max(total_deaths/population)*100 as HighestPercentPopulationDied
              from COVID_DATA..CovidDeaths
              group by location
              order by HighestPercentPopulationDied desc
              
      3.5	Creating a table to look at the continents with the highest death count/percentage per population:
          •	SQL Query used:
              select continent, max(cast(total_deaths as int)) as highestDeathsCount, max(total_deaths/population)*100 as HighestPercentPopulationDied
              from COVID_DATA..CovidDeaths
              where continent is not null
              group by continent
              order by HighestPercentPopulationDied desc
              
      3.6	Creating a table to look at the total COVID-infected cases/deaths in the world by date 
          •	SQL Query used:
              select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(nullif (convert(float,new_cases),0))*100 as DeathPercentage
              from COVID_DATA..CovidDeaths
              where continent is not null
              group by date
              order by 1,2
              
      3.7	Creating a table to look at the COVID death percentage in the world
          •	SQL Query used:
              select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(nullif (convert(float,new_cases),0))*100 as DeathPercentage
              from COVID_DATA..CovidDeaths
              where continent is not null
              
      3.8	Creating a table to look at the total population versus the newly vaccinated population in each country over the dates
          •	SQL Query used:
              select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
              from COVID_DATA..CovidDeaths as dea
              join COVID_DATA..CovidVaccination as vac
              on dea.location = vac.location
              and dea.date = vac.date
              where dea.continent is not null
              order by 1,2,3
      
      3.9	Creating a table to look at the total population versus vaccinated population (rolling people vaccinated) in each country over the dates
          •	SQL Query used:   
              select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
              sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
              from COVID_DATA..CovidDeaths as dea
              join COVID_DATA..CovidVaccination as vac
              on dea.location = vac.location
              and dea.date = vac.date
              where dea.continent is not null
              order by 1,2,3
      
      3.10	Creating a table to look at the percentage of rolling people vaccinated per population over the dates in each country
          •	SQL Query used (with CTE):
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
      
          •	SQL Query used (with Temporary Table):
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
              
### 4	Exporting tables for visualisation in Tableau & Power BI by creating view tables
      4.1	World Total cases & deaths
          •	SQL Query used:
              Create view World_Cases_n_Deaths_In_Total as
              select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths , sum(new_deaths)/sum(new_cases)*100 as World_Death_Percentage
              from COVID_DATA..CovidDeaths
              where continent is not null
      
      4.2	World total deaths by continent
          •	SQL Query used:
              Create view World_Cases_n_Deaths_By_Continents as
              select location, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths
              from COVID_DATA..CovidDeaths
              where continent is null
              and	location not in ('Lower middle income','World','Low income', 'European Union', 'Upper middle income','High income')
              group by location
              
      4.3	Percentage of population infected by country
          •	SQL Query used:
              create view World_InfectedCases_n_PercentPopulationInfected_By_Country as
              select location, population, ISNULL(max(convert(int,total_cases)),0) as Highest_Infected_Cases, isnull(max(convert(int,total_cases)),0)/population*100 as Percentage_Population_Infected
              from COVID_DATA..CovidDeaths
              where continent is not null
              group by location, population
              
      4.4	Percentage of population infected by country and date
          • SQL Query used:
             create view World_InfectedCases_n_PercentPopulationInfected_By_Country_n_Date as
             select location, population, date, ISNULL(max(convert(int,total_cases)),0) as Highest_Infected_Cases, isnull(max(convert(int,total_cases)),0)/population*100 as Percentage_Population_Infected
             from COVID_DATA..CovidDeaths
             where continent is not null
             group by location, population, date
             create view World_InfectedCases_n_PercentPopulationInfected_By_Country_n_Date as
             select location, population, date, ISNULL(max(convert(int,total_cases)),0) as Highest_Infected_Cases, isnull(max(convert(int,total_cases)),0)/population*100 as Percentage_Population_Infected
             from COVID_DATA..CovidDeaths
             where continent is not null
             group by location, population, date
