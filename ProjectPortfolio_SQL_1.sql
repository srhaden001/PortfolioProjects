Select *
From CovidDeaths
Where location Like '%Canada%'

Select *
From CovidVaccinations

--Select data to use

Select population, location, date, total_cases, new_cases,total_deaths
From CovidDeaths
Where location Like '%Canada%'
Order by total_deaths desc

--Total cases vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 As DeathPercentage
From CovidDeaths
Where location Like '%states%'
Order by 1,2


--Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population) * 100 As CasePercentage
From CovidDeaths
Where location Like '%states%'
Order by 1,2

--Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) As HighestInfectionCount, (MAX(total_cases)/population) * 100 As InfectionPercentage
From CovidDeaths
--Where location Like '%states%'
Group By location, population
Order by 3 Desc

--Countries with highest death count per population

Select location, MAX(CAST(total_deaths as INT)) As CountryTotalDeathCount
From CovidDeaths
Where continent Is Not Null
Group By location
Order by CountryTotalDeathCount Desc

Select continent, MAX(CAST(total_deaths as INT)) As TotalDeathCount
From CovidDeaths
Where continent Is Not Null
Group By continent
Order by TotalDeathCount Desc

Select continent, SUM(CAST(total_deaths as INT)) As TotalDeathCount
From CovidDeaths
Where continent Is Not Null
Group By continent
Order by TotalDeathCount Desc

Select location, MAX(CAST(total_deaths as INT)) As TotalDeathCount
From CovidDeaths
Where continent Is Null
Group By location
Order by TotalDeathCount Desc

--Continents with highest death count

Select location, MAX(CAST(total_deaths as INT)) As CountryTotalDeathCount
From CovidDeaths
Where continent Is Not Null
Group By location
Order by CountryTotalDeathCount Desc

--Global numbers


Select date, SUM(new_cases) As total_cases, SUM(cast(new_deaths as Int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 As DeathPercentage
From CovidDeaths
Where continent Is Not Null
Group By date
Order by 1,2

Select SUM(new_cases) As total_cases, SUM(cast(new_deaths as Int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 As DeathPercentage
From CovidDeaths
Where continent Is Not Null
--Group By date
Order by 1,2


--Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(new_vaccinations as Int)) Over(Partition By cd.location Order By cd.location, cd.date) As RollingVaccinationCount,

From CovidDeaths cd
	Join CovidVaccinations cv
	On cd.location = cv.location
	And cd.date = cv.date
Where cd.continent Is Not Null
Order By 2,3


--CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingVacinationCount) As
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(new_vaccinations as Int)) Over(Partition By cd.location Order By cd.location, cd.date) As RollingVaccinationCount

From CovidDeaths cd
	Join CovidVaccinations cv
	On cd.location = cv.location
	And cd.date = cv.date
Where cd.continent Is Not Null
)

Select *, (RollingVacinationCount/Population) *100 As RollingVacVsPop
From PopVsVac

--Temp Table

Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)

Insert Into #PercentPopulationVaccinated

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(new_vaccinations as Int)) Over(Partition By cd.location Order By cd.location, cd.date) As RollingVaccinationCount

From CovidDeaths cd
	Join CovidVaccinations cv
	On cd.location = cv.location
	And cd.date = cv.date
Where cd.continent Is Not Null

Select *, (RollingVaccinationCount/Population) *100 As RollingVacVsPop
From #PercentPopulationVaccinated
Order By 2,3

Create View PercentPopulationVaccinated As

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(Cast(new_vaccinations as Int)) Over(Partition By cd.location Order By cd.location, cd.date) As RollingVaccinationCount

From CovidDeaths cd
	Join CovidVaccinations cv
	On cd.location = cv.location
	And cd.date = cv.date
Where cd.continent Is Not Null

Select * 
From PercentPopulationVaccinated
Order By 2,3
