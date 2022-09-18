select * from coviddeaths 
order by 3,4;

--select * from covidvaccinations c  
--order by 3,4

--Select data that we are going to be using
select "location" , "date" , total_cases,new_cases, total_deaths, population  
from coviddeaths 
order by 1,2

--Search for total cases vs total deaths / deatrate
select "location" , "date" , total_cases, total_deaths, (total_deaths/total_cases)*100 as deathrate
from coviddeaths 
where "location" like '%Indonesia%'
order by 2 desc

-- Looking at total cases vs population
select "location" , "date" , total_cases, population , (total_cases/population)*100 as PercentPopulationInfected
from coviddeaths 
--where "location" like '%Indonesia%'
order by 1,2 desc

--find highest infection rate
select "location" ,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from coviddeaths 
group by "location" ,population 
order by PercentPopulationInfected desc

--Find country with highest death count per population
select "location" , max(total_deaths) as TotalDeath  
from coviddeaths 
where total_deaths IS NOT null and continent <> ''
group by "location" 
order by TotalDeath desc 

--Breakdown by continent 
select "location" , max(total_deaths) as TotalDeath  
from coviddeaths 
where total_deaths IS NOT null and continent = '' and location not like '%income%'
group by "location"
order by TotalDeath desc 


--GLOBAL NUMBRS
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_death, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage 
from coviddeaths 
where continent <> ''
--group by "date" 
order by 1,2 

--Vaccination
select * 
from coviddeaths cd
join covidvaccinations cv 
	on cd."location" = cv."location" 
	and cd."date" = cv."date" ;

--USE CTE
--Find Total Population vs Vaccination
With PopvsVac (Continent, "location", "Date", Population, New_Vaccinataions, RollingPeopleVaccinated)
as 
(
select cd.continent ,cd."location", cd."date" , cd.population, cv.new_vaccinations 
, SUM(cv.new_vaccinations) over (partition by cd."location" order by cd.location, cd.date) as RollingPeopleVaccinated 
from coviddeaths cd
join covidvaccinations cv 
	on cd."location" = cv."location" 
	and cd."date" = cv."date" 
where cd.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccineRate
From PopvsVac







