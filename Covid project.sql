select * from CovidDeaths
where continent is not null
order by 3,4

Select * from CovidVaccinations
order by 3,4

--select data that we are going use
select location, date, total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--looking at total cases v/s total deaths
--shows likelihood of dying if you contact covid in your country
select location, date, total_cases,total_deaths,population,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths
where location like 'India'
order by 1,2

--looking at total cases vs the population
--shows what % of population got covid
select location, date,population, total_cases,(total_cases/population)*100 as percentageofpopinfected
from CovidDeaths
where location like 'India'
order by 2,4



--country with highest infection rate compared to population
select location,population, max(total_cases) as highestinfectioncount,max(total_cases/population)*100 as percentageofpopinfected
from CovidDeaths
--where location like 'India'
group by location,population
order by 4 desc

--showing countries with highest deathcount per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like 'India'
where continent is not null
group by location
order by totaldeathcount desc

--Break things by Continent

--
select continent, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like 'India'
where continent is not null
group by continent
order by totaldeathcount desc

--global Numbers
select date, sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths
--where location like 'India'
where continent is not null
group by date
order by 1,2


--looking at total popluation vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevac
--(rollingpeoplevac/dea.population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE beacuse we canot use rollingpoeplevac as column to calculate other things
--note: no of columns in cte should b equal to no. of colmun in subquery
with PopvsVac (continent, location, date, population,new_vaccinations,rollingpeoplevac)
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingcountpeoplevac
--, (rollingcountpeoplevac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevac/population)*100
from PopvsVac

--temp table
Drop table if exists  #percntpopulationvaccinated
Create Table #percntpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert Into #percntpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingcountpeoplevac
--, (rollingcountpeoplevac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percntpopulationvaccinated

--creating view to store data fir later vizulaisation

create view percntpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingcountpeoplevac
--, (rollingcountpeoplevac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
