USE transactions

-- Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:
-- Des de quants països es generen les vendes.
-- Identifica la companyia amb la mitjana més gran de vendes.

-- Llistat dels països que estan generant vendes.
SELECT c.country , COUNT(t.id) AS transactions_count
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
GROUP BY c.country
ORDER BY transactions_count

-- Des de quants països es generen les vendes.
SELECT c.country , DATE(min(t.timestamp)) AS first_transtaction
FROM company AS c
INNER JOIN transaction AS t
ON c.id = t.company_id
GROUP BY c.country

-- Identifica la companyia amb la mitjana més gran de vendes.
WITH sales_AVG AS (
    SELECT c.company_name , 
        RANK() OVER (ORDER BY AVG(t.amount) DESC) AS ranking
    FROM company AS c
    INNER JOIN transaction AS t
    ON c.id = t.company_id
    GROUP BY c.company_name
)
SELECT comany_name
FROM `sales_AVG`
WHERE ranking = 1
