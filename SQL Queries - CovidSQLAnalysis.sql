-- select * from CovidDeaths;
-- select * from CovidVaxs;

-- Country + Continent Analysis

-- Total cases vs Total deaths
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by location, date;

-- Total cases vs Total deaths by location
select location, date, total_cases, total_deaths, round((cast(total_deaths as float)/ total_cases)*100, 2) as death_rate
from CovidDeaths
order by location, date;
-- Continent
select continent, date, total_cases, total_deaths, round(cast(total_deaths as float)/ total_cases*100, 2) as death_rate
from CovidDeaths
where continent is not null
group by continent, date
order by continent, date;

-- Total cases vs Population (percentage of population that died from Covid)
select location, date, total_cases, population, round(cast(total_cases as float)/ population*100, 2) as PercentPopulationInfected
from CovidDeaths
order by location, date;
-- Continent
select continent, date, total_cases, population, round(cast(total_cases as float)/ population*100, 2) as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by continent, date
order by continent, date;

-- Countries with the highest infection rate compared to population
select location, total_cases, population,
       max(total_cases) as HighestInfectionCount, max(round(cast(total_cases as float)/ population*100, 2)) as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc;
-- Continent
WITH max_cases AS (
  SELECT continent, max(total_cases) AS highest_infection_count
  FROM CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY continent
)
SELECT cd.continent,
       cd.total_cases,
       cd.population,
       mc.highest_infection_count,
       round(cast(cd.total_cases as float) / cd.population * 100, 2) AS percent_population_infected
FROM CovidDeaths cd
JOIN max_cases mc ON cd.continent = mc.continent AND cd.total_cases = mc.highest_infection_count
WHERE cd.continent IS NOT NULL
group by cd.continent, cd.total_cases, cd.population, mc.highest_infection_count
ORDER BY percent_population_infected DESC;

-- Countries with the highest death count per population
select location, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;
-- Continents with the highest death count per population
select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;
---- Correct Query
select location, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is null and location not in ('International', 'European Union', 'High income', 'Low income', 'Upper middle income', 'Lower middle income', 'Low income')
group by location
order by TotalDeathCount desc;


-- GLOBAL ANALYSIS

select sum(new_cases) as total_cases,
       sum(new_deaths) as total_deaths,
       ROUND(CAST(SUM(new_deaths) AS FLOAT) / SUM(new_cases) * 100, 2) as DeathPercentage
from CovidDeaths
where continent is not null
order by 1, 2;

--join tables
-- Total population vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,

from CovidDeaths dea
join CovidVaxs vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date;

--CTE
with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
    (
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
         sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  from CovidDeaths dea
  join CovidVaxs vac
      on dea.location = vac.location
             and dea.date = vac.date
  where dea.continent is not null
  order by dea.location, dea.date
)
select *, (cast(RollingPeopleVaccinated as float)/ population)*100 from PopVsVac;

-- Temp Table
Drop table PopVsVac;
create temporary table PopVsVac
(
    Continent varchar(255),
    Location varchar(255),
    Date date,
    Population int,
    New_Vaccinations int,
    RollingPeopleVaccinated int
);
insert into PopVsVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
         sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  from CovidDeaths dea
  join CovidVaxs vac
      on dea.location = vac.location
             and dea.date = vac.date
  where dea.continent is not null
  order by dea.location, dea.date;
select * from PopVsVac;

-- VIEWS
create view PopVsVac as
    select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
         sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  from CovidDeaths dea
  join CovidVaxs vac
      on dea.location = vac.location
             and dea.date = vac.date
  where dea.continent is not null
  order by dea.location, dea.date;
