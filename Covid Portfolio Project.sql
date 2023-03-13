/*
Covid19 Data Exploration

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM coviddeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM covidvaccines
--ORDER BY 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM coviddeaths
ORDER BY 1,2


--Looking at Total cases vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM dbo.coviddeaths
--WHERE location like 'Viet%'
ORDER BY 1,2


--Looking at total cases vs population
--Shows what percentage of population infected with Covid

SELECT location, date,population,total_cases, total_deaths,  (total_cases/population)*100 as Infection_percentage
FROM dbo.coviddeaths
--WHERE location like '%states%'
ORDER BY 1,2



--Countries with Highest Infection Rate Compared to Population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as 
	Percent_population_infected
FROM dbo.coviddeaths
--WHERE location like '%Viet%'
GROUP BY location,population
ORDER BY Percent_population_infected DESC



--Countries with highest Death Count per Population


SELECT location, Max(total_deaths) as TotalDeathCount
From coviddeaths
WHERE continent is not null
Group by location
Order by TotalDeathCount DESC



--Breaking Things Down by Continent
--Showing Contient with the highest Death count per population

SELECT continent, Max(total_deaths) as TotalDeathCount
From coviddeaths
WHERE continent is not null
Group by continent
Order by TotalDeathCount DESC


--Global Numbers

SELECT sum(new_deaths) AS total_deaths, sum(new_cases) AS total_cases,
sum(new_deaths)/sum(new_cases)*100 AS Death_Percentage
FROM coviddeaths
WHERE continent is not null

--Global Numbers by date

SELECT date, sum(new_deaths) AS total_deaths, sum(new_cases) AS total_cases,
sum(new_deaths)/nullif(sum(new_cases),0)*100 AS Death_Percentage
FROM coviddeaths
WHERE continent is not null
Group by date
ORDER BY date



--Total Population Vs Vaccinations
--Shows Percentage of Population that has received at least one Covid Vaccine


SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations,
SUM(B.new_vaccinations) Over (partition by A.location Order by A.location, A.date) AS Rolling_people_vaccinated
FROM coviddeaths AS A
JOIN covidvaccines AS B
	ON A.location = B.location 
	 AND A.date = B.date
WHERE A.continent is not null
Order by 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
AS
(
SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations,
SUM(B.new_vaccinations) Over (partition by A.location Order by A.location, A.date) AS Rolling_people_vaccinated
FROM coviddeaths AS A
JOIN covidvaccines AS B
	ON A.location = B.location 
	 AND A.date = B.date
WHERE A.continent is not null
)
SELECT *, (Rolling_people_vaccinated/population)*100 AS Percentage_of_population_Vaccinated
FROM PopvsVac



--Temptable

DROP TABLE if EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location Nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations,
SUM(B.new_vaccinations) Over (partition by A.location Order by A.location, A.date) AS Rolling_people_vaccinated
FROM coviddeaths AS A
JOIN covidvaccines AS B
	ON A.location = B.location 
	 AND A.date = B.date
WHERE A.continent is not null
SELECT *, (Rolling_people_vaccinated/population)*100 AS Percentage_of_population_Vaccinated
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
SELECT A.continent, A.location, A.date, A.population, B.new_vaccinations,
SUM(B.new_vaccinations) Over (partition by A.location Order by A.location, A.date) AS Rolling_people_vaccinated
FROM coviddeaths AS A
JOIN covidvaccines AS B
	ON A.location = B.location 
	 AND A.date = B.date
WHERE A.continent is not null

