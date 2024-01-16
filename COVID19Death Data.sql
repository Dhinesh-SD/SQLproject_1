
SELECT *
FROM Vaccinations
ORDER BY 3,4

SELECT location, date, total_cases,new_cases,total_deaths,population
FROM PortfolioCovidProject.dbo.CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases,total_deaths,(CONVERT(int, TRIM(total_deaths))/CONVERT(int,TRIM(total_cases)))*100 as DeathPercentage
FROM PortfolioCovidProject.dbo.CovidDeaths
ORDER BY 1,2

--SHOWS PERCENTAGE OF IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT CD.iso_code, CD.location, CD.date, total_cases, total_deaths, concat(round((CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100,2),'%') As TotalDeathPercentage
FROM PortfolioCovidProject.dbo.CovidDeaths CD
right JOIN PortfolioCovidProject..Vaccinations Vacc
	ON CD.iso_code = Vacc.iso_code
GROUP BY CD.iso_code, CD.location, CD.date, total_cases,total_deaths
HAVING CD.iso_code ='USA' and CD.new_cases is not NULL
ORDER BY 3 DESC

--SHOWS WHAT PERCENTAGE OF NEW CASES GOT AFFECTED BY COVID EVERY MONTH OF THE YEAR

SELECT CD.location,MONTH(CD.date)as MonthNum, YEAR(CD.date) As Yr ,SUM(Convert(int,CD.new_cases)) AS New_Cases_Evey_Month ,cd.population,ROUND((SUM(Convert(float,CD.new_cases))/population)*100,5) as AffectedPercentage
FROM PortfolioCovidProject..CovidDeaths CD
WHERE CD.iso_code = 'USA'
GROUP BY  CD.location, month(CD.date),YEAR(CD.date),cd.population
ORDER BY 3,2

--Same as above not grouped
SELECT location,date,total_cases,population,(CONVERT(float,total_cases)/population)*100 As Affected_Percentage
FROM PortfolioCovidProject..CovidDeaths
WHERE iso_code ='AND'
GROUP BY location,date,total_cases,population
ORDER BY 1,2

--INFECTION RATES IN EACH COUNTRY COMPARED TO POPULATION
SELECT iso_code,location,population,MAX(convert(int,total_cases)) as TotalInfectionCount, MAX(CONVERT(float,total_cases)/population)*100 As Affected_Percentage
FROM PortfolioCovidProject..CovidDeaths
GROUP BY iso_code,location,population
ORDER BY 3 DESC

--Countries with Highest Mortality Rate per affected population 
SELECT location,Max(CAST(total_cases AS int)) AS Total_Cases_Registered,MAX(cast(total_deaths as int)) as TotalDeathCount,(MAX(CONVERT(float,total_deaths))/MAX(convert(Float,total_cases)))*100 As Mortality_Rate
FROM PortfolioCovidProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY 3 DESC

--CONTINENTS with Highest Mortality Rate per affected population 
SELECT continent,Max(CAST(total_cases AS int)) AS Total_Cases_Registered,MAX(cast(total_deaths as int)) as TotalDeathCount,(MAX(CONVERT(float,total_deaths))/MAX(convert(Float,total_cases)))*100 As Mortality_Rate
FROM PortfolioCovidProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY 4 DESC

--GLOBAL NUMBERS
SELECT SUM(CAST(new_cases AS int)) AS Total_Cases_Registered,SUM(Cast(new_deaths as int)) as TotalDeathCount,(SUM(Cast(total_deaths as float))/SUM(CAST(total_cases AS float)))*100 AS Death_Percentage
FROM PortfolioCovidProject..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


--PERCENTAGE OF POPULATION VACCINATED  USING CTE table
WITH CTE_Percent_Vaccinated (Continent,Location,Date,Population,NewVaccinations,Cummulative_Vacc)
As
( 
SELECT CD.continent,CD.location,CD.date,CD.population,CAST(Vacc.new_vaccinations AS int) as NewVaccinations
,SUM(CONVERT(float,Vacc.new_vaccinations))OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) As Cummulative_Vaccination
FROM PortfolioCovidProject..CovidDeaths CD
JOIN PortfolioCovidProject..Vaccinations Vacc
	ON CD.location = Vacc.location AND CD.date=Vacc.date
WHERE CD.continent is NOT NULL
--ORDER BY 1,2,3
)
SELECT *,(Cummulative_Vacc/Population)*100 As Percent_Vaccinated
FROM CTE_Percent_Vaccinated



--PERCENTAGE OF POPULATION VACCINATED  USING Temp TABLE
DROP TABLE IF EXISTS #Percent_Vaccinated 
CREATE TABLE #Percent_Vaccinated 
(Continent nvarChar(250),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
Cummulative_Vacc numeric)

INSERT INTO #Percent_Vaccinated 
SELECT CD.continent,CD.location,CD.date,CD.population,CAST(Vacc.new_vaccinations AS int) as NewVaccinations
,SUM(CONVERT(float,Vacc.new_vaccinations))OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) As Cummulative_Vaccination
FROM PortfolioCovidProject..CovidDeaths CD
JOIN PortfolioCovidProject..Vaccinations Vacc
	ON CD.location = Vacc.location AND CD.date=Vacc.date
WHERE CD.continent is NOT NULL
--ORDER BY 1,2,3

SELECT *,(Cummulative_Vacc/Population)*100 As Percent_Vaccinated
FROM #Percent_Vaccinated

----CREATING A VIEW
--CREATE VIEW Percentage_population_Vacc as
--SELECT CD.continent,CD.location,CD.date,CD.population,CAST(Vacc.new_vaccinations AS int) as NewVaccinations
--,SUM(CONVERT(float,Vacc.new_vaccinations))OVER (PARTITION BY CD.location ORDER BY CD.location,CD.date) As Cummulative_Vaccination
--FROM PortfolioCovidProject..CovidDeaths CD
--JOIN PortfolioCovidProject..Vaccinations Vacc
--	ON CD.location = Vacc.location AND CD.date=Vacc.date
--WHERE CD.continent is NOT NULL

SELECT * FROM Percentage_population_Vacc