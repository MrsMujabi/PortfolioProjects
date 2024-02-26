Select *
From [PortfolioProject]..[CovidDeaths]
Where Continent is not null
Order by 3, 4

--Select *
--From [PortfolioProject]..[CovidVaccinations]
--Order by 3, 4

--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
Order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got Covid

Select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc

--Showing countries with highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select Continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Continent
Order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select Continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Continent
Order by TotalDeathCount

--GLOBAL NUMBERS

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null
--Group by date
Order by 1,2

--Looking at Total Population Vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int,new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	Sum(Convert(int,new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations.vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
--Order by 2,3)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentagePopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	Sum(Convert(int,new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations.vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
--Order by 2,3)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	Sum(Convert(int,new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations.vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.Continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated