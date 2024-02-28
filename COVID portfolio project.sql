Select *
From PortfolioProject..[csv.CovidDeathsData]
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..[csv.CovidVaccinationsData]
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[csv.CovidDeathsData]
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[csv.CovidDeathsData]
--where location like '%kingdom%'
order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationIngfected
From PortfolioProject..[csv.CovidDeathsData]
--where location like '%kingdom%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..[csv.CovidDeathsData]
--where location like '%kingdom%'
Group by location, population
order by 4 DESC

--Showing countries with Highest Death Count per Population
Select location, MAX(total_deaths) AS TotalDeathCount
From PortfolioProject..[csv.CovidDeathsData]
--where location like '%kingdom%'
where continent is not null
Group by location
Order by TotalDeathCount desc


--Showing continents with highest death count per population
Select continent, MAX(total_deaths) AS TotalDeathCount
From PortfolioProject..[csv.CovidDeathsData]
--where location like '%kingdom%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global data:
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..[csv.CovidDeathsData]
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date)
, as RollingPeopleVaccinated, (RollingPeopleVacci
from PortfolioProject..[csv.CovidDeathsData] dea
join [csv.CovidVaccinationsData] vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Implementing CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..[csv.CovidDeathsData] dea
join [csv.CovidVaccinationsData] vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac

--Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..[csv.CovidDeathsData] dea
join [csv.CovidVaccinationsData] vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null

