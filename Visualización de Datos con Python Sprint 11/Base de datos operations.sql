#Practica del Sprint 4

/*Nivell 1

Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, 
almenys 4 taules de les quals puguis realitzar les següents consultes:*/

/*Antes de empezar a realizar los ejercicios empezamos por Crear la base de datos y luego sus tablas, utilizando los archivos adjuntos dejados en la plataforma.
*/
CREATE DATABASE operations; #Escogemos un nombre que tenga relacion y sentido junto a los datos a utilizar 

USE operations; #Utilizamos el comando USE para seleccionar la base de datos que acabamos de crear y proceder a la creacion de las tablas.

#Al revisar los archivos CSV, hemos notado que hay 2 archivos con informacion sobre usuarios, uno para europa y otro para america, por lo que en vez de crear
# 2 tablas de dimensiones de usuarios, tendremos una que contenga a todos, uniendolas y agregando una columna identificativa del continente llamada region para asi mantener
#la integridad de los datos y no perder la utilidad del continente.
#Se crearan 2 tablas user, una en crudo definida como users_raw y otra definida como users donde se le introduciran los valores limpios luego de transformarlos

CREATE TABLE IF NOT EXISTS `users_raw` (  -- Usaremos esta tabla para introducir los datos del archivo CSV sin transformacion ni limpieza previa
  `id` int DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `surname` varchar(100) DEFAULT NULL,
  `phone` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `birth_date` varchar(50) DEFAULT NULL,    -- Aqui podemos definir la columna birth_date como varchar para transformar y luego pasar a DATE 
  `country` varchar(150) DEFAULT NULL,
  `city` varchar(150) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL
);

#Procedemos a importar e insertar los datos del archivo csv a usars_raw
#primero insertamos el archivo CSV american_users
LOAD DATA LOCAL INFILE 'C:\\Users\\aleja\\Documents\\Analisis de Datos\\Especialidad IT ACADEMY\\Sprint 4 MODELAT SQL\\Archivos adjuntos sprint 4\\american_users.csv'
INTO TABLE `users_raw`
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;

#Despues de ejecutarlo MySQL nos ha arrojado el Error 3948: Loading local data is disabled, por lo que debimos utilizar el comando  SET GLOBAL local_infile para activarlo
SET GLOBAL local_infile = 1;
#Ahora si pudimos ejercutar el LOAD DATA LOCAL INFILE arriba para ingresar los datos


#Se procede a insertar el segundo archivo CSV a la tabla users_raw --> european_users 
LOAD DATA LOCAL INFILE 'C:\\Users\\aleja\\Documents\\Analisis de Datos\\Especialidad IT ACADEMY\\Sprint 4 MODELAT SQL\\Archivos adjuntos sprint 4\\european_users.csv'
INTO TABLE `users_raw`
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;




#Creamos la tablaa users que contendrá la informacion limpia y transformada de users_raw

CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `surname` varchar(100) DEFAULT NULL,
  `phone` varchar(150) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `birth_date` DATE DEFAULT NULL,
  `region` varchar (50) DEFAULT NULL,  #Columna definida para no perder la granularidad de los datos al juntar ambos archivos CSV de users
  `country` varchar(150) DEFAULT NULL,
  `city` varchar(150) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

-- Antes de Hacer la transformacion revisamos la cantidad de paises distintos en la tabla users_raw
SELECT DISTINCT country FROM users_raw;

-- Procedemos a transformar y limpiar los datos de users_raw para insertarlos en la tabla users

INSERT INTO  `users`(id,name,surname,phone,email,birth_date,region,country,city,postal_code,address)
SELECT id,name,surname,phone,email,
STR_TO_DATE(birth_date,'%b %d, %Y'), -- %b significa mes abreviado nov, sep, oct, ...
CASE -- Asignamos el valor de region con un CASE
	WHEN country in ('United States','Canada','Mexico') THEN 'American'
	WHEN country in ('United Kingdom','Spain', 'Netherlands','Sweden','France','Poland','Germany','Italy','Portugal') THEN 'European'
    ELSE 'Other'
 END,
country,city,postal_code,address
FROM users_raw;


#Creamos la tabla credit_cards con los campos segun el archivo csv, asignando a cada columna su tipo de dato y longitud. 
#Ademas de definir la primary key definimos tambien la foreign key que relaciona la tabla credit_cards con users,
# Definimos un indice llamado idx_user_id para optimizar las consultas.

#creamos la tabla credit_cards_raw para obtener todos los datos en crudo del archivo CSV para luego transformar 
CREATE TABLE IF NOT EXISTS `credit_cards_raw`  ( 
  `id` varchar(20) ,
  `user_id` int NOT NULL,
  `iban` varchar(50) DEFAULT NULL,
  `pan` varchar(20) DEFAULT NULL,
  `pin` varchar(4) DEFAULT NULL,
  `cvv` varchar(4) DEFAULT NULL,
  `track1` varchar(100) DEFAULT NULL,
  `track2` varchar(100) DEFAULT NULL,
  `expiring_date` varchar(50) DEFAULT NULL
) ;

#Procedemos a importar e insertar los datos del archivo csv a credit_cards_raw
LOAD DATA LOCAL INFILE 'C:\\Users\\aleja\\Documents\\Analisis de Datos\\Especialidad IT ACADEMY\\Sprint 4 MODELAT SQL\\Archivos adjuntos sprint 4\\credit_cards.csv'
INTO TABLE `credit_cards_raw`
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;

#Creamos la tabla credit_cards asignando su respectivo atributo a cada columna, y definiendo la primary key, foreign key y un indice.
CREATE TABLE IF NOT EXISTS `credit_cards`  ( 
  `id` varchar(20) NOT NULL,
  `user_id` int NOT NULL,
  `iban` varchar(50) DEFAULT NULL,
  `pan` varchar(20) DEFAULT NULL,
  `pin` varchar(4) DEFAULT NULL,
  `cvv` varchar(4) DEFAULT NULL,
  `track1` varchar(100) DEFAULT NULL,
  `track2` varchar(100) DEFAULT NULL,
  `expiring_date` DATE DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ;

-- Se procede a transfromar los datos en el SELECT y a insertarlos en la tabla credit_cards
INSERT INTO `credit_cards` (id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date)
SELECT id,user_id,iban,pan,pin,cvv,track1,track2,
STR_TO_DATE(expiring_date, '%m/%d/%y')
FROM credit_cards_raw;

Select * from credit_cards; -- comprobando los datos 


#Creando la tabla companies, no hace falta en este caso creaer una tabla en crudo ya que es necesario hacer transformaciones de datos porque en este caso ya estan limpios
  
CREATE TABLE IF NOT EXISTS `companies` (
  `id` varchar(20) NOT NULL, #Tener en cuenta el nombre del id en el archivo CSV que es company_id
  `company_name` varchar(255) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `website` varchar(260) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ;

#Procedemos a importar e insertar los datos del archivo csv a la tabla companies
LOAD DATA LOCAL INFILE 'C:\\Users\\aleja\\Documents\\Analisis de Datos\\Especialidad IT ACADEMY\\Sprint 4 MODELAT SQL\\Archivos adjuntos sprint 4\\companies.csv'
INTO TABLE `companies`
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;

SELECT * FROM companies; -- comprobando que se hayan insertado los datos 


-- Para crear la columna products, se ha detectado que en la columna price se encuentra el simbolo "$" por lo que será necesario transformar esa columna
-- Creamos una tabla llamada products_raw que reciba los datos sin alterar del archivo csv:

CREATE TABLE IF NOT EXISTS `products_raw`(
`id` int,
`product_name` varchar (100) DEFAULT NULL,
`price` varchar(50) DEFAULT NULL , -- Asignamos como varchar y luego se procede a transformar cuando se inserte en la otra tabla
`colour` varchar (20) DEFAULT NULL,
`weight` DECIMAL(10,2) DEFAULT NULL,
`warehouse_id` varchar(20) DEFAULT NULL
);

#Procedemos a importar e insertar los datos del archivo csv a la tabla products_raw
LOAD DATA LOCAL INFILE 'C:\\Users\\aleja\\Documents\\Analisis de Datos\\Especialidad IT ACADEMY\\Sprint 4 MODELAT SQL\\Archivos adjuntos sprint 4\\products.csv'
INTO TABLE `products_raw`
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS ;

-- Creamos la tabla products, que contendrá los valores en limpio y con su respectiva primary key.

CREATE TABLE IF NOT EXISTS `products`(
`id` int NOT NULL PRIMARY KEY ,
`product_name` varchar (100) DEFAULT NULL,
`price` DECIMAL(10,2) DEFAULT NULL ,
`colour` varchar (20) DEFAULT NULL,
`weight` DECIMAL(10,2) DEFAULT NULL,
`warehouse_id` varchar(20) DEFAULT NULL
);

-- Se procede a transfromar los datos en el SELECT y a insertarlos en la tabla products
INSERT INTO `products` (id,product_name,price,colour,weight,warehouse_id)
SELECT id,product_name,
REPLACE(REPLACE(price,'$',''), ',', '')
,colour,weight,warehouse_id
FROM products_raw;


-- Creando la tabla transactions 
-- Hemos notado que en el archivo CSV para la creacion de la tabla transactions, existe una columna llamada product_ids en la cual tiene varios ids en una misma celda
-- por lo que procederemos a crear una tabla llamada transaction_products, donde podremos transformar los datos para evitar errores 
-- debido a que manipular la informacion donde hay mas de un id en una misma celda puede darnos problemas y dificultades a la hora de filtrar o agrupar.

-- Creamos una tabla llamada transactions_raw donde insertaremos los datos y luego procederemos a transformarlos, por lo que definiremos todas las columnas como varchar 

CREATE TABLE `transactions_raw` (
  `id` VARCHAR(255),
  `card_id` VARCHAR(20),
  `business_id` VARCHAR(20),-- Esta columna actua como foreign key que hace referencia a la tabla companies
  `timestamp` VARCHAR(50),      
  `amount` VARCHAR(20),        
  `declined` VARCHAR(10),
  `product_ids` VARCHAR(255),   
  `user_id` VARCHAR(20),
  `lat` VARCHAR(50),           
  `longitude` VARCHAR(50)       
  );

-- Se procede a insertar los datos del archivo CSV en la tabla transactions_raw
LOAD DATA LOCAL INFILE 'C:\\Users\\aleja\\Documents\\Analisis de Datos\\Especialidad IT ACADEMY\\Sprint 4 MODELAT SQL\\Archivos adjuntos sprint 4\\transactions.csv'
INTO TABLE `transactions_raw`
FIELDS TERMINATED BY ';' -- en el excel no se nota pero abriendo con block de notas se ve el separador claramente  
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' -- se tuvo que agregar el \r porque se descuadraba y no detectaba el final de las filas
IGNORE 1 ROWS
(id, card_id, business_id, timestamp, amount, declined, @product_ids, user_id, lat, longitude)  -- Se especifican las columnas para evitar errores 
SET product_ids = REPLACE(@product_ids, ' ', '');


TRUNCATE TABLE transactions_raw;-- se usa bara borrar todo el contenido de la tabla pero dejando la estructura
SELECT COUNT(*) FROM transactions_raw; 
DESCRIBE transactions_raw;


#Creo la tabla trancactions con sus atributos 
CREATE TABLE IF NOT EXISTS `transactions`(
 `id` varchar(255) NOT NULL,
  `card_id` varchar(20) DEFAULT NULL,
  `company_id` varchar(20) DEFAULT NULL,    -- Se renombra la columna `business_id` a `company_id` para mayor facilidad y congruencia en las consultas
  `timestamp` timestamp NULL DEFAULT NULL, -- timestamp que tiene el formato de fecha incorrecto  ---> 12/12/2018 8:05 y lo transformaremos en ---> 2018-12-12 08:05:00
  `amount` DECIMAL(10,2) DEFAULT NULL,
  `declined` tinyint DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `lat` varchar(250) DEFAULT NULL,
  `longitude` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`), -- Creamos Indices para user_id, card_id y company_id para tener las consultas optimizadas
  KEY `idx_card_id` (`card_id`),
  KEY `idx_company_id` (`company_id`),
  CONSTRAINT `fk_card_id` FOREIGN KEY (`card_id`) REFERENCES `credit_cards` (`id`),
  CONSTRAINT `fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_company_id` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
);

-- Comprobando si se ha cargado bien el timestamp en la tabla transactions_raw para evitar conversion, y si estan limpios.
SELECT DISTINCT timestamp FROM transactions_raw;
select * from transactions_raw;
SELECT 
  timestamp,
  LENGTH(timestamp)
FROM transactions_raw
GROUP BY timestamp;

-- Se procede a transformar, limpiar y a insertar en la tabla transactions con un SELECT desde la tabla transactions_raw
INSERT INTO `transactions` (id,card_id,company_id,timestamp,amount,declined,user_id,lat,longitude)
SELECT id,card_id,business_id,timestamp,
CAST(REPLACE(REPLACE(amount,'$',''), ',', '') AS DECIMAL(10,2)), -- aplicamos esta conversion por si hubiese algun dato con moneda $ y con coma (,)
CAST(declined as unsigned), -- unsigned: entero positivo que actuara como booleano
CAST(user_id as unsigned),
lat,longitude
FROM transactions_raw;

SELECT * FROM transactions;

#Creamos la tabla puente donde podremos de esta forma obtener un mejor modelado de datos y evitar errores por la columna product_ids
CREATE TABLE IF NOT EXISTS `transaction_products`(
`transaction_id` varchar(255) NOT NULL,
`product_id` int NOT NULL,
PRIMARY KEY (`transaction_id`,`product_id`),
CONSTRAINT `fk_transaction_id` FOREIGN KEY (`transaction_id`) REFERENCES `transactions`(`id`),
CONSTRAINT `fk_product_id` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
);

-- Se procede a insertar los datos a transactions_products a traves de un SELECT desde la tabla transactions_raw
INSERT INTO `transaction_products`(transaction_id,product_id)
SELECT t.id, jt.product_id
FROM transactions_raw t,
JSON_TABLE(
	CONCAT('[',REPLACE(product_ids, ' ',''),']'), '$[*]'
    COLUMNS(
			product_id int PATH '$')
) as jt
WHERE t.product_ids IS NOT NULL  -- con estos ultimos dos filtros evitamos que se rompa el insert por un nulo o dato dañado
AND t.product_ids <> '';

-- Otra opcion para poder crear la tabla transaction_products y solucionar la relacion muchos a muchos era con FIND_IN_SET


/*Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.*/
-- Con subconsulta A CORREGIR:
SELECT u.id,u.name,u.surname
FROM users u 
where u.id in (
SELECT t.user_id
FROM transactions t
where t.declined=0
group by t.user_id
having COUNT(t.id)>80
);

-- Mismo ejercicio,solucion con JOIN 
SELECT u.id,u.name,u.surname,COUNT(t.id) as number_transactions
FROM users u
JOIN transactions t
ON u.id=t.user_id
WHERE t.declined=0
GROUP BY u.id,u.name,u.surname
HAVING number_transactions>80;


/*Exercici 2
Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.*/

select *   -- Buscando en la tabla companies como se encuentra escrita exactamente la compañia solicitada
from companies
where company_name like ('%Donec%');

SELECT cr.iban, ROUND(AVG(amount),2) as average_amount
FROM transactions t
JOIN credit_cards cr
ON t.card_id=cr.id
JOIN companies co
ON t.company_id=co.id
WHERE co.company_name='Donec Ltd' AND t.declined=0
GROUP BY cr.iban
ORDER BY average_amount DESC;



/*Nivell 2
Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions han estat declinades aleshores és inactiu, 
si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:

Exercici 1
Quantes targetes estan actives?*/

-- Creamos la tabla card_status 
CREATE TABLE IF NOT EXISTS card_status
SELECT card_id,
CASE 
	WHEN SUM(declined)=COUNT(*) THEN 'Inactive'-- Igualando el sum con el count se evita marcar como activa una tarjeta q tenga solo 2 transacciones y a su vez declinadas
    ELSE 'Active'
END AS current_status
FROM( SELECT card_id, declined,
 ROW_NUMBER() OVER(PARTITION BY card_id 
 ORDER BY timestamp DESC) AS rn -- alias comun rn para la funcion ROW_NUMBER()
 FROM transactions) AS ranked
WHERE rn<=3
GROUP BY card_id;
-- COUNT(*) cuenta cuántas filas reales tiene esa tarjeta después del filtro, sea 1, 2 o 3. 
-- Y SUM(declined) cuenta cuántas fueron declinadas. Si son iguales, todas fueron declinadas.

-- Exercici 1
-- Quantes targetes estan actives?
SELECT COUNT(*) AS active_cards
FROM card_status
WHERE current_status='Active';



/*Nivell 3
Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

Exercici 1
Necessitem conèixer el nombre de vegades que s'ha venut cada producte.*/

SELECT tp.product_id,p.product_name,COUNT(*) as number_sales
FROM transaction_products tp
JOIN products p ON tp.product_id=p.id
JOIN transactions t ON tp.transaction_id=t.id
WHERE t.declined=0
GROUP BY tp.product_id,p.product_name
ORDER BY tp.product_id;




