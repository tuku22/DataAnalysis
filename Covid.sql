Select Location, date, total_cases, new_cases, total_deaths, population
From master..CovidDeaths$
Where continent is not null
order by 1,2

-- Let's have a look at Total Cases vs Total Deaths
-- Showing the likelyhood of dying in Finland
Select Location, date, total_cases, total_deaths,
	(CAST(total_deaths as float)/ CAST(total_cases as float))*100 as DeathPercentage
From master..CovidDeaths$
Where location like '%Finland%'
order by 1,2

-- Shows what percentage of population got Covid in Finland

Select Location, date, Population, total_cases,
	(CAST(total_cases as float)/ CAST(population as float))*100 as CovidPercentage
From master..CovidDeaths$
Where location like '%Finland%'
order by 1,2

-- Lets look at Countries with Highest Infection Rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,
	MAX((CAST(total_cases as float)/ CAST(population as float)))*100 as PercentOfPopulationInfected
From master..CovidDeaths$
Group by Location, Population
order by PercentOfPopulationInfected desc

-- Showing Countries with Highest Death count per Population
Select Location, MAX((CAST(total_deaths as float))) as TotalDeathCount
From master..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Show continents death count statistics

Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From master..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Show continents with the highest death count per

Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From master..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select date, SUM(cast(new_cases as float)), SUM(cast(new_deaths as float)), SUM(cast(new_deaths as float)) / SUM(cast(New_Cases as float)) * 100 as DeathPercentage
From master..CovidDeaths$
Where continent is not null
Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From master..CovidDeaths$ dea
Join master..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location
Order by dea.location, dea.Date) as RollingPeopleVaccinated
From master..CovidDeaths$ as dea
Join master..CovidVaccinations$ as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null