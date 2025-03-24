-- Kontrola dat v původních tabulkách
SELECT * FROM czechia_price ORDER BY date_from;
SELECT * FROM czechia_payroll ORDER BY payroll_year;

-- Odstranění staré verze konečné tabulky, pokud existuje
DROP TABLE IF EXISTS t_yegor_gladush_project_SQL_primary_final;

-- Vytvoření hlavní konečné tabulky
CREATE TABLE t_yegor_gladush_project_SQL_primary_final AS
SELECT
    cpc.name AS food_category,
    cpc.price_value,
    cpc.price_unit,
    cp.value AS price,
    cp.date_from,
    cp.date_to,
    cpay.payroll_year,
    cpay.value AS avg_wages,
    cpib.name AS industry_branch
FROM czechia_price cp
JOIN czechia_payroll cpay
    ON YEAR(cp.date_from) = cpay.payroll_year
    AND cpay.value_type_code = 5958
    AND cp.region_code IS NULL
JOIN czechia_price_category cpc
    ON cp.category_code = cpc.code
JOIN czechia_payroll_industry_branch cpib
    ON cpay.industry_branch_code = cpib.code;

-- Náhled na konečnou tabulku
SELECT * FROM t_yegor_gladush_project_SQL_primary_final ORDER BY date_from, food_category;

-- Další data o Evropě (2006–2018)
DROP TABLE IF EXISTS t_yegor_gladush_project_SQL_secondary_final;

CREATE TABLE t_yegor_gladush_project_SQL_secondary_final AS
SELECT
    c.country,
    e.`year`,
    e.population,
    e.gini,
    e.GDP
FROM countries c
JOIN economies e ON e.country = c.country
WHERE c.continent = 'Europe'
    AND e.`year` BETWEEN 2006 AND 2018
ORDER BY c.country, e.`year`;

-- Kontrola doplňkové tabulky
SELECT * FROM t_yegor_gladush_project_SQL_secondary_final;




-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- Vytvoření VIEW pro výpočet trendu mezd
CREATE OR REPLACE VIEW v_yegor_gladush_project_wages_trend AS
SELECT
    industry_branch,
    payroll_year,
    ROUND(AVG(avg_wages)) AS avg_wages_CZK,
    LAG(ROUND(AVG(avg_wages))) OVER (PARTITION BY industry_branch ORDER BY payroll_year) AS prev_year_wages
FROM t_yegor_gladush_project_SQL_primary_final
GROUP BY industry_branch, payroll_year;

-- Výběr dat z pohledu a přidání výpočtů
SELECT
    industry_branch,
    payroll_year,
    avg_wages_CZK,
    prev_year_wages,
    CASE
        WHEN avg_wages_CZK < prev_year_wages THEN 'Pokles'
        ELSE 'Růst nebo stagnace'
    END AS trend,
    ROUND(avg_wages_CZK * 100.0 / prev_year_wages - 100, 2) AS wages_difference_percentage
FROM v_yegor_gladush_project_wages_trend
WHERE prev_year_wages IS NOT NULL
ORDER BY industry_branch, payroll_year;




-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
-- Výpočet kupní síly na základě cen mléka a chleba
CREATE OR REPLACE VIEW v_yegor_gladush_project_purchase_power AS
SELECT
    industry_branch,
    payroll_year,
    AVG(avg_wages) AS avg_wage,
    MAX(CASE WHEN food_category = 'Mléko polotučné pasterované' THEN price END) AS milk_price,
    MAX(CASE WHEN food_category = 'Chléb konzumní kmínový' THEN price END) AS bread_price
FROM t_yegor_gladush_project_SQL_primary_final
WHERE payroll_year IN (2006, 2018)
    AND food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
GROUP BY industry_branch, payroll_year;

-- Výběr dat z VIEW a přidání výpočtů
SELECT
    industry_branch,
    payroll_year,
    avg_wage,
    milk_price,
    bread_price,
    ROUND(avg_wage / milk_price) AS nakoupit_l_mleka,
    ROUND(avg_wage / bread_price) AS nakoupit_kg_chleba
FROM v_yegor_gladush_project_purchase_power
ORDER BY industry_branch, payroll_year;




-- 3. Která kategorie potravin zdražuje nejpomaleji?
-- Výpočet průměrného ročního růstu cen potravin podle kategorií
SELECT
    older_year AS year_from,
    MAX(newer_year) AS year_to,
    food_category,
    ROUND(AVG(price_diff_percentage), 2) AS avg_annual_price_growth_in_percentage
FROM v_yegor_gladush_project_food_price_trend
GROUP BY food_category
ORDER BY avg_annual_price_growth_in_percentage;




-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd?
-- Výpočet rozdílu růstu cen a mezd
CREATE OR REPLACE VIEW v_yegor_gladush_project_price_salary_comparison AS
WITH YearlyAverages AS (
    SELECT payroll_year, AVG(price) AS avg_price_year, AVG(avg_wages) AS avg_wages_year
    FROM t_yegor_gladush_project_SQL_primary_final
    WHERE price IS NOT NULL AND avg_wages IS NOT NULL
    GROUP BY payroll_year
),
PreviousYearAverages AS (
    SELECT payroll_year + 1 AS prev_year, AVG(price) AS avg_price_prev_year, AVG(avg_wages) AS avg_wages_prev_year
    FROM t_yegor_gladush_project_SQL_primary_final
    WHERE price IS NOT NULL AND avg_wages IS NOT NULL
    GROUP BY prev_year
)
SELECT
    y.payroll_year,
    p.prev_year,
    ROUND((y.avg_price_year - p.avg_price_prev_year) / y.avg_price_year * 100, 2) AS price_grow_percent,
    ROUND((y.avg_wages_year - p.avg_wages_prev_year) / y.avg_wages_year * 100, 2) AS wages_grow_percent,
    CASE
        WHEN (y.avg_price_year - p.avg_price_prev_year) / y.avg_price_year * 100 - (y.avg_wages_year - p.avg_wages_prev_year) / y.avg_wages_year * 100 > 10 THEN 'nad 10'
        ELSE 'pod 10'
    END AS růst
FROM YearlyAverages y
JOIN PreviousYearAverages p ON y.payroll_year = p.prev_year;

SELECT * FROM v_yegor_gladush_project_price_salary_comparison;




-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?
-- Pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

-- Vytvoření VIEW pro výpočet růstu mezd podle kategorií produktů
-- VIEW pro průměrnou roční mzdu s předchozím rokem
CREATE OR REPLACE VIEW v_yg_avg_wages_yearly AS
SELECT
    payroll_year,
    AVG(avg_wages) AS avg_wages_year,
    LAG(AVG(avg_wages)) OVER (ORDER BY payroll_year) AS avg_wages_prev_year
FROM
    t_yegor_gladush_project_SQL_primary_final
WHERE
    avg_wages IS NOT NULL
GROUP BY
    payroll_year;

-- VIEW pro průměrnou roční cenu produktů s předchozím rokem
CREATE OR REPLACE VIEW v_yg_avg_price_yearly AS
SELECT
    payroll_year,
    AVG(price) AS avg_price_year,
    LAG(AVG(price)) OVER (ORDER BY payroll_year) AS avg_price_prev_year
FROM
    t_yegor_gladush_project_SQL_primary_final
WHERE
    price IS NOT NULL
GROUP BY
    payroll_year;

-- VIEW pro průměrné roční HDP s předchozím rokem
CREATE OR REPLACE VIEW v_yg_avg_gdp_yearly AS
SELECT
    `year` AS payroll_year, -- Předpokládáme, že YEAR odpovídá payroll_year
    AVG(GDP) AS avg_gdp_year,
    LAG(AVG(GDP)) OVER (ORDER BY `year`) AS avg_gdp_prev_year
FROM
    t_yegor_gladush_project_SQL_secondary_final
WHERE
    GDP IS NOT NULL AND country = 'Czech Republic'
GROUP BY
    `year`;

-- Spojení VIEW pro analýzu
SELECT
    w.payroll_year,
    ROUND((p.avg_price_year - p.avg_price_prev_year) / p.avg_price_prev_year * 100, 2) AS price_growth_percent,
    ROUND((w.avg_wages_year - w.avg_wages_prev_year) / w.avg_wages_prev_year * 100, 2) AS wages_growth_percent,
    ROUND(
        ROUND((p.avg_price_year - p.avg_price_prev_year) / p.avg_price_prev_year * 100, 2) -
        ROUND((w.avg_wages_year - w.avg_wages_prev_year) / w.avg_wages_prev_year * 100, 2),
        2
    ) AS difference_price_and_salary_percent,
    ROUND((g.avg_gdp_year - g.avg_gdp_prev_year) / g.avg_gdp_prev_year * 100, 2) AS gdp_growth_percent
FROM
    v_yg_avg_wages_yearly w
JOIN
    v_yg_avg_price_yearly p ON w.payroll_year = p.payroll_year
JOIN
    v_yg_avg_gdp_yearly g ON w.payroll_year = g.payroll_year
WHERE
    p.avg_price_prev_year IS NOT NULL AND w.avg_wages_prev_year IS NOT NULL AND g.avg_gdp_prev_year IS NOT NULL
ORDER BY
    w.payroll_year;