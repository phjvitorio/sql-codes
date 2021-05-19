select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject_1..CovidDeaths
order by 1, 2  

-- Casos vs mortes
-- Probabilidade de morrer se contrair covid no Brasil x tempo
select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
from PortfolioProject_1..CovidDeaths
where location like '%Brazil%'
order by 1, 2

-- Total de casos x populacao
select location, date, population, total_cases, ROUND((total_cases/population)*100,2) as CasesPercentage
from PortfolioProject_1..CovidDeaths
-- where location like '%Brazil%'
order by 1, 2

-- Regiao com maior taxa de infeccao
select location, population, MAX(total_cases) as Cases, MAX(ROUND((total_cases/population)*100,2)) as CasesPercentage
from PortfolioProject_1..CovidDeaths
group by location, population
order by 4 desc

-- Regiao com mais mortes
select location, population, MAX(CAST(total_deaths as int)) as Cases
from PortfolioProject_1..CovidDeaths
where continent is not null
group by location, population
order by 3 desc

-- Continente com mais mortes
select location, MAX(CAST(total_deaths as int)) as Deaths
from PortfolioProject_1..CovidDeaths
where continent is null
group by location
order by 2 desc

-- DADOS MUNDIAIS
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) as death_ratio--, SUM(CAST(total_deaths as int)), ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
from PortfolioProject_1..CovidDeaths
where continent is not null
group by date
order by date asc

-- Adicionando vacinados

select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) as rolling_vaccinated
from PortfolioProject_1..CovidDeaths d
join PortfolioProject_1..CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2, 3

--CTE

WITH peo_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinated) AS (
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) as rolling_vaccinated
from PortfolioProject_1..CovidDeaths d
join PortfolioProject_1..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
)

select *, (rolling_vaccinated/population)*100 from peo_vs_vac

--TEMP TABLE
drop table if exists #PercentVaccinated
create table #PercentVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinated numeric
)

insert into #PercentVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) as rolling_vaccinated
from PortfolioProject_1..CovidDeaths d
join PortfolioProject_1..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null

select *, (rolling_vaccinated/population)*100 from #PercentVaccinated