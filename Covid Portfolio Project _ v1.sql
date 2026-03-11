Select *
From Portfolio_Project..CovidDeaths
Where continent is not null
order by 3,4


--select *
--from Portfolio_Project..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2

--Likelihood of dying if you contract covid in your contry
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..CovidDeaths
Where location like '%states%'
order by 1,2

-- Total Cases vs Population - show percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
From Portfolio_Project..CovidDeaths
Where location like '%states%'
order by 1,2

Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
From Portfolio_Project..CovidDeaths


-- Country with higest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, (Max(total_cases)/population)*100 as InfectionRate
From Portfolio_Project..CovidDeaths
Group by location, population
order by InfectionRate desc



Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by Location 
order by TotalDeathCount desc

-- By continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Continent with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc


-- Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100  as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
group by DATE
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100  as DeathPercentage
From Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2

-- Total population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization
DROP View IF EXISTS PercentPopulationVaccinated;
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


SELECT * FROM PercentPopulationVaccinated;


CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
    --, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3

SELECT * FROM sys.views 
WHERE name = 'PercentPopulationVaccinated';

SELECT * FROM PercentPopulationVaccinated;
