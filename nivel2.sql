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

describe fact_transactions
