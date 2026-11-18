USE transactions

-- Exercici 2

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


-- Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
WITH german_companies AS (
    SELECT id
    FROM company
    WHERE country LIKE 'Germany'
)
SELECT *
FROM transaction
WHERE company_id IN (SELECT 1 FROM german_companies);




-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

WITH trasnactions_avg AS (
    SELECT 
        company_id
    FROM transaction
    WHERE amount > (SELECT AVG(amount) FROM transaction))
SELECT *
FROM company AS c
WHERE EXISTS (SELECT 1 FROM trasnactions_avg AS t WHERE t.company_id = c.id);


-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT *
FROM company AS c
WHERE NOT EXISTS (SELECT 1 FROM transaction AS t WHERE c.id = t.company_id)

