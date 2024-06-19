Select *
From CovidDeaths

-- Table of India's Covid Info
Select location,date,total_cases,total_deaths,population
From CovidDeaths
Where location='India'

--Likelihood of death
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as ProbabilityOfDeath
From CovidDeaths
Where location='India'

--Infected Percentage compared to population
Select location,date,total_cases,population,(total_cases/population)*100 as InfectedPercentage
From CovidDeaths
Where location='India'

--Locations with Highest Infected Count and their Highest Infected percentage
Select location,population,max(total_cases) as MaxInfectedCount,max((total_cases/population))*100 as InfectedPercentage
From CovidDeaths
Where continent is not null
Group By location, population
Order By InfectedPercentage	

--Locations with Highest Death Count and their Highest Death percentage
Select location,max(cast(total_deaths as int)) as MaxDeathCount
From CovidDeaths
Where continent is not null
Group By location
Order By MaxDeathCount desc

-- Grouping the info by continents
Select location,max(cast(total_deaths as int)) as MaxDeathCount
From CovidDeaths
Where continent is null
Group By location
Order By MaxDeathCount desc

-- Showing continents with highest death count
Select continent,max(cast(total_deaths as int)) as MaxDeathCount
From CovidDeaths
Where continent is not null
Group By continent
Order By MaxDeathCount desc

-- Global Numbers by date
select date,sum(new_cases) as TotalCases,Sum(cast(new_deaths as int)) as TotalDeaths,(Sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
Group by date
Order by 1,2

-- Global Numbers
select sum(new_cases) as TotalCases,Sum(cast(new_deaths as int)) as TotalDeaths,(Sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
Order by 1,2

--Looking at Total population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,new_vaccinations)) Over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE A CTE
WITH PopvsVac(Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
AS 
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,new_vaccinations)) Over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)



Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,new_vaccinations)) Over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating Views to store data for further vizualization

Create view PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,new_vaccinations)) Over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated
