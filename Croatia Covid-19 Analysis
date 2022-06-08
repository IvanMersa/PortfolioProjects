/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT  *
FROM `projekt.CovidDeaths` 

SELECT  *
FROM `projekt.CovidVaccinations` 

-- Select the data

SELECT location, date, total_cases,new_cases, total_deaths,population
FROM `projekt.CovidDeaths` 
ORDER BY location, date

-- Mortality rate

SELECT location, date, new_cases, total_cases, total_deaths, ((total_deaths/total_cases)*100) as postotak_smrtnosti
FROM `projekt.CovidDeaths` 
WHERE location = "Croatia"
ORDER BY location, date

-- Total cases vs population
-- Shows the percentage of the population infected with the corona

SELECT location, date, new_cases, total_cases, total_deaths, ((total_cases/population)*100) as postotak_zaraze
FROM `projekt.CovidDeaths` 
WHERE location = "Croatia"
ORDER BY location, date

-- Countries with the highest number of cases

SELECT location, population, MAX(total_cases) as zadnji_broj_zarazenih,
MAX((total_cases/population))*100 as najveci_postotak_zarazenih
FROM `projekt.CovidDeaths` 
GROUP BY location, population
ORDER BY najveci_postotak_zarazenih DESC

-- Countries with the highest mortality

SELECT location, MAX(CAST(total_deaths AS INT)) as zadnji_broj_umrlih,
MAX((total_deaths/population))*100 as najveci_postotak_umrlih
FROM `projekt.CovidDeaths` 
WHERE continent is not null
GROUP BY location
ORDER BY zadnji_broj_umrlih DESC

-- Continents with the highest mortality

SELECT continent, MAX(CAST(total_deaths AS INT)) as umrli,
MAX((total_deaths/population))*100 as postotak_umrlih
FROM `projekt.CovidDeaths` 
WHERE continent is not null
GROUP BY continent
ORDER BY umrli DESC

-- GLOBAL

SELECT SUM(new_cases) AS ukupni_slucajevi, SUM(CAST(new_deaths AS INT)) AS ukupna_smrt, 
SUM(new_deaths)/SUM(new_cases)*100 AS postotak_smrtnosti -- total_deaths, ((total_deaths/total_cases)*100) as postotak_smrtnosti
FROM `projekt.CovidDeaths` 
WHERE continent is not null
--GROUP BY date 
--ORDER BY date DESC

-- Vaccination rate through time

SELECT continent, location, date, population, procjepljenost, (procjepljenost/population)*100 as procjepljenost_kroz_vrijeme
FROM(SELECT d. continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as procjepljenost
FROM `projekt.CovidDeaths` d
JOIN `projekt.CovidVaccinations`v
    ON d.location = v.location 
    AND d.date = v.date 
WHERE d.continent is not null
ORDER BY 2, 3) a

-- Creating view to store data for later visualizations

CREATE VIEW projekt.procjepljenost_kroz_vrijeme as 
SELECT continent, location, date, population, procjepljenost, (procjepljenost/population)*100 as procjepljenost_kroz_vrijeme
FROM(SELECT d. continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as procjepljenost
FROM `projekt.CovidDeaths` d
JOIN `projekt.CovidVaccinations`v
    ON d.location = v.location 
    AND d.date = v.date 
WHERE d.continent is not null
ORDER BY 2, 3) a

-- An overview of hospitalization rates and vaccination rates over time in Croatia

SELECT location,date,stopa_procjepljenosti, stopa_hospitaliziranosti
FROM(
SELECT d.location,d.date,d.total_cases,d.hosp_patients, ((d.hosp_patients/d.total_cases)*100) as stopa_hospitaliziranosti,
((v.people_vaccinated/d.population)*100) as stopa_procjepljenosti
FROM `projekt.CovidDeaths` d
JOIN `projekt.CovidVaccinations` v
ON d.location = v.location 
AND d.date = v.date
WHERE d.hosp_patients  is not null and v.people_vaccinated is not null
GROUP BY location,date, total_cases,hosp_patients,stopa_procjepljenosti
ORDER by location asc) a 
WHERE location = "Croatia"

-- Impact of human_development_index on mortality

SELECT distinct(location), AVG(postotak_smrtnosti) OVER(PARTITION BY location order by location) as smrtnost,
human_development_index
from
(select d.location,d.date, (d.total_deaths/d.total_cases)*100 as postotak_smrtnosti,
v.human_development_index
FROM `projekt.CovidDeaths` d
JOIN `projekt.CovidVaccinations` v
ON d.date = v.date
AND d.location = v.location
GROUP BY d.location,d.date,postotak_smrtnosti,human_development_index
) a
GROUP BY location, postotak_smrtnosti, date, human_development_index
GROUP BY smrtnost desc,human_development_index desc
