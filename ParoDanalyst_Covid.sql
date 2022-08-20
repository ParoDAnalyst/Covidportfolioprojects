select *
from [dbo].['owid-coviddeath]
order by 3, 4

--select *
--from [dbo].['owid-covidvaccination]
--order by 3, 4


--DATA EXPLORATION
select location, date, total_cases, new_cases, total_deaths, population
from [dbo].['owid-coviddeath]
order by 1,2

-- Looking at the total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)
from [dbo].['owid-coviddeath]
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as Deathpercentage
from [dbo].['owid-coviddeath]
order by 1,2

-- As at 2020-08-17 we have 4.09% of death from the toal case in Afghanistan  (LIKELYHOOD OF DYING ONCE YOU CONTRACT COVID 19)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as Deathpercentage
from [dbo].['owid-coviddeath]
where location like '%states'
order by 1,2

-- As at 2020-08-17 1.12%  death in the united states


-- TOTAL CASES VS POPULATION

select location, date, total_cases, population, (total_cases/population)*100 as Deathpercentage
from [dbo].['owid-coviddeath]
where location like'%stan'
order by 1,2


-- Country with the highest infection rate compared to population

select location,population, max(total_cases) as HIGHESTINFECTION, max((total_cases/population))*100 as INFECTEDPOPULATIONpercentage
from [dbo].['owid-coviddeath]
Group by location, population
Order by INFECTEDPOPULATIONpercentage desc

-- country with the highest death

select location,  max(cast(total_deaths as int)) as HIGHESTDEATH, max((total_deaths/population))*100 as DEATHPOPULATIONpercentage
from [dbo].['owid-coviddeath]
Group by location
Order by DEATHPOPULATIONpercentage desc

select location, max(cast(total_deaths as int)) as HIGHESTDEATH
from [dbo].['owid-coviddeath]
where continent is not null
Group by location
Order by HIGHESTDEATH desc

-- COUNTRY WITH THE HIGHEST CASES

select location, max(cast(total_cases as int)) as HIGHESTCASES
from [dbo].['owid-coviddeath]
where continent is not null
Group by location
Order by HIGHESTCASES desc

-- CONTINENT


select continent, max(cast(total_cases as int)) as HIGHESTCASES
from [dbo].['owid-coviddeath]
where continent is not null
Group by continent
Order by HIGHESTCASES desc



select continent, max(cast(total_deaths as int)) as HIGHESTDEATH
from [dbo].['owid-coviddeath]
where continent is not null
Group by continent
Order by HIGHESTDEATH desc


select continent, max(cast(total_deaths as int)) as HIGHESTDEATH, max((total_deaths/population))*100 as continentdeath
from [dbo].['owid-coviddeath]
where continent is not null
Group by continent
Order by continentdeath desc


select continent, max(cast(total_cases as int)) as HIGHESTCASES, max((total_cases/population))*100 as continentcase
from [dbo].['owid-coviddeath]
where continent is not null
Group by continent
Order by continentcase desc


-- GLOBAL NUMBERS

select continent, location, date, total_cases, new_cases, total_deaths, population
from [dbo].['owid-coviddeath]
where continent is not null
order by 1,2

--- Number of cases by day globally

select SUM(new_cases), date
from [dbo].['owid-coviddeath]
where continent is not null
group by date
order by 1

-- NUMBER OF DEATH PER DAY

select date, sum(cast(new_deaths as int))
from [dbo].['owid-coviddeath]
where continent is not null
group by date
order by 1

select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeath, sum(cast(new_deaths as int))/ sum(new_cases) *100 as deathpercentage1
from [dbo].['owid-coviddeath]
where continent is not null
group by date
order by 1,2

select  sum(new_cases) as toatlcases, sum(cast(new_deaths as int)) as totaldeath, sum(cast(new_deaths as int))/ sum(new_cases) *100 as deathpercentage1
from [dbo].['owid-coviddeath]
--where continent is not null
--group by date
order by 1,2



--VACCINATION

select *
from [dbo].['owid-coviddeath] as dc inner join [dbo].['owid-covidvaccination] as vc on dc.location = vc.location and dc.date = vc.date

--Total vaccination by total population

select dc.continent, dc.location,dc.date, dc.population, vc.new_vaccinations
from [dbo].['owid-coviddeath] as dc inner join [dbo].['owid-covidvaccination] as vc on dc.location = vc.location and dc.date = vc.date
where dc.continent is not null
order by 2,3

--- USING PARTITION

select dc.continent, dc.location,dc.date, dc.population, vc.new_vaccinations, sum(cast ( vc.new_vaccinations as bigint)) over (partition by dc.location) 
from [dbo].['owid-coviddeath] as dc inner join [dbo].['owid-covidvaccination] as vc on dc.location = vc.location and dc.date = vc.date
where dc.continent is not null
order by 2,3

---
select dc.continent, dc.location,dc.date, dc.population, vc.new_vaccinations, sum(cast ( vc.new_vaccinations as bigint)) over (partition by dc.location order by dc.location,dc.date) as ROllingpeoplevaccinated
from [dbo].['owid-coviddeath] as dc inner join [dbo].['owid-covidvaccination] as vc on dc.location = vc.location and dc.date = vc.date
where dc.continent is not null
order by 2,3


----USING CTE

with PopvsVac (continent, location,date, population, new_vaccinations,ROllingpeoplevaccinated)
as
(
select dc.continent, dc.location,dc.date, dc.population, vc.new_vaccinations, sum(cast ( vc.new_vaccinations as bigint)) over (partition by dc.location order by dc.location,dc.date) as ROllingpeoplevaccinated
-- ,(ROllingpeoplevaccinated/population)*100
from [dbo].['owid-coviddeath] as dc inner join [dbo].['owid-covidvaccination] as vc on dc.location = vc.location and dc.date = vc.date
--where dc.continent is not null
--order by 2,3
) 
select *, ((ROllingpeoplevaccinated/population)*100)
from PopvsVac

--TEMP TABLE




Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacinnations numeric,
ROllingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dc.continent, dc.location,dc.date, dc.population, vc.new_vaccinations, sum(cast ( vc.new_vaccinations as bigint)) over (partition by dc.location order by dc.location,dc.date) as ROllingpeoplevaccinated
-- ,(ROllingpeoplevaccinated/population)*100
from [dbo].['owid-coviddeath] as dc inner join [dbo].['owid-covidvaccination] as vc on dc.location = vc.location and dc.date = vc.date
--where dc.continent is not null
--order by 2,3

select *
from #percentpopulationvaccinated
