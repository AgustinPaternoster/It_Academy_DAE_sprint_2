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

-- 
-- Exercici 4
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres 
-- dues taules ("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document 
-- denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

-- (id, iban, pan, pin, cvv, expiring_dat
-- CcU-2952', 'BG45IVQL52710525608255', '4556 453 55 5287', '4598', '438', '06/29/21'
CREATE TABLE credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(40),
    pan VARCHAR (20),
    pin VARCHAR (4),
    cvv VARCHAR (3),
    expiring_date VARCHAR (10)
)L

-- Exercici 5
-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta
-- de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999
-- . Recorda mostrar que el canvi es va realitzar.
UPDATE credit_card
    SET
        iban = "TR323456312213576817699999"
WHERE id LIKE 'CcU-2938'

-- Exercici 6
-- En la taula "transaction" ingressa una nova transacció amb la següent informació:
Id :108B1D1D-5B23-A76C-55EF-C568E49A99DD 
credit_card_id :CcU-9999 
company_id : b-9999 
user_id :9999 
lat :829.999 
longitude : -117.999 
amount :111.11 
declined : 0 
        
INSERT INTO company VALUES(
 'b-9999',
 'Tester Inc',
 '06 85 56 52 31',
 'tester@tester.com',
 'Germany',
 'www.tester.com'   
)

INSERT INTO transaction 
VALUES(
'108B1D1D-5B23-A76C-55EF-C568E49A99DD ',
'CcU-9999',
'b-9999',
9999,
829.999,
-117.999,
NOW(),
111.11,
0
)


-- Exercici 7
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
ALTER TABLE credit_card
DROP COLUMN pan;


