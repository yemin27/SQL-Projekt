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
ORDER BY c.`country`, e.`year`;

-- Kontrola doplňkové tabulky
SELECT * FROM t_yegor_gladush_project_SQL_secondary_final;

-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
-- Создаем представление для вычисления тренда зарплат
CREATE OR REPLACE VIEW v_yegor_gladush_project_wages_trend AS
SELECT
    industry_branch,
    payroll_year,
    ROUND(AVG(avg_wages)) AS avg_wages_CZK,
    LAG(ROUND(AVG(avg_wages))) OVER (PARTITION BY industry_branch ORDER BY payroll_year) AS prev_year_wages
FROM
    t_yegor_gladush_project_SQL_primary_final
GROUP BY
    industry_branch, payroll_year;

-- Выбираем данные из представления и добавляем расчеты
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
FROM
    v_yegor_gladush_project_wages_trend
WHERE prev_year_wages IS NOT NULL
ORDER BY
    industry_branch, payroll_year;

-- 1.1 Výpočet průměrného růstu mezd dle odvětví mezi roky 2006 - 2018
CREATE OR REPLACE VIEW v_yegor_gladush_project_wages_trend AS
SELECT
    industry_branch,
    payroll_year,
    ROUND(AVG(avg_wages)) AS avg_wages_CZK,
    LAG(ROUND(AVG(avg_wages))) OVER (PARTITION BY industry_branch ORDER BY payroll_year) AS prev_year_wages
FROM
    t_yegor_gladush_project_SQL_primary_final
GROUP BY
    industry_branch, payroll_year;

-- Выбираем данные из представления и добавляем расчеты
SELECT
    industry_branch,
    AVG(ROUND(v.avg_wages_CZK * 100.0 / v.prev_year_wages - 100, 2)) AS avg_wages_difference_percentage
FROM
    v_yegor_gladush_project_wages_trend v
WHERE v.prev_year_wages IS NOT NULL
GROUP BY industry_branch
ORDER BY avg_wages_difference_percentage DESC;


-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- Výpočet kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období (dle odvětví)
CREATE OR REPLACE VIEW v_yegor_gladush_project_purchase_power AS
SELECT
    industry_branch,
    payroll_year,
    AVG(avg_wages) AS avg_wage,
    MAX(CASE WHEN food_category = 'Mléko polotučné pasterované' THEN price END) AS milk_price,
    MAX(CASE WHEN food_category = 'Chléb konzumní kmínový' THEN price END) AS bread_price
FROM
    t_yegor_gladush_project_sql_primary_final
WHERE
    payroll_year IN (2006, 2018)
    AND food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
GROUP BY
    industry_branch, payroll_year;

-- Выбираем данные из представления и добавляем расчеты
SELECT
    industry_branch,
    payroll_year,
    avg_wage,
    milk_price,
    bread_price,
    ROUND(avg_wage / milk_price) AS nakoupit_l_mleka,
    ROUND(avg_wage / bread_price) AS nakoupit_kg_chleba
FROM
    v_yegor_gladush_project_purchase_power
ORDER BY
    industry_branch, payroll_year;

-- 3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- Průměrný roční růst cen podle kategorií
SELECT
    older_year AS year_from,
    MAX(newer_year) AS year_to,
    food_category,
    ROUND(AVG(price_diff_percentage), 2) AS avg_annual_price_growth_in_percentage
FROM v_yegor_gladush_project_food_price_trend
GROUP BY food_category
ORDER BY avg_annual_price_growth_in_percentage;

-- Trend růstu cen potravin a porovnání
CREATE OR REPLACE VIEW v_yegor_gladush_project_avg_food_price_by_year AS
SELECT
    food_category,
    price_value AS value,
    price_unit AS unit,
    payroll_year AS year,
    ROUND(AVG(price), 2) AS avg_price
FROM
    t_yegor_gladush_project_SQL_primary_final
GROUP BY
    food_category, payroll_year;

CREATE OR REPLACE VIEW v_yegor_gladush_project_food_price_trend AS
SELECT
    older.food_category,
    older.value,
    older.unit,
    older.year AS older_year,
    older.avg_price AS older_price,
    newer.year AS newer_year,
    newer.avg_price - older.avg_price AS price_difference_czk,
    ROUND((newer.avg_price - older.avg_price) / older.avg_price * 100, 2) AS price_diff_percentage,
    CASE
        WHEN newer.avg_price > older.avg_price THEN 'Nárůst'
        ELSE 'Pokles'
    END AS price_trend
FROM
    v_yegor_gladush_project_avg_food_price_by_year older
JOIN
    v_yegor_gladush_project_avg_food_price_by_year newer ON older.food_category = newer.food_category AND newer.year = older.year + 1
ORDER BY
    older.food_category, older.year;

SELECT * FROM v_yegor_gladush_project_food_price_trend;


-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- Создаем представление для расчета роста зарплат
CREATE OR REPLACE VIEW v_yegor_gladush_project_salary_growth AS
SELECT
    payroll_year,
    ROUND(
        (AVG(avg_wages) - LAG(AVG(avg_wages)) OVER (ORDER BY payroll_year)) /
        LAG(AVG(avg_wages)) OVER (ORDER BY payroll_year) * 100,
        2
    ) AS salary_growth
FROM
    t_yegor_gladush_project_sql_primary_final
GROUP BY
    payroll_year;

-- Создаем представление для расчета роста цен продуктов
CREATE OR REPLACE VIEW v_yegor_gladush_project_price_growth AS
SELECT
    payroll_year,
    ROUND(
        (AVG(price) - LAG(AVG(price)) OVER (PARTITION BY food_category ORDER BY payroll_year)) /
        LAG(AVG(price)) OVER (PARTITION BY food_category ORDER BY payroll_year) * 100,
        2
    ) AS price_growth,
    food_category
FROM
    t_yegor_gladush_project_sql_primary_final
GROUP BY
    payroll_year, food_category;

-- Выбираем данные из представлений и добавляем расчеты
SELECT
    pg.payroll_year,
    pg.food_category,
    pg.price_growth,
    sg.salary_growth,
    sg.salary_growth - pg.price_growth AS difference
FROM
    v_yegor_gladush_project_price_growth pg
JOIN
    v_yegor_gladush_project_salary_growth sg ON pg.payroll_year = sg.payroll_year
ORDER BY
    difference DESC;


-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
-- Создаем представление для расчета роста зарплат по категориям продуктов
CREATE OR REPLACE VIEW v_yegor_gladush_project_wages_growth_by_category AS
SELECT
    payroll_year,
    food_category,
    AVG(avg_wages) AS avg_wages,
    LAG(AVG(avg_wages)) OVER (PARTITION BY food_category ORDER BY payroll_year) AS prev_avg_wages
FROM
    t_yegor_gladush_project_sql_primary_final
GROUP BY
    payroll_year, food_category;

-- Создаем представление для расчета роста цен по категориям продуктов
CREATE OR REPLACE VIEW v_yegor_gladush_project_price_growth_by_category AS
SELECT
    food_category,
    payroll_year,
    AVG(price) AS avg_price,
    LAG(AVG(price)) OVER (PARTITION BY food_category ORDER BY payroll_year) AS prev_avg_price
FROM
    t_yegor_gladush_project_sql_primary_final
GROUP BY
    payroll_year, food_category;

-- Создаем представление для расчета изменений ВВП
CREATE OR REPLACE VIEW v_yegor_gladush_project_gdp_change AS
SELECT
    `year`,
    country,
    GDP,
    LAG(GDP) OVER (ORDER BY `year`) AS prev_GDP,
    LEAD(GDP) OVER (ORDER BY `year`) AS next_year_GDP
FROM
    t_yegor_gladush_project_sql_secondary_final
WHERE
    country = 'Czech Republic';

-- Выбираем данные из представлений и добавляем расчеты
SELECT
    w.payroll_year,
    'Czech Republic' AS country,
    w.food_category,
    ROUND((p.avg_price - p.prev_avg_price) / p.prev_avg_price * 100, 2) AS price_growth,
    ROUND((w.avg_wages - w.prev_avg_wages) / w.prev_avg_wages * 100, 2) AS salary_growth,
    ROUND(
        ROUND((w.avg_wages - w.prev_avg_wages) / w.prev_avg_wages * 100, 2) -
        ROUND((p.avg_price - p.prev_avg_price) / p.prev_avg_price * 100, 2),
        2
    ) AS difference_price_and_salary,
    ROUND((g.GDP - g.prev_GDP) / g.prev_GDP * 100, 2) AS change_of_gdp,
    ROUND((g.next_year_GDP - g.GDP) / g.GDP * 100, 2) AS next_year_gdp_change
FROM
    v_yegor_gladush_project_wages_growth_by_category w
JOIN
    v_yegor_gladush_project_price_growth_by_category p ON w.food_category = p.food_category AND w.payroll_year = p.payroll_year
JOIN
    v_yegor_gladush_project_gdp_change g ON w.payroll_year = g.`year`
WHERE
    p.prev_avg_price IS NOT NULL AND w.prev_avg_wages IS NOT NULL AND g.prev_GDP IS NOT NULL
ORDER BY
    w.payroll_year, w.food_category;