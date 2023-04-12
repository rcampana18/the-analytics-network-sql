--CLASE 1--

1) Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
SELECT *
FROM stg.product_master
WHERE categoria='Electro'

2)Cuales son los productos producidos en China?
SELECT *
FROM stg.product_master
WHERE origen='China' 

3)Mostrar todos los productos de Electro ordenados por nombre.
SELECT nombre
FROM stg.product_master
WHERE categoria='Electro'
ORDER BY nombre --DESC
--**Cómo hago si tengo valores null en el nombre por ejemplo?

4)Cuales son las TV que se encuentran activas para la venta?
SELECT nombre
FROM stg.product_master
WHERE subcategoria='TV'and is_active='true'

5)Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
SELECT *
FROM stg.store_master
WHERE pais='Argentina'
ORDER BY fecha_apertura   

--**Qué pasa con las fechas null?

6)Cuales fueron las ultimas 5 ordenes de ventas?
SELECT orden,fecha
FROM stg.order_line_sale
ORDER BY fecha DESC
LIMIT 5

7)Mostrar los primeros 10 registros del conteo de trafico por Super store ordenados por fecha.
SELECT date(fecha::text),tienda
FROM stg.super_store_count
ORDER BY fecha                        
LIMIT 10

8)Cuales son los productos de electro que no son Soporte de TV ni control remoto.
SELECT *
FROM stg.product_master
WHERE categoria='Electro' and subsubcategoria NOT IN ('Soporte','Control remoto')
--??? Qué pasa si tengo subsubcategoría null? Trae el producto?

9)Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
SELECT *
FROM stg.order_line_sale
WHERE moneda='ARS'and venta > 100000

10)Mostrar todas las lineas de ventas de Octubre 2022.
SELECT *
FROM stg.order_line_sale
WHERE fecha LIKE '%-10-%' --No lo toma por el tipo de dato 'date'?

SELECT *
FROM stg.order_line_sale
WHERE EXTRACT(MONTH FROM fecha)=10

11)Mostrar todos los productos que tengan EAN.
SELECT *
FROM stg.product_master
WHERE ean IS NOT NULL

12)Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 
10 de Noviembre de 2022.
SELECT *
FROM stg.order_line_sale							
WHERE fecha > '2022-10-01' and fecha < '2022-11-10'    

SELECT *
FROM stg.order_line_sale
WHERE fecha BETWEEN '2022-10-01' AND '2022-11-10' /*Con BETWEEN*/

--CLASE 2--

1)Cuales son los paises donde la empresa tiene tiendas?
SELECT DISTINCT pais
FROM stg.store_master

2)Cuantos productos por subcategoria tiene disponible para la venta?
SELECT subcategoria, count(subcategoria) as Prod_disp
FROM stg.product_master
WHERE is_active='true'
GROUP BY subcategoria
ORDER BY Prod_disp DESC

3)Cuales son las ordenes de venta de Argentina de mayor a $100.000?
SELECT orden,venta
FROM stg.order_line_sale
WHERE moneda='ARS' and venta > 100000

4)Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?

SELECT moneda,trunc(abs(sum(coalesce(descuento,0))),2)
FROM stg.order_line_sale
WHERE fecha BETWEEN '2022-11-1' AND '2022-11-30'
GROUP BY moneda

5)Obtener los impuestos pagados en Europa durante el 2022.

OPCION 1
SELECT moneda, round(sum(impuestos),2)
FROM stg.order_line_sale
WHERE fecha BETWEEN '2022-01-1' AND '2022-12-31' and moneda='EUR'
GROUP BY moneda

OPCION 2
SELECT moneda,round(sum(impuestos),2)
FROM stg.order_line_sale
WHERE EXTRACT(YEAR FROM fecha)=2022 and moneda='EUR'
GROUP BY moneda

6)En cuantas ordenes se utilizaron creditos?
SELECT count(distinct orden) as Con_Creditos 
FROM stg.order_line_sale
WHERE creditos IS NOT NULL

7)Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
SELECT tienda, abs(round((sum(descuento)/sum(venta))*100,2)) as porcentaje
FROM stg.order_line_sale
GROUP BY tienda

8)Cual es el inventario promedio por dia que tiene cada tienda?
SELECT tienda, trunc(AVG((inicial+final)/2),2) as promedio
FROM stg.inventory
GROUP BY tienda
ORDER BY tienda

9)Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.

SELECT producto,
		sum(coalesce(venta,0)+coalesce(descuento,0))as venta_neta,
		abs(round(sum(coalesce(descuento,0))/sum((coalesce(venta,0)))*100,2)) as porcentaje
FROM stg.order_line_sale
WHERE moneda='ARS' 
GROUP BY producto
ORDER BY producto

10)Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa 
para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa.
Obtener en una unica tabla, las entradas a tienda de ambos sistemas.

Select tienda,date(fecha::TEXT),conteo from stg.market_count
UNION ALL 
Select tienda,date(fecha::TEXT),conteo from stg.super_store_count

11)Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
SELECT*
FROM stg.product_master
WHERE nombre LIKE '%PHILIPS%' and is_active='true'  
--Si tengo variantes de mayúsculas/minúsculas, tengo que incluir las posibles variantes en la query?
--Cómo sabría si tengo muchas variantes en cómo está escrito Phillips? Hay que conocer la base
SELECT*
FROM stg.product_master
WHERE Lower (nombre) LIKE '%philips%' and is_active='true' 

12)Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal.
SELECT tienda, moneda, trunc(sum(venta),2)as ventas
FROM stg.order_line_sale
GROUP BY moneda, tienda
ORDER BY ventas DESC

13)Cual es el precio promedio de venta de cada producto en las distintas monedas? 
Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
SELECT moneda,producto,trunc(sum(venta)/sum(cantidad),2) as promedio
FROM stg.order_line_sale
GROUP BY moneda,producto
ORDER BY moneda

14)Cual es la tasa de impuestos que se pago por cada orden de venta?
SELECT orden, trunc(sum(impuestos)/sum(venta),2) as tasa
FROM stg.order_line_sale
GROUP BY orden
ORDER BY orden

--CLASE 3--

1)Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, 
mostrando la leyenda "Unknown" cuando no hay un color disponible

SELECT nombre, codigo_producto, categoria, coalesce(color,'Unknown')as Color_nulos
FROM stg.product_master
WHERE lower(nombre) LIKE '%philips%' or lower (nombre) LIKE '%samsung%' 

2)Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.

SELECT sm.pais, 	
	sm.provincia, 
	sum(ols.venta) as gross_sale, 
	sum(ols.impuestos) as tax 
FROM stg.order_line_sale as ols
JOIN stg.store_master as sm
ON ols.tienda=sm.codigo_tienda
GROUP BY sm.pais, sm.provincia

3)Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria
y moneda.

SELECT pm.subcategoria,
	ols.moneda,
	sum(ols.venta) as vebtas
FROM stg.order_line_sale as ols
LEFT JOIN stg.product_master as pm
ON ols.producto=pm.codigo_producto
GROUP BY ols.moneda,pm.subcategoria 
ORDER BY subcategoria, moneda

4)Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia;
usar guion como separador y usarla para ordernar el resultado.

SELECT pm.subcategoria,
	(sm.pais||'-'||sm.provincia) as pais_pcia, 
	sum(ols.cantidad) as unid_vendidas
FROM stg.order_line_sale as ols
LEFT JOIN stg.product_master as pm
ON ols.producto=pm.codigo_producto
LEFT JOIN stg.store_master as sm
ON ols.tienda=sm.codigo_tienda
GROUP BY pm.subcategoria, pais_pcia 
ORDER BY pais_pcia

5)Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo
desde la fecha de apertura para el sistema "super_store".

SELECT sm.nombre, sum(conteo)
FROM stg.super_store_count as ssc
LEFT JOIN stg.store_master as sm
ON ssc.tienda=sm.codigo_tienda
--WHERE date(ssc.fecha::text)>sm.fecha_apertura /*por las dudas para que sea mayor a la fecha de apertura*/
GROUP BY sm.nombre

6)Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; 
mostrar el resultado con el nombre de la tienda.

SELECT extract(month from inv.fecha) as mes,
		sm.nombre, 
		inv.sku, 
		trunc(avg((inicial+final)/2),2)as inv_prom
FROM stg.inventory as inv
JOIN stg.store_master as sm
ON inv.tienda=sm.codigo_tienda
GROUP BY mes, sm.nombre, inv.sku
ORDER BY sm.nombre

7)Calcular la cantidad de unidades vendidas por material. 
Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.

/* Cuál es la diferencia? */

OPCION 1:
SELECT 
	CASE
		WHEN pm.material is null then 'Unknown'
		else upper(pm.material)
		END as material_2,
	sum(ols.cantidad)
FROM stg.order_line_sale as ols
LEFT JOIN stg.product_master as pm
ON ols.producto=pm.codigo_producto
GROUP BY material_2 

OPCION 2:
With material_1 as 
SELECT *,
	CASE
		WHEN material is null then 'Unknown'
		else upper(material)
		END as material_consolidado	
FROM stg.order_line_sale as ols
LEFT JOIN stg.product_master as pm
ON ols.producto=pm.codigo_producto
)
SELECT material_consolidado, sum(cantidad)
FROM material_1
GROUP BY material_consolidado

8)Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta 
en cada linea convertido a dolares usando la tabla de tipo de cambio.

/*Quiero Joinear con el mes las dos tablas y las ventas brutas dividirlas por la cotizacion para 
tener el valor en usd.
--OLS tiene fechas del 2022
--mafr tiene los meses del 2022 y 2023 */

SELECT *,  /*Cuándo es necesario referenciar la tabla de origen cuando hay join??*/
	Round(CASE
		WHEN moneda='ARS' then ols.venta/mafr.cotizacion_usd_peso
		WHEN moneda='EUR' then ols.venta/mafr.cotizacion_usd_eur
		WHEN moneda='URU' then ols.venta/mafr.cotizacion_usd_uru
	END,2) AS venta_bruta_usd,
	(TO_CHAR (fecha, 'YYYY-MM')) AS fecha,
    (TO_CHAR (mes, 'YYYY-MM')) AS mes
FROM stg.order_line_sale as ols
LEFT JOIN stg.monthly_average_fx_rate as mafr
ON extract(month from ols.fecha)=extract(month from mafr.mes)
	
9)Calcular cantidad de ventas totales de la empresa en dolares.

With tabla_nueva as(
SELECT *,  
	CASE
		WHEN moneda='ARS' then ols.venta/mafr.cotizacion_usd_peso
		WHEN moneda='EUR' then ols.venta/mafr.cotizacion_usd_eur
		WHEN moneda='URU' then ols.venta/mafr.cotizacion_usd_uru
	END AS venta_usd
FROM stg.order_line_sale as ols
LEFT JOIN stg.monthly_average_fx_rate as mafr
ON extract(month from ols.fecha)=extract(month from mafr.mes)
)
SELECT trunc(sum(venta_usd),2) as Tot_Venta_USD
FROM tabla_nueva

10)Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - promociones) - costo expresado en dolares.

With nueva_tabla as(
SELECT *,  
	trunc(CASE
		WHEN moneda='ARS' then (ols.venta+coalesce(ols.descuento,0))/mafr.cotizacion_usd_peso
		WHEN moneda='EUR' then (ols.venta+coalesce(ols.descuento,0))/mafr.cotizacion_usd_eur
		WHEN moneda='URU' then (ols.venta+coalesce(ols.descuento,0))/mafr.cotizacion_usd_uru
	END,2) AS venta_neta_usd
FROM stg.order_line_sale as ols
LEFT JOIN stg.monthly_average_fx_rate as mafr
ON extract(month from ols.fecha)=extract(month from mafr.mes)
LEFT JOIN stg.cost as cst
ON ols.producto=cst.codigo_producto
)
SELECT *, trunc(venta_neta_usd-costo_promedio_usd,2) as margen
FROM nueva_tabla
	
11)Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.

SELECT orden, subcategoria, count(distinct producto)
FROM stg.order_line_sale as ols
LEFT JOIN stg.product_master as pm
ON ols.producto=pm.codigo_producto
GROUP BY orden, subcategoria

CLASE 4
1)Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
CREATE SCHEMA bkp

Select * 
INTO bkp.product_master_20230404
FROM stg.product_master

Select *, current_date as backup_date 
INTO bkp.product_master_20230404
FROM stg.product_master

2)Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. 
Pueden utilizarse dos sentencias.

UPDATE bkp.product_master_20230404
SET color='N/A'
WHERE color is null

UPDATE bkp.product_master_20230404
SET material='N/A'
WHERE material is null

3)Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".

UPDATE bkp.product_master_20230404
SET is_active='false'
WHERE subsubcategoria='Control remoto'

4)Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.

ALTER TABLE bkp.product_master_20230404
ADD COLUMN is_local boolean

UPDATE bkp.product_master_20230404
SET is_local=
			Case when origen='Argentina' then true
			Else false
			End

5)Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
/*bkp a la ols para no tocar la original*/

Select * 
INTO bkp.ols_20230404
FROM stg.order_line_sale

ALTER TABLE bkp.ols_20230404
ADD COLUMN  line_key varchar

UPDATE bkp.ols_20230404
SET line_key=(orden||'-'||producto)

6)Eliminar todos los valores de la tabla "order_line_sale" para el POS 1.

DELETE FROM bkp.ols_20230404
WHERE pos=1

7)Crear una tabla llamada "employees" (por el momento vacia) que tenga un id (creado de forma incremental),
nombre, apellido, fecha de entrada, fecha salida, telefono, pais, provincia, codigo_tienda, posicion. 
Decidir cual es el tipo de dato mas acorde.

DROP TABLE IF EXISTS bkp.employees ;
    
CREATE TABLE bkp.employees (
			id 			SERIAL primary key,
			nombre 			varchar(20),
			apellido 		varchar(20),
			fecha_entrada 		date,
			fecha_salida 		date,
			telefono 		bigint,
			pais 			varchar(20),
			provincia 		varchar(20),
			codigo_tienda 		int,
			posicion 		varchar
	
)

8)Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:

INSERT INTO bkp.employees (nombre, apellido, fecha_entrada, fecha_salida, telefono, pais, provincia, codigo_tienda, posicion) 
VALUES 	('Juan','Perez','2022-01-01',null,'541113869867','Argentina','Santa Fe','2', 'Vendedor'),
	('Catalina', 'Garcia','2022-03-01', null,null,'Argentina','Buenos Aires','2','Representante Comercial'),
	('Ana','Valdez','2020-02-21','2022-03-01',null,'España','Madrid','8','Jefe Logistica'),
	('Fernando', 'Moralez',null, '2022-04-04',null, 'España', 'Valencia','9', 'Vendedor')

9)Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.

INSERT INTO bkp.employees (nombre, apellido, fecha_entrada, fecha_salida, telefono, pais, provincia, codigo_tienda, posicion) 
VALUES 	('Juan','Perez','2022-01-01',null,'541113869867','Argentina','Santa Fe','2', 'Vendedor')

10)Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial

INSERT INTO bkp.employees (nombre, apellido, fecha_entrada, fecha_salida, telefono, pais, provincia, codigo_tienda, posicion) 
VALUES ('Catalina', 'Garcia','2022-03-01', null,null,'Argentina','Buenos Aires','2','Representante Comercial')

11)Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica

INSERT INTO bkp.employees (nombre, apellido, fecha_entrada, fecha_salida, telefono, pais, provincia, codigo_tienda, posicion) 
VALUES ('Ana','Valdez','2020-02-21','2022-03-01',null,'España','Madrid','8','Jefe Logistica')

12)Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.

INSERT INTO bkp.employees (nombre, apellido, fecha_entrada, fecha_salida, telefono, pais, provincia, codigo_tienda, posicion) 
VALUES ('Fernando', 'Moralez',null, '2022-04-04',null, 'España', 'Valencia','9', 'Vendedor')
13)Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.

Drop table bkp.cost_20230411

Select *, now() last_updated_ts 
INTO bkp.cost_20230411
FROM stg.cost

14)El cambio en la tabla "order_line_sale" en el punto 6 fue un error y debemos volver la tabla a su estado original, como lo harias?
TBD
