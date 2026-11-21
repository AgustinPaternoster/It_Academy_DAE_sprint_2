USE transactions;

Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per 
-- vendes. Mostra la data de cada transacció juntament amb el total de les vendes.


WITH ranking_ventas AS (SELECT DATE(t.timestamp) AS fecha, 
    SUM(t.amount) ventas_totales,
    RANK () OVER(ORDER BY SUM(t.amount) DESC) AS ranking
FROM fact_transactions AS t
GROUP BY DATE(t.timestamp))
SELECT fecha, ventas_totales
FROM ranking_ventas
WHERE ranking < 6

-- Exercici 2
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van 
-- realitzar transaccions amb un valor comprès entre 350 i 400 euros i en alguna 
-- d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
-- Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone, c.country , DATE(t.timestamp) , t.amount
FROM dim_company AS c
INNER JOIN fact_transactions AS t
ON c.company_id = t.company_id
WHERE (t.amount BETWEEN 350 AND 400) AND (DATE(t.timestamp) IN ('2015-04-29', '2018-7-20','2024-3-13')) 

-- Exercici 3
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es 
-- requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que 
-- realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de 
-- les empreses on especifiquis si tenen igual o més de 400 transaccions o menys.

WITH transactions_nb AS (
    SELECT 
        c.company_id , 
        COUNT(t.id) AS total_transacciones
    FROM dim_company AS c
    INNER JOIN fact_transactions AS t
    ON c.company_id = t.company_id
    GROUP BY c.company_id)
SELECT c.company_id ,  c.company_name , c.country,
    CASE
        WHEN t.total_transacciones < 400 THEN 'Menos 400'
        WHEN t.total_transacciones > 400 THEN 'Mas 400'
        WHEN t.total_transacciones = 400 THEN 'igual 400'
    END AS transacciones_nb
        
FROM dim_company AS c
INNER JOIN transactions_nb AS t
ON c.company_id = t.company_id

-- Exercici 4
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de
--  la base de dades.
SELECT *
FROM fact_transactions
WHERE id LIKE '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'

DELETE FROM fact_transactions
WHERE id LIKE '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD'

-- Exercici 5
-- La sección de marketing desea tener acceso a información específica para realizar
-- análisis y estrategias efectivas. Se ha solicitado crear una vista que proporcione 
-- detalles clave sobre las compañías y sus transacciones. Será necesaria que crees una
-- vista llamada VistaMarketing que contenga la siguiente información: Nombre de la compañía
-- . Teléfono de contacto. País de residencia. Media de compra realizado por cada compañía. 
-- Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.

CREATE VIEW vistamarketing AS
WITH company_data AS ( 
    SELECT c.company_name, 
    c.phone, 
    c.country,
    AVG(t.amount) OVER (PARTITION BY c.company_id) AS sales_avg
    FROM dim_company AS c
    INNER JOIN fact_transactions AS t
    ON t.company_id = c.company_id)
SELECT DISTINCT company_name, phone, country, ROUND(sales_avg,2) AS sales_avg
FROM company_data
ORDER BY sales_avg DESC