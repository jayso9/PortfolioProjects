
select*
from projectportfolio..CovidDeaths
order by 1,2 

--select*
--from projectportfolio..CovidVaccinations
--order by 3,4
--select data that we are going to be using

Select location,date,total_cases, new_cases, total_deaths, population 
From projectportfolio..CovidDeaths
order by 1,2

--lets look at total death vs total cases
Select location,date,total_cases, total_deaths, (total_deaths/total_cases)* 100 as deathPercentage
From projectportfolio..CovidDeaths
Where location LIKE '%ghana%'
order by 1,2

--Lets look at the total cases vs population

Select location,date,total_cases, total_deaths, population, (total_cases/population)* 100 as totalCasesPercentage
From projectportfolio..CovidDeaths
Where location LIKE '%ghana%'
order by 1,2

--Lets look at countries with the highest infection rate comapered to the population

Select location,MAX(total_cases) AS highestInfection, population, MAX((total_cases/population))* 100 as PercentageByPopulation
From projectportfolio..CovidDeaths
--Where location LIKE '%ghana%'
GROUP BY location, population
order by PercentageByPopulation desc

-- This shows the cocuntrises with the highest deaths

Select location,MAX(cast(total_deaths as int)) AS deathcount
From projectportfolio..CovidDeaths
--Where location LIKE '%ghana%'
Where continent is not null
GROUP BY location
order by deathcount desc

--LET'S GROUP THING BY CONTINENTS


Select continent,MAX(cast(total_deaths as int)) AS deathcount
From projectportfolio..CovidDeaths
--Where location LIKE '%ghana%'
Where continent is not null
GROUP BY continent
order by deathcount desc

----- GLOBAL NUMBERS 
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as deathPercentage
From projectportfolio..CovidDeaths
where continent is not null
--Where location LIKE '%ghana%'
Group by date
order by 1,2



Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from projectportfolio..CovidDeaths dea
join projectportfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by dea.location,dea.date

-- USE CTE

With PopvsVac (continent,location,date,population,new_vaccinations,rollingPeopleVaccinated) as

(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from projectportfolio..CovidDeaths dea
join projectportfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
select *, (rollingPeopleVaccinated/Population)* 100
from PopvsVac


--TEMP TABLE

Create table #PopulationByPercentage
(continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into  #PopulationByPercentage
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from projectportfolio..CovidDeaths dea
join projectportfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

select *, (rollingPeopleVaccinated/Population)* 100
from #PopulationByPercentage

--Creating View to store later for data visualization

USE projectportfolio
GO
Create view  percentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from projectportfolio..CovidDeaths dea
join projectportfolio..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

