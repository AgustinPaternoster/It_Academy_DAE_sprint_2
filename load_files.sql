-- Carga de products.csv en MySQL (contenedor "mysql")
-- El directorio ./files está montado como volumen en /app/files dentro del contenedor.
-- Requiere que el servicio mysql arranque con --secure-file-priv="" (ver docker-compose.yml).
USE transactions;

-- 1) Estructura de la tabla
CREATE TABLE IF NOT EXISTS products (
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

-- 2) Cargar el CSV directamente desde el volumen.
--    price y cost vienen con '$', se limpian con SET + REPLACE.
LOAD DATA INFILE '/app/files/N1-Ex.8__products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @price, colour, weight, warehouse_id, category, brand, @cost, launch_date)
SET price = REPLACE(@price, '$', ''),
    cost  = REPLACE(@cost,  '$', '');

-- 3) Comprobación
SELECT COUNT(*) AS total_products FROM products;
