-- Checking the Dataset
--The data is uploaded to database named `covid`  and `deaths` & `vac` are tables 

SELECT *
FROM `..covid.deaths`;

SELECT *
FROM `..covid.vac`;

-- Selecting some data  to explore 

SELECT location,date,  total_cases , total_deaths , population 
FROM `..covid.deaths`;



-- total cases vs total deaths 

SELECT  location ,date , total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `..covid.deaths`
order by location,date

;

-- total case vs death for  Specific country 


SELECT  location ,date , total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `..covid.deaths`
WHERE location = "United States"
order by location,date

;


--  Total cases vs population 

SELECT  location ,date ,population, total_cases, (total_cases/population)*100 AS ContractionRatePercentage
FROM `..covid.deaths`
WHERE location = "United States"
order by location,date


;

-- Highest infaction rate Countries  

SELECT location ,MAX(population) AS Population,MAX(total_cases) AS TotalCases, MAX ((total_cases/population)*100) AS ContractionRatePercentage
FROM `..covid.deaths`
WHERE continent IS NOT NULL  --continent is null in aggregated rows like "world","Asia","africa"
GROUP BY location
ORDER BY 4 DESC

;

-- Countries with highest Death count per population

SELECT location ,MAX(population) AS Population,MAX(CAST(total_deaths as int)) AS TotalDeaths, MAX ((total_deaths/population)*100) AS DeathRatePercentageOverPopulation
FROM `..covid.deaths`
WHERE continent IS NOT NULL  
GROUP BY location
ORDER BY 4 DESC
; 


-- Death rate by continent 

SELECT continent, MAX(cast(total_deaths as int )) as TotalDeathCount2
FROM `project-1-350606.covid.deaths`
WHERE continent is not null 
GROUP BY continent
Order by 2
;
 

-- Global Stats 

SELECT date, SUM(new_cases) as GlobalNewCases , SUM(new_deaths) as GlobalNewDeaths
FROM `..covid.deaths`

WHERE continent is not null 
GROUP BY date
ORDER BY 1,2
;


--Joining the vaccination table with death rate table 


SELECT *
FROM `..covid.deaths` AS dea
JOIN `..covid.vac` AS vac
  ON dea.date = vac.date 
  AND dea.location = vac.location
;


-- total population vs vaccination 


SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
FROM `..covid.deaths` AS dea
JOIN `..covid.vac` AS vac
  ON dea.date = vac.date 
  AND dea.location = vac.location
WHERE dea.continent is not null 
ORDER BY 2,3
;


-- Rolling vaccination by date 


SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalVaccinatedeUptoDate 
         --the partition makes sure the counter gets reset for each unique location
         --the date pertiiton makes the incremental roll of sum possible
FROM `..covid.deaths` AS dea
JOIN `..covid.vac` AS vac
  ON dea.date = vac.date 
  AND dea.location = vac.location
WHERE dea.location = "United States"  or dea.location ="Canada"
ORDER BY dea.location,dea.date 
;


-- Percentage of Vaccination by country 

WITH PopVsVacas AS(
  SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinated
         --the partition makes sure the counter gets reset for each unique location
         --the date pertiiton makes the incremental roll of sum possible
FROM `..covid.deaths` AS dea
JOIN `..covid.vac` AS vac
  ON dea.date = vac.date 
  AND dea.location = vac.location
  WHERE dea.continent is not null
--WHERE dea.location = "United States"  or dea.location ="Canada"
--ORDER BY dea.location,dea.date ;
)
select *, (TotalVaccinated/population) * 100 AS Vaccine_percentage
FROM PopVsVacas

;

-- Creating Temp table 

--Trial verion of Bigquerry doesn't allow data insertion in new table, so extract data from prev querry and manually inset into the table  
-- If you're using paid version, the following scripts will do just fine


-- DROP TABLE IF EXISTS `covid.PercentPopulationVac` ;
-- CREATE TABLE `covid.PercentPopulationVac` 
-- (
--   continent string,
--   location string,
--   date datetime,
--   population integer,
--   new_vaccinations integer,
--   TotalPeopleVaccinated integer
-- );


-- INSERT INTO `covid.PercentPopulationVac` 
-- SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations,
--   SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinated
--          --the partition makes sure the counter gets reset for each unique location
--          --the date pertiiton makes the incremental roll of sum possible
-- FROM `..covid.deaths` AS dea
-- JOIN `..covid.vac` AS vac
--   ON dea.date = vac.date 
--   AND dea.location = vac.location
--   WHERE dea.continent is not null;


-- SELECT *,(TotalPeopleVaccinated/population)*100
-- FROM `covid.PercentPopulationVac` 


-- ;

-- Creating Views For Cisualizations


CREATE VIEW IF NOT EXISTS covid.VaccinationRate AS

SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
FROM `..covid.deaths` AS dea
JOIN `..covid.vac` AS vac
  ON dea.date = vac.date 
  AND dea.location = vac.location
WHERE dea.continent is not null 

;

--Testing the view 

SELECT *
FROM `project-1-350606.covid.VaccinationRate`


;

















