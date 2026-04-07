#TAREA SPRINT 3 
/*Nivell 1
Exercici 1
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu 
descripció d'aquest.*/

#CREAMOS LA TABLA, Y SUS COLUMNAS SEGUN LO Q SE NECESITA (lo sabemos viendo los datos que ingresaremos con el archivo adjunto)

CREATE TABLE IF NOT EXISTS credit_card(
id VARCHAR(20) PRIMARY KEY, 
iban VARCHAR(60), 
pan VARCHAR(30), 
pin VARCHAR(4), 
cvv VARCHAR(3), 
expiring_date VARCHAR(20)
); 

#Creamos la restriccion y foreign key para asignar la relacion con la tabla transaction 
ALTER TABLE transaction 
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);

#Comprobamos que haya funcionado la relacion creada, haciendo un SELECT y un join:
SELECT * FROM transaction t
JOIN credit_card c
ON c.id=t.credit_card_id;


/*Exercici 2
El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938. 
La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.*/

UPDATE credit_card 
SET iban="TR323456312213576817699999"
WHERE id="CcU-2938" ;

select * 
from credit_card
where id="CcU-2938";


/* Exercici 3
En la taula "transaction" ingressa una nova transacció amb la següent informació:

Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	0   */

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude,amount,declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999,111.11,0);

#Al intentar hacer el INSERT INTO nos salta un error debido a que estamos intentando agregar valores a la foreign key que no se encuentran en la tabla padre expresamente 
#en la columna id de company y id de credit_card
 
#Procedemos a utilizar el comando SET FOREIGN_KEY_CHECKS  para desactivar la seguridad de actualizacion y agregar los datos que faltan a las tablas company y credit_card
SET FOREIGN_KEY_CHECKS = 0; 

# AGREGANDO PRIMERO LOS VALORES A LA TABLAS TABLAS PRINCIPALES-PADRE
INSERT INTO credit_card (id) VALUES('CcU-9999');

INSERT INTO company (id) VALUES('b-9999');

#Luego volvemos a utilizar el comando para activar nuevamente el modo seguro y mantener protegidos los datos
SET FOREIGN_KEY_CHECKS = 1; 

#Ahora si podemos agregar los datos con el INSERT INTO :
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude,amount,declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999,111.11,0);

#ahora mostramos q se hayan agregado los valores del ejercicio
select * from transaction 
where credit_card_id="CcU-9999";


/*Exercici 4
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.*/

#REALIZAMOS LA ALTERACION Y ELIMINACION DE LA COLUMNA PAN
ALTER TABLE credit_card
DROP column pan ;

#Comprobamos que se ha eliminado la columna "pan" con el comando DESCRIBE:
DESCRIBE credit_card;

/*Nivell 2
Exercici 1
Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.*/

#Procedemos a realizar la eliminacion el registro con el comando DELETE:
DELETE FROM transaction
where id= "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

#Comprobamos con un SELECT que haya funcionado la eliminacion y mostramos el resultado:
SELECT * FROM transaction
where id= "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

/*Exercici 2
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
*/

#Procedemos a crear la vista con el comando CREATE OR REPLACE:
CREATE OR REPLACE VIEW VistaMarketing AS  
SELECT c.company_name, c.phone, c.country, avg(t.amount) as average_sales 
FROM company c
JOIN transaction t
ON c.id=t.company_id
WHERE t.declined=0
GROUP BY c.company_name, c.phone, c.country;

#Mostramos la vista creada con un SELECT y ordenamos segun media de ventas como se pide en el ejercicio con un ORDER BY de mayor a menor
SELECT * 
FROM VistaMarketing 
ORDER BY average_sales desc;

/* Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany" */

# Se muestra a traves de un SELECT las compañias que se encuentran en Alemania, utilizando la vista creada VistaMarketing y filtrando con un WHERE
SELECT * 
FROM VistaMarketing 
WHERE country="Germany"
;

/*Nivell 3
Exercici 1
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, 
però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama: */

#Al observar el diagrama notamos que es necesario renombrar la tabla user a data_user, por lo que aplicamos un RENAME:
RENAME TABLE user to data_user;

#Modificamos la columna id de la tabla data_user ya que esta creada como tipo char, procedemos a convertirla a tipo int con el comando ALTER TABLE:
ALTER TABLE data_user 
MODIFY id int;

#Modificamos el nombre de la columna email a personal_email de la tabla data_user a traves del comando ALTER TABLE, para obtener un modelo como se muestra en el diagrama:
ALTER TABLE data_user 
CHANGE email personal_email VARCHAR(150);

#CREAMOS la relacion de la tabla data_user con la primary key a transaction
ALTER TABLE transaction
ADD CONSTRAINT fk_data_user_id 
FOREIGN KEY (user_id)
REFERENCES data_user(id);
#DA ERROR 

#Con esta consulta podemos comprobar los datos que se encuentran(ids en este caso) en la tabla hijo pero no en la tabla padre
#Por eso nos da error al intentar hacer la restriccion y la relacion con la foreign key
SELECT user_id
FROM transaction
WHERE user_id IS NOT NULL
AND user_id NOT IN (
    SELECT id FROM data_user
);

#Debemos desactivar el modo seguro antes para evitar el error y poder actualizar la tabla, usaremos el comando set sql_safe_updates
SET SQL_SAFE_UPDATES = 0; 
#Para desactivar el modo safe, luego volverlo a activar igualando a 1

#Ya que la tabla transaction(hijo) tiene datos que la tabla data_user(padre) no tiene debemos corregirlo, poniendo esos valores en null y luego hacer la relacion nuevamente
UPDATE transaction
SET user_id=NULL
WHERE user_id is NOT NULL 
AND user_id NOT IN (
	SELECT id
    FROM data_user
); #actualiza la tabla transaction, asignando nulo a la columna user_id cuando ésta no se encuentre en la tabla data_user

#Luego de hacer la actualizacion ahora si podemos crear la relacion sin que de el error de seguridad:
ALTER TABLE transaction
ADD CONSTRAINT fk_data_user_id 
FOREIGN KEY (user_id)
REFERENCES data_user(id);

#Activamos nuevamente como se debe el modo seguro:
SET SQL_SAFE_UPDATES = 1; 

#CAMBIOS QUE FALTAN HACER PARA QUE EL DIAGRAMA ESTÉ IGUAL:

# Modificando la longitud del iban en credit card el iban cambiar el varchar tambien
ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR (50) DEFAULT NULL;

# cambiar el cvv en credit card de varchar a int 
ALTER TABLE credit_card
MODIFY COLUMN cvv int; 

#crear columna fecha actual en credit_card
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

#Eliminar la columna website de la tabla company, antes haremos un backup, podriamos hacer una tabla pero solo exportaremos mejor la informacion hacia afuera con un archivo
SELECT id, website 
FROM company;    
#En resultados → clic derecho “Export recordset” Guardar como CSV

#Ahora si borramos porque ya guardamos una copia 
ALTER TABLE company
DROP COLUMN website;


/*
Exercici 2
L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.*/

#Creamos la VIEW con el comando CREATE OR REPLACE:

CREATE OR REPLACE VIEW InformeTecnico AS
SELECT t.id as Transaction_id, d.name as User_name,d.surname as User_surname,c.iban as Credit_card_iban,co.company_name as Company
FROM transaction t
JOIN data_user d
ON t.user_id=d.id
JOIN credit_card c
ON t.credit_card_id=c.id
JOIN company co
ON t.company_id=co.id
WHERE t.declined=0;

#MOSTRAMOS LA VIEW con el comando SELECT ordenando como se pide segun el TRANSACTION_ID de mayor a menor.
SELECT *
FROM InformeTecnico
ORDER BY Transaction_id DESC;





