
select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total Cases vs Total Deaths
--Shows likelihood of dyingif you contact covid in your country
select location,date,total_cases,total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at total Cases vs Population
--Shows what percentage of population got Covid
select location,date,population,total_cases, (total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionRate
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by InfectionRate desc


--- LET'S Break things Down by Continent

select continent,max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Looking at countries with Highest Date Count per population
select location,max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count
select continent,max(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2 

--Overall deaths percentage
select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2 




--looking at total population vs vaccination
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopkeVaccinated
---,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv on 
	cd.location=cv.location and
	cd.date=cv.date
where cd.continent is not null
order by 2,3

--cte for looking at total population vs vaccination
With PopvsVac (Continent,Location,Date,Population, NewVac,RollingPeopleVaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopkeVaccinated
---,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv on 
	cd.location=cv.location and
	cd.date=cv.date
where cd.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 
from PopvsVac

-- Temp Table for looking at total population vs vaccination

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopkeVaccinated
---,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv on 
	cd.location=cv.location and
	cd.date=cv.date
--where cd.continent is not null
--order by 2,3


Select *,(RollingPeopleVaccinated/Population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated

--- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopkeVaccinated
---,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv on 
	cd.location=cv.location and
	cd.date=cv.date
where cd.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated