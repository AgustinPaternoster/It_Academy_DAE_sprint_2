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
SELECT company_name
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

CREATE TABLE credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(40),
    pan VARCHAR (20),
    pin VARCHAR (4),
    cvv VARCHAR (3),
    expiring_date VARCHAR (10),
    CONSTRAINT chk_pin CHECK (pin REGEXP '^[0-9]{4}'),
    CONSTRAINT chk_cvv CHECK (cvv REGEXP '^[0-9]{3}') 
)

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
-- Id :108B1D1D-5B23-A76C-55EF-C568E49A99DD 
-- credit_card_id :CcU-9999 
-- company_id : b-9999 
-- user_id :9999 
-- lat :829.999 
-- longitude : -117.999 
-- amount :111.11 
-- declined : 0 
        
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

describe credit_card;

-- Ejercicio 8
-- Crear tablas de dimensiones y hechos
CREATE DATABASE new_transactions;
USE new_transactions;

CREATE TABLE IF NOT EXISTS tmp_transactions (
    id VARCHAR(36) NOT NULL,
    card_id VARCHAR(15),
    business_id VARCHAR(15),
    `timestamp` DATETIME,
    amount DECIMAL(10,2),
    declined TINYINT(1),
    product_ids VARCHAR(255),
    user_id INT,
    lat FLOAT,
    longitude FLOAT,
    discount_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    channel VARCHAR(20),
    campaign_id VARCHAR(30),
    device_type VARCHAR(20),
    is_international TINYINT(1),
    decline_reason VARCHAR(50),
    distance_km DECIMAL(10,2),
    PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS tmp_company (
    company_id VARCHAR(15) NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    phone VARCHAR(25),
    email VARCHAR(150),
    country VARCHAR(100),
    website VARCHAR(255),
    merchant_category VARCHAR(50),
    merchant_price_position VARCHAR(20),
    PRIMARY KEY (company_id)
);

CREATE TABLE IF NOT EXISTS tmp_credit_card (
    id VARCHAR(15) NOT NULL,
    user_id INT,
    iban VARCHAR(40),
    pan VARCHAR(25),
    pin VARCHAR(4),
    cvv VARCHAR(4),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(10),
    card_type VARCHAR(20),
    card_renewal_flag TINYINT(1),
    PRIMARY KEY (id)
);

USE new_transactions;
CREATE TABLE IF NOT EXISTS tmp_european_users (
    id INT NOT NULL,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(150),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(30),
    income_band VARCHAR(20),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS tmp_american_users (
    id INT NOT NULL,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(150),
    birth_date DATE,
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(30),
    income_band VARCHAR(20),
    PRIMARY KEY (id)
);

-- IMPORTACION DE archivos CSV
LOAD DATA INFILE '/app/files/N1-Ex.8__transactions.csv'
IGNORE
INTO TABLE tmp_transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, card_id, business_id, `timestamp`, amount, declined, product_ids, user_id,
 lat, longitude, discount_amount, tax_amount, shipping_amount, channel,
 campaign_id, device_type, is_international, @decline_reason, distance_km)
SET decline_reason = NULLIF(@decline_reason, '');

LOAD DATA INFILE '/app/files/N1-Ex.8__companies.csv'
IGNORE
INTO TABLE tmp_company
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(company_id, company_name, phone, email, country, website,
 merchant_category, merchant_price_position);

LOAD DATA INFILE '/app/files/N1-Ex.8__credit_cards.csv'
IGNORE
INTO TABLE tmp_credit_card
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date,
 card_type, card_renewal_flag);

LOAD DATA INFILE '/app/files/N1-Ex.8__european_users.csv'
IGNORE
INTO TABLE tmp_european_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code,
 address, signup_date, user_segment, income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

LOAD DATA INFILE '/app/files/N1-Ex.8__american_users.csv'
IGNORE
INTO TABLE tmp_american_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, @birth_date, country, city, postal_code,
 address, signup_date, user_segment, income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

-- 4) Comprobación: deben ser 1010 filas

use new_transactions;

CREATE TABLE dim_users (
    id INT NOT NULL,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(150),
    birth_date DATE,
    region VARCHAR(20),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(30),
    income_band VARCHAR(20),
    
    PRIMARY KEY (Id)
);

CREATE TABLE dim_company (
    company_id VARCHAR(15) NOT NULL,
    company_name VARCHAR(255),
    phone VARCHAR(25),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255),
    merchant_category VARCHAR(50),
    merchant_price_position VARCHAR(20),
    
    PRIMARY KEY (company_id)
);

CREATE TABLE dim_credit_card (
    id VARCHAR(15) NOT NULL,
    iban VARCHAR(40),
    pan VARCHAR(25),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(10),
    card_type VARCHAR(20),
    card_renewal_flag BOOLEAN,
    
    PRIMARY KEY (id)
);

CREATE TABLE fact_transactions (
    id VARCHAR(36) NOT NULL,
    company_id VARCHAR(15),
    card_id VARCHAR(15),
    user_id INT,
    `timestamp` TIMESTAMP,
    amount DECIMAL(10,2),
    declined BOOLEAN,
    product_ids VARCHAR(255),
    lat FLOAT,
    longitude FLOAT,
    discount_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    channel VARCHAR(20),
    campaign_id VARCHAR(30),
    device_type VARCHAR(20),
    is_international BOOLEAN,
    decline_reason VARCHAR(50),
    distance_km DECIMAL(10,2),
    
    PRIMARY KEY (id),
    FOREIGN KEY (company_id) REFERENCES dim_company(company_id),
    FOREIGN KEY (card_id) REFERENCES dim_credit_card(id),
    FOREIGN KEY (user_id) REFERENCES dim_users(id)
);

-- Carga de datos en tablas dim y fact

INSERT INTO dim_company (company_id,company_name,phone,email,country,website,merchant_category,merchant_price_position)
SELECT company_id,company_name,phone,email,country,website,merchant_category,merchant_price_position
FROM tmp_company;

INSERT INTO dim_credit_card (
    id, 
    iban, 
    pan, 
    pin, 
    cvv, 
    track1, 
    track2, 
    expiring_date,
    card_type,
    card_renewal_flag)
SELECT 
    id,
    iban,
    pan, 
    pin,
    cvv,
    track1,
    track2,
    expiring_date,
    card_type,
    card_renewal_flag
FROM tmp_credit_card

INSERT INTO dim_users (
    id ,
    name ,
    surname ,
    phone ,
    email ,
    birth_date ,
    region ,
    country ,
    city ,
    postal_code ,
    address ,
    signup_date ,
    user_segment ,
    income_band
    )
SELECT id, name, surname, phone, email,birth_date, "american" AS region, country,city,postal_code,address,signup_date,user_segment,income_band
FROM tmp_american_users
UNION
SELECT id, name, surname, phone, email,birth_date, 'european' AS region, country,city,postal_code,address,signup_date,user_segment,income_band
FROM tmp_european_users

INSERT INTO fact_transactions (
    id,
    company_id ,
    card_id ,
    user_id ,
    `timestamp` ,
    amount ,
    declined ,
    product_ids ,
    lat ,
    longitude ,
    discount_amount ,
    tax_amount ,
    shipping_amount ,
    channel ,
    campaign_id ,
    device_type ,
    is_international ,
    decline_reason ,
    distance_km
)
SELECT f.id, f.business_id, f.card_id, f.user_id, f.timestamp, f.amount, f.declined,
    f.product_ids, f.lat, f.longitude, f.discount_amount, f.tax_amount, f.shipping_amount,
    f.channel, f.campaign_id, f.decline_reason, f.is_international, f.decline_reason, f.distance_km
FROM tmp_transactions AS f;

-- Exercici 9
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions 
-- utilitzant almenys 2 taules.

WITH transctions_nb AS (
    SELECT 
        u.* , 
        COUNT(*) as total_trans
    FROM dim_users AS u
    INNER JOIN fact_transactions AS t
    ON t.user_id = u.id
    GROUP BY u.id)
SELECT *
FROM transctions_nb
WHERE total_trans > 80

-- Exercici 10
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

WITH iban AS (
    SELECT c.iban, 
        b.company_name ,
        t.amount   
    FROM dim_credit_card AS c
    INNER JOIN fact_transactions AS t
    ON c.id = t.card_id
    INNER JOIN dim_company AS b
    ON t.company_id = b.company_id
    WHERE b.company_name LIKE 'Donec Ltd')
SELECT  iban, AVG(amount) AS amount_avg
FROM iban
GROUP BY iban;


