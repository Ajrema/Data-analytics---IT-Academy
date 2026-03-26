/*NIVELL 1
Exercici 2
Utilitzant JOIN realitzaràs les següents consultes:
*/

#Llistat dels països que estan generant vendes.
SELECT distinct country
FROM company c
JOIN transaction t 
ON c.id=t.company_id
WHERE declined !=1;


#Des de quants països es generen les vendes.
SELECT count(distinct country) as Cantidad_Paises
FROM company c
JOIN transaction t 
ON c.id=t.company_id
WHERE declined !=1;



#Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name, round(AVG(amount),2) as Media_Ventas
FROM company c
JOIN transaction t 
ON c.id=t.company_id
WHERE declined !=1
GROUP BY c.company_name
ORDER BY Media_Ventas DESC
limit 1;


/*Exercici 3
Utilitzant només subconsultes (sense utilitzar JOIN):
*/

#Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
where company_id in ( 
		SELECT id
		FROM company
		where country="Germany"
);

#Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT *
FROM company c
WHERE EXISTS (
	SELECT 1
	FROM transaction t
	WHERE c.id=t.company_id
    AND amount>(
		SELECT AVG(amount) as promedio_monto
		FROM transaction
) AND declined !=1
);


#Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
#No hay empresas sin transacciones
SELECT *
FROM company c
where id not in(
	SELECT company_id
	FROM transaction 
);


/*Nivell 2
Exercici 1
Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
Mostra la data(fecha) de cada transacció juntament amb el total de les vendes.*/

SELECT DATE(timestamp) as Fecha, SUM(amount) as Total_ventas 
FROM transaction
WHERE declined !=1
group by DATE(timestamp)
order by sum(amount) desc
limit 5;


/*
Exercici 2
Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.*/

SELECT country, ROUND(AVG(amount),2) as Media_ventas
FROM company c
JOIN transaction t
ON c.id=t.company_id
WHERE declined !=1
GROUP BY country
ORDER BY AVG(amount) DESC;


/*
Exercici 3
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
 Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.*/
#Mostra el llistat aplicant JOIN i subconsultes.
SELECT *
FROM company c
JOIN transaction t
ON c.id=t.company_id
WHERE country = (
	SELECT country
	FROM company 
	where company_name="Non Institute"
) AND company_name!="Non institute"
;

#Mostra el llistat aplicant solament subconsultes
SELECT * 
FROM transaction 
WHERE company_id in (
	SELECT id 
	FROM company
	WHERE country in (
		SELECT country
		FROM company
		WHERE company_name="Non Institute"
) AND company_name!="Non Institute"
);

/*Nivell 3
Exercici 1
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros i 
en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor quantitat.*/

SELECT country, company_name, phone, DATE(t.timestamp) as Date ,amount  
FROM company c
JOIN transaction t
ON c.id=t.company_id
where amount BETWEEN 350 AND 400 
AND DATE(t.timestamp) in ("2015-04-29","2018-07-20","2024-03-13") #sino ponemos las fechas entre comillas serian operaciones matematicas
ORDER BY amount DESC;

/*Exercici 2
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre 
la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis
 si tenen més de 400 transaccions o menys.*/
SELECT c.id,company_name, COUNT(*) as Transactions,
CASE
	WHEN COUNT(*)> 400 THEN "Superior a 400"
	ELSE "Menor a 400"
END as Classification
FROM company c
JOIN transaction t
ON c.id=t.company_id
GROUP BY c.id,company_name
order by Transactions DESC;


