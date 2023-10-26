select * from CovidDeaths
order by 3,4

--select * from CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

-- Total Cases versus Total Deaths in Germany from beginning of Covid in Germany until April 30th 2021

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'germany'
order by 1, 2

-- Total cases verus population of Germany
select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject1.dbo.CovidDeaths
where location like 'germany'
order by 1, 2

-- the countries with the highest infection rated compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1.dbo.CovidDeaths
group by location, population
order by 1 desc

-- percentage of highest death count
select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject1.dbo.CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- continents with highest death counts
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1.dbo.CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- global numbers
select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject1.dbo.CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- global numbers
select sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1.dbo.CovidDeaths
where continent is not null
--group by date
order by 1, 2

-- Join CovidDeaths and CovidVaccinations together

Select * 
from PortfolioProject1.dbo.CovidVaccinations dea
Join PortfolioProject1.dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date

-- Total Populations vs New Vaccinations per day in germany
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum (cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
from PortfolioProject1.dbo.CovidDeaths dea
join PortfolioProject1.dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
and dea.location like 'germany'
order by 2,3

-- Population Percentage vs TotalVaccinations in germany using cte
with PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum (convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
--, (TotalVaccinations/population)*100
from PortfolioProject1.dbo.CovidDeaths dea
join PortfolioProject1.dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
and dea.location like 'germany'
--order by 2,3
)
Select *, (TotalVaccinations/population)*100 as VaccinationPercentage
from PopvsVac


-- Eine neue Tabelle erstellen, um die prozente der impfungen der gesamtbevölkerung anzuzeigen
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, TotalVaccinations numeric)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum (convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
--, (TotalVaccinations/population)*100
from PortfolioProject1.dbo.CovidDeaths dea
join PortfolioProject1.dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
and dea.location like 'germany'
--order by 2,3
Select *, (TotalVaccinations/population)*100 as VaccinationPercentage
from #PercentPopulationVaccinated


--Creating View to store data later
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum (convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
--, (TotalVaccinations/population)*100
from PortfolioProject1.dbo.CovidDeaths dea
join PortfolioProject1.dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
and dea.location like 'germany'
--order by 2,3

Select *
from PercentPopulationVaccinated