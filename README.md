# Projekt ENGETO - datová analýza


 


----

## Zadání projektu


Na analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jsme se dohodli, že se pokusíme odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Úkolem je připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

K projektu jsou použity datové sady z Portálu otevřených dat ČR.

---
## Výzkumné otázky

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

## Výstup projektu
Pomozte kolegům s daným úkolem. Výstupem by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. Tabulky pojmenujte t_{jmeno}_{prijmeni}_project_SQL_primary_final (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a t_{jmeno}_{prijmeni}_project_SQL_secondary_final (pro dodatečná data o dalších evropských státech).

## 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
V letech 2006 až 2018 průměrně rostly mzdy ve všech odvětvích o 3,9 procenta, což naznačuje celkově pozitivní trend na trhu práce. Nicméně, detailnější pohled odhaluje značné rozdíly v dynamice mezd mezi jednotlivými sektory.

Nejrychleji rostly mzdy ve zdravotnictví a sociální péči, zemědělství, lesnictví a rybářství a zpracovatelském průmyslu.

Naopak, nejpomalejší růst mezd zaznamenaly peněžnictví a pojišťovnictví, ostatní činnosti a administrativní a podpůrné činnosti.  V případě Peněžnictví a pojišťovnictví je pozoruhodný zejména výrazný propad mezd v roce 2013 o 8,9 procenta. Tento pokles by mohl souviset s ekonomickou krizí v daném období.

## 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
- 1416 l mléka v roce 2006
- 1594 l mléka v roce 2018
- 1165 kg chleba v roce 2006
- 1309 kg chleba v roce 2018

V roce 2006 si průměrný pracovník v Česku mohl dovolit koupit 1416 litrů mléka. Nejvyšší kupní sílu v oblasti mléka měli zaměstnanci v odvětví Peněžnictví a pojišťovnictví, kteří si mohli pořídit 2707 litrů. Naopak nejméně mléka si mohl dovolit pracovník v Ubytování, stravování a pohostinství, a to 777 litrů. Rozdíl mezi těmito dvěma odvětvími činil 1930 litrů mléka.

V roce 2018 se průměrná kupní síla v oblasti mléka zvýšila na 1594 litrů. Nejvíce mléka si mohli dopřát zaměstnanci v Informačních a komunikačních činnostech, a to 2747 litrů. Nejnižší kupní sílu v oblasti mléka si udrželi pracovníci v Ubytování, stravování a pohostinství, kteří si mohli koupit 919 litrů. Rozdíl mezi nejvyšší a nejnižší kupní silou se snížil na 1828 litrů mléka.

V roce 2006 si průměrný pracovník v Česku mohl dovolit koupit 1165 kilogramů chleba. Nejvyšší kupní sílu v oblasti chleba měli zaměstnanci v odvětví Peněžnictví a pojišťovnictví, kteří si mohli pořídit 2229 kilogramů. Naopak nejméně chleba si mohl dovolit pracovník v Ubytování, stravování a pohostinství, a to 640 kilogramů. Rozdíl mezi těmito dvěma odvětvími činil 1589 kilogramů chleba.

V roce 2018 se průměrná kupní síla v oblasti chleba zvýšila na 1309 kilogramů. Nejvíce chleba si mohli dopřát zaměstnanci v Informačních a komunikačních činnostech, a to 2257 kilogramů. Nejnižší kupní sílu v oblasti chleba si udrželi pracovníci v Ubytování, stravování a pohostinství, kteří si mohli koupit 755 kilogramů. Rozdíl mezi nejvyšší a nejnižší kupní silou se snížil na 1502 kilogramů chleba.

## 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
Kategorií potravin, která vykazuje nejnižší procentuální meziroční nárůst ceny je curk krystalový. 

## 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
Na základě provedené analýzy neexistuje žádný rok, ve sledovaném období, kdy by průměrný meziroční nárůst cen potravin byl o více než 10 procentních bodů vyšší než průměrný meziroční nárůst mezd. Ve všech srovnatelných letech byl nárůst cen potravin v porovnání s nárůstem mezd nižší než tato hranice.

## 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
Rok 2007 (vysoký růst HDP): Růst HDP byl v roce 2007 nejvyšší (5,57%). V následujícím roce (2008) byl zaznamenán největší nárůst mezd (7,87%) a také poměrně vysoký nárůst cen potravin (6,41%). To by mohlo naznačovat určitou souvislost, kdy vysoký ekonomický růst předchází růstu mezd a následně i cen.

Rok 2016 (růst HDP): Růst HDP v roce 2016 byl 2,54%, což není extrémně vysoká hodnota, ale stále se jedná o růst. V následujícím roce (2017) byl zaznamenán největší nárůst cen potravin (9,98%). Zde by se mohla projevit zpožděná reakce cen na ekonomický růst.

Závěr:

Vysoký růst HDP v roce 2007 mohl přispět k růstu mezd v následujícím roce a následně i k růstu cen potravin.
Růst HDP v roce 2016 mohl s určitým zpožděním ovlivnit výrazný nárůst cen potravin v roce 2017.
