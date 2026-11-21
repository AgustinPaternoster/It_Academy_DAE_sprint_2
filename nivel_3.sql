USE transactions;
-- Exercici 1
-- Ejercicio 1
-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres últimas 
-- transacciones han sido declinadas entonces es inactivo, si 
-- al menos una no es rechazada entonces es activo. Partiendo de esta tabla responde:
-- 👉 ¿Cuántas tarjetas están activas?


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
    ON c.id = t.card_id),
last_trans AS (
    SELECT id_card , 
    IF (SUM(declined) = 3, 'inactiva', 'activa') AS estado
    FROM transacciones AS t1
    WHERE t1.ranking < 4
    GROUP BY t1.id_card
)
SELECT estado , COUNT(*) AS total_tarjetas
FROM last_trans
GROUP BY estado


-- Ejercicio 2
-- Crea una tabla con la que podamos unir los datos del archivo de products.csv 
-- con la base de datos creada (ya que hasta ahora no podíamos hacerlo), 
-- teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:
-- 👉 Necesitamos conocer el número de veces que se ha vendido cada producto.
USE transactions;
CREATE TABLE dim_products (
    id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    colour VARCHAR(30),
    weight FLOAT,
    warehouse_id VARCHAR(10),
    category VARCHAR(50),
    brand VARCHAR(100),
    cost DECIMAL(10,2),
    launch_date DATE
);

USE transactions;
CREATE TABLE fact_detail_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_product INT,
    company_id VARCHAR(15),
    user_id INT,
    quantity INT,
    id_transaction VARCHAR(36),
    `timestamp` DATETIME,

    FOREIGN KEY(id_product) REFERENCES dim_products(id),
    FOREIGN KEY(company_id) REFERENCES dim_company(company_id),
    FOREIGN KEY(user_id) REFERENCES dim_users(id)
);


INSERT INTO dim_products (id, product_name, price, colour, weight, warehouse_id, category, brand, cost, launch_date)
SELECT id, product_name, price, colour, weight, warehouse_id, category, brand, cost, launch_date
FROM products

describe fact_detail_transactions;
describe fact_transactions;
INSERT INTO fact_detail_transactions (id_product, company_id, user_id, quantity, id_transaction, timestamp)
SELECT jt.id_product, company_id, user_id, 1 AS quantity, id, timestamp
FROM fact_transactions AS t
JOIN JSON_TABLE( CONCAT('[', TRIM(BOTH  ',' FROM t.product_ids),']') , '$[*]' COLUMNS(id_product INT PATH '$' )
) AS jt;


WITH sales_products AS (
    SELECT 
        t.id_product, 
        p.product_name, 
        p.price,
        SUM(t.quantity) OVER (PARTITION BY t.id_product) AS total_sales
    FROM fact_detail_transactions AS t  
    INNER JOIN dim_products AS p 
    ON t.id_product = p.id)
SELECT DISTINCT *
FROM sales_products;
