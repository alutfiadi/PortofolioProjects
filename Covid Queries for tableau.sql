--Queries For TABLEAU
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage 
from coviddeaths 
where continent <> ''
--group by "date" 
order by 1,2 

--Breakdown by continent 
select "location" , max(total_deaths) as TotalDeath  
from coviddeaths 
where continent is NULL and "location"  not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income') 
group by "location"
order by TotalDeath desc 

--find highest infection rate
select "location" ,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths 
group by "location" ,population 
order by PercentPopulationInfected desc

--in EXCEL CHANGE NULL with 0

--find highest infection rate with date
select "location" ,population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths 
group by "location" ,population, date 
order by PercentPopulationInfected desc