---Select data that will be used
select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2

--Totak Cases vs Total Deaths in a Country
--Chances of death if you test positive for Covid-19
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
As DeathPercentage
From CovidDeaths
Where location like '%states%'
Order By 1,2



--Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100
As NoOfPeopleWithCovid
From CovidDeaths
Where location like 'S%africa'
Order By 1,2



--Highest Infection Rate in relation to the population
Select location, population, Max(total_cases) as HighestInfection, 
Max((total_cases/population))*100
As PercentInfected
From CovidDeaths
--Where location like 'S%africa'
Group By location, population
Order By PercentInfected desc


---Highest Death Count per Population
Select location, Max(cast(total_deaths as int)) as HighestDeath
From CovidDeaths
Where continent is not null
Group By location
Order By HighestDeath desc



---BY Continent
Select continent, Max(cast(total_deaths as int)) as HighestDeath
From CovidDeaths
Where continent is not null
Group By continent
Order By HighestDeath desc


--Global Numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from CovidDeaths
Where continent is not null
group by date
order by 1,2

--
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from CovidDeaths
Where continent is not null
order by 1,2


--total population vs vaccinated 
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by deaths.location order by deaths.location, deaths.date) as TotalVacs
from CovidDeaths deaths
join CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
order by 2,3

--Making use of CTE 
With populationVSvac (Continent, location, date, population, new_vaccinations,TotalVacs)
as
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by deaths.location order by deaths.location, deaths.date) as TotalVacs
from CovidDeaths deaths
join CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
)

Select *, (TotalVacs/population) *100
from populationVSvac


---Temp Table approach
create table #PercentPopulationVaccinated(
	Continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	TotalVacs numeric
)

insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by deaths.location order by deaths.location, deaths.date) as TotalVacs
from CovidDeaths deaths
join CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null

Select *, (TotalVacs/population) *100
from #PercentPopulationVaccinated


--create a view to store for visualization
Create View PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by deaths.location order by deaths.location, deaths.date) as TotalVacs
from CovidDeaths deaths
join CovidVaccinations vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null