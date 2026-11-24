USE new_transactions;
-- Exercici 1
-- Ejercicio 1
-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres últimas 
-- transacciones han sido declinadas entonces es inactivo, si 
-- al menos una no es rechazada entonces es activo. Partiendo de esta tabla responde:
-- 👉 ¿Cuántas tarjetas están activas?


CREATE TABLE dim_credit_card_state (
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
    state VARCHAR(20),
    
    PRIMARY KEY (id)
);

INSERT INTO dim_credit_card_state (
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
WITH transacciones AS (
    SELECT 
        c.id AS id_card , 
        t.id AS id_transaction,  
        t.declined , 
        t.timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY c.id
            ORDER BY t.timestamp DESC, t.id DESC) AS ranking
    FROM dim_credit_card AS c
    INNER JOIN fact_transactions AS t
    ON c.id = t.card_id)
SELECT id_card , 
IF (SUM(declined) = 3, 'inactiva', 'activa') AS state
FROM transacciones AS t1
WHERE t1.ranking < 4
GROUP BY t1.id_card


SELECT state , COUNT(*) as total_credit_card
FROM dim_credit_card_state
WHERE state = 'activa'



-- Ejercicio 2
-- Crea una tabla con la que podamos unir los datos del archivo de products.csv 
-- con la base de datos creada (ya que hasta ahora no podíamos hacerlo), 
-- teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:
-- 👉 Necesitamos conocer el número de veces que se ha vendido cada producto.
USE new_transactions;
-- IMPORTACION ARCHIVO CSV

CREATE TABLE IF NOT EXISTS tmp_products (
    id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10, 2),
    colour VARCHAR(7),
    weight DECIMAL(5, 2),
    warehouse_id VARCHAR(10),
    category VARCHAR(50),
    brand VARCHAR(100),
    cost DECIMAL(10, 2),
    launch_date DATE
);

LOAD DATA INFILE '/app/files/N1-Ex.8__products.csv'
IGNORE
INTO TABLE tmp_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @price, colour, weight, warehouse_id, category, brand, @cost, launch_date)
SET price = REPLACE(@price, '$', ''),
    cost  = REPLACE(@cost,  '$', '');


CREATE TABLE dim_products (
    id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    colour VARCHAR(30),
    weight DECIMAL(10,2),
    warehouse_id VARCHAR(10),
    category VARCHAR(50),
    brand VARCHAR(100),
    cost DECIMAL(10,2),
    launch_date DATE
);

CREATE TABLE fact_detail_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_product INT,
    company_id VARCHAR(15),
    user_id INT,
    quantity INT,
    id_transaction VARCHAR(36),
    `timestamp` TIMESTAMP,

    FOREIGN KEY(id_product) REFERENCES dim_products(id),
    FOREIGN KEY(company_id) REFERENCES dim_company(company_id),
    FOREIGN KEY(user_id) REFERENCES dim_users(id)
);

use new_transactions;
INSERT INTO dim_products (id, product_name, price, colour, weight, warehouse_id, category, brand, cost, launch_date)
SELECT id, product_name, price, colour, weight, warehouse_id, category, brand, cost, launch_date
FROM tmp_products


INSERT INTO fact_detail_transactions (id_product, company_id, user_id, quantity, id_transaction, timestamp)
SELECT jt.id_product, company_id, user_id, 1 AS quantity, id, timestamp
FROM fact_transactions AS t
JOIN JSON_TABLE( 
    CONCAT('[', TRIM(BOTH  ',' FROM t.product_ids),']') , 
    '$[*]' COLUMNS(id_product INT PATH '$' )
) AS jt;


WITH sales_products AS (
    SELECT 
        t.id_product, 
        p.product_name, 
        p.price,
        SUM(t.quantity) OVER (PARTITION BY t.id_product) AS total_units_sold
    FROM fact_detail_transactions AS t  
    INNER JOIN dim_products AS p 
    ON t.id_product = p.id)
SELECT DISTINCT *
FROM sales_products;


