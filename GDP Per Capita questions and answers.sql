# create database SalesLoft_Analyst;
use salesloft_analyst;

# ____________________________________________________________________________

# Question 1
# Data Integrity & Cleanup
# Alphabetically list all the country codes in the continent map table that appear more than once. For countries with no country code make them display as "N/A" and display them first in the list.

# answer for error 1175
set sql_safe_updates = 0;

# modificando el datatype de la columna country_code de text (TXT) a string (varchar)
alter table continent_map modify column country_code varchar(255);
alter table continent_map modify column continent_code varchar(255);

#  Replace '' with “N/A”
update continent_map set country_code = if(country_code= '', 'N/A', country_code);

select * from continent_map;
# order by first 'N/A'
select country_code, continent_code
from continent_map
order by field(country_code, 'N/A') DESC;

# ________________________________________________________________________________________________

# Question 2
# List the Top 10 Countries by year over year % GDP per capita growth between 2011 & 2012.

# % year over year growth is defined as (GDP Per Capita in 2012  -  GDP Per Capita in 2011)  /  (GDP Per Capita in 2011)
#The final product should include columns for:
#Rank
#Country Name 
#Country Code 
#Continent
#Growth Percent

# solution to error 1055
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT * FROM per_capita;
# The next code is to do the math operation (GDP Per Capita in 2012  -  GDP Per Capita in 2011)  /  (GDP Per Capita in 2011) for each country
SELECT country_code, (MAX(CASE WHEN year = 2012 THEN gdp_per_capita END) - MAX(CASE WHEN year = 2011 THEN gdp_per_capita END)) / MAX(CASE WHEN year = 2011 THEN gdp_per_capita END) AS Growth_Percent
FROM per_capita
GROUP BY country_code;

# Another way to do it
SELECT
    country_code,
    ((MAX(CASE WHEN year = 2012 THEN gdp_per_capita END) - MAX(CASE WHEN year = 2011 THEN gdp_per_capita END)) / MAX(CASE WHEN year = 2011 THEN gdp_per_capita END)) AS Growth_Percent
FROM
    per_capita
WHERE
    year IN (2011, 2012)
GROUP BY
    country_code;

SELECT per_capita.country_code, per_capita.year, per_capita.gdp_per_capita, countries.country_name, continents.continent_name, continent_map.continent_code
FROM per_capita
JOIN countries ON per_capita.country_code = countries.country_code
JOIN continent_map ON per_capita.country_code = continent_map.country_code
JOIN continents ON continent_map.continent_code = continents.continent_code;


SELECT p.country_code, p.gdp_per_capita, c.country_name, t.continent_name, m.continent_code, 
(MAX(CASE WHEN year = 2012 THEN gdp_per_capita END) - MAX(CASE WHEN year = 2011 THEN p.gdp_per_capita END)) / MAX(CASE WHEN year = 2011 THEN p.gdp_per_capita END) AS Growth_Percent,
RANK() OVER (ORDER BY (MAX(CASE WHEN year = 2012 THEN gdp_per_capita END) - MAX(CASE WHEN year = 2011 THEN p.gdp_per_capita END)) / MAX(CASE WHEN year = 2011 THEN p.gdp_per_capita END) DESC) AS 'Rank'
FROM per_capita p
JOIN countries c ON p.country_code = c.country_code
JOIN continent_map m ON p.country_code = m.country_code
JOIN continents t ON m.continent_code = t.continent_code
GROUP BY country_code
order by Growth_Percent DESC LIMIT 20;

# Growth_Percent express as % form
SELECT p.country_code, p.gdp_per_capita, c.country_name, t.continent_name, m.continent_code, 
(MAX(CASE WHEN year = 2012 THEN gdp_per_capita END) - MAX(CASE WHEN year = 2011 THEN p.gdp_per_capita END)) / MAX(CASE WHEN year = 2011 THEN p.gdp_per_capita END ) * 100 AS Growth_Percent,
RANK() OVER (ORDER BY (MAX(CASE WHEN year = 2012 THEN gdp_per_capita END) - MAX(CASE WHEN year = 2011 THEN p.gdp_per_capita END)) / MAX(CASE WHEN year = 2011 THEN p.gdp_per_capita END) DESC) AS 'Rank'
FROM per_capita p
JOIN countries c ON p.country_code = c.country_code
JOIN continent_map m ON p.country_code = m.country_code
JOIN continents t ON m.continent_code = t.continent_code
GROUP BY country_code
order by Growth_Percent DESC LIMIT 10;

# ____________________________________________________________________________

# Question 3
# For the year 2012, compare the percentage share of GDP Per Capita for the following regions: 
# North America (NA), Europe (EU), and the Rest of the World
#North America
#Europe

# The rest of the world:
# Africa
#Asia
#South America
#Oceania
#Antarctica

SELECT * FROM per_capita;
SELECT * FROM continent_map;
SELECT * FROM continents;
SELECT * FROM countries;

SELECT p.gdp_per_capita, t.continent_name, m.continent_code
FROM per_capita p
JOIN continent_map m ON p.country_code = m.country_code
JOIN continents t ON m.continent_code = t.continent_code;


SELECT 
    ROUND(SUM(CASE WHEN c.continent_name = 'North America' THEN p.gdp_per_capita ELSE 0 END) / SUM(p.gdp_per_capita) * 100, 2) AS 'North America % GDP',
    ROUND(SUM(CASE WHEN c.continent_name = 'Europe' THEN p.gdp_per_capita ELSE 0 END) / SUM(p.gdp_per_capita) * 100, 2) AS 'Europe % GDP',
    ROUND(SUM(CASE WHEN c.continent_name NOT IN ('North America', 'Europe') THEN p.gdp_per_capita ELSE 0 END) / SUM(p.gdp_per_capita) * 100, 5) AS 'Rest of the world % GDP'
FROM per_capita p
JOIN continent_map m ON p.country_code = m.country_code
JOIN continents c ON m.continent_code = c.continent_code
WHERE p.year = 2012;

# ____________________________________________________________________________

# Question 4
# For years 2004 through 2012, calculate the average GDP Per Capita
# for every continent for every year. The average in this case is defined as the Sum of GDP Per Capita
# for All Countries in the Continent / Number of Countries in the Continent
# The final product should include columns for:
# * Year
# * Continent
# * Average GDP Per Capita

SELECT * FROM per_capita;
SELECT * FROM continent_map;
SELECT * FROM continents;
SELECT * FROM countries;

# show all the different years
SELECT DISTINCT year FROM per_capita;

SELECT 
    ROUND(AVG(CASE WHEN c.continent_name = 'North America' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'North America % GDP',
    ROUND(AVG(CASE WHEN c.continent_name = 'Europe' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Europe % GDP',
    ROUND(AVG(CASE WHEN c.continent_name = 'Africa' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Africa % GDP',
    ROUND(AVG(CASE WHEN c.continent_name = 'Asia' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Asia % GDP',
    ROUND(AVG(CASE WHEN c.continent_name = 'South America' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'South America % GDP',
    ROUND(AVG(CASE WHEN c.continent_name = 'Oceania' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Oceania % GDP',
    ROUND(AVG(CASE WHEN c.continent_name = 'Antarctica' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Antarctica % GDP'
FROM per_capita p
JOIN continent_map m ON p.country_code = m.country_code
JOIN continents c ON m.continent_code = c.continent_code
order by p.year;

SELECT p.year, 
ROUND(AVG(CASE WHEN c.continent_name = 'North America' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'North America % GDP', 
ROUND(AVG(CASE WHEN c.continent_name = 'Europe' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Europe % GDP', 
ROUND(AVG(CASE WHEN c.continent_name = 'Africa' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Africa % GDP', 
ROUND(AVG(CASE WHEN c.continent_name = 'Asia' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Asia % GDP', 
ROUND(AVG(CASE WHEN c.continent_name = 'South America' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'South America % GDP', 
ROUND(AVG(CASE WHEN c.continent_name = 'Oceania' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Oceania % GDP', 
ROUND(AVG(CASE WHEN c.continent_name = 'Antarctica' THEN p.gdp_per_capita ELSE 0 END), 2) AS 'Antarctica % GDP' 
FROM per_capita p JOIN continent_map m ON p.country_code = m.country_code 
JOIN continents c ON m.continent_code = c.continent_code
GROUP BY p.year 
ORDER BY p.year ASC;

# Question 5
# For years 2004 through 2012, calculate the median GDP Per Capita for every continent for every year. The median in this case is defined as The value at which half of the samples for a continent are higher and half are lower
# The final product should include columns for:
# * Year
# * Continent
# * Median GDP Per Capita

SELECT pc.year, c.continent_name, 
       (SELECT AVG(pc2.gdp_per_capita) 
        FROM per_capita pc2 
        JOIN continent_map cm2 ON pc2.country_code = cm2.country_code 
        WHERE cm2.continent_code = c.continent_code AND pc2.year = pc.year) AS median_gdp_per_capita
FROM per_capita pc
JOIN continent_map cm ON pc.country_code = cm.country_code
JOIN continents c ON cm.continent_code = c.continent_code
GROUP BY pc.year, c.continent_name;

