--CLASE 1
1) Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
SELECT *
FROM stg.product_master
WHERE categoria='Electro'

2)Cuales son los productos producidos en China?
SELECT *
FROM stg.product_master
WHERE origen='China' 

SELECT categoria, subcategoria, COUNT(subcategoria)
FROM stg.product_master
WHERE origen='China'
GROUP BY  categoria,subcategoria

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
WHERE fecha BETWEEN '2022-10-01' AND '2022-11-10' 

--CLASE 2
1)Cuales son los paises donde la empresa tiene tiendas?
SELECT DISTINCT pais
FROM stg.store_master

2)Cuantos productos por subcategoria tiene disponible para la venta?
SELECT DISTINCT subcategoria, count(subcategoria) as SubCont
FROM stg.product_master
WHERE is_active='true'
GROUP BY subcategoria
ORDER BY SubCont DESC

3)Cuales son las ordenes de venta de Argentina de mayor a $100.000?
SELECT orden,venta
FROM stg.order_line_sale
WHERE moneda='ARS' and venta > 100000

4)Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
SELECT moneda,trunc(abs(sum(descuento)),2)
FROM stg.order_line_sale
WHERE fecha BETWEEN '2022-11-1' AND '2022-11-30' and descuento IS NOT NULL
GROUP BY moneda

5)Obtener los impuestos pagados en Europa durante el 2022.
SELECT moneda, round(sum(impuestos),2)
FROM stg.order_line_sale
WHERE fecha BETWEEN '2022-01-1' AND '2022-12-31' and moneda='EUR'
GROUP BY moneda

SELECT moneda,round(sum(impuestos),2)
FROM stg.order_line_sale
WHERE EXTRACT(YEAR FROM fecha)=2022 and moneda='EUR'
GROUP BY moneda

6)En cuantas ordenes se utilizaron creditos?
SELECT count(creditos) as Con_Creditos
FROM stg.order_line_sale
WHERE creditos IS NOT NULL

7)Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
SELECT tienda,sum(descuento) as dcto,sum(venta)as ventas, abs(round((sum(descuento)/sum(venta))*100,2)) as porcentaje
FROM stg.order_line_sale
GROUP BY tienda

8)Cual es el inventario promedio por dia que tiene cada tienda?
SELECT tienda, trunc(AVG((inicial+final)/2),2) as promedio
FROM stg.inventory
GROUP BY tienda
ORDER BY tienda

9)Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.

SELECT producto,coalesce(venta,0) as venta,coalesce(descuento,0) as dcto, coalesce(venta,0)+coalesce(descuento,0) as venta_neta,trunc(abs((coalesce(descuento,0))/(coalesce(venta,0)))*100,2) as porcentaje
FROM stg.order_line_sale
WHERE moneda='ARS' /*and descuento IS NOT NULL*/
GROUP BY producto,venta, dcto,venta_neta,porcentaje
ORDER BY producto

/*Comment: No haría falta usar el coalesce para "Venta" porque si está la orden es porque se realizó una venta.
Ahora, si la info no se importó bien por el motivo que fuera, puede que el campo venta esté null (?) y ahí
tendría sentido usar el coalesce.
Por otro lado no haría falta usar el coalesce en la agregación SUM de dcto porque se suman los no nulos*/

10)Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa 
para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa.
Obtener en una unica tabla, las entradas a tienda de ambos sistemas.

SELECT tienda, date(fecha :: varchar(10)),conteo FROM stg.market_count
UNION
SELECT tienda, date(fecha :: varchar(10)), conteo FROM stg.super_store_count

Select tienda,date(fecha::TEXT),conteo from stg.market_count
UNION ALL 
Select tienda,date(fecha::TEXT),conteo from stg.super_store_count

11)Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
SELECT*
FROM stg.product_master
WHERE nombre LIKE '%PHILIPS%' and is_active='true'  
--Si tengo variantes de mayúsculas/minúsculas, tengo que incluir las posibles variantes en la query?
--Cómo sabría si tengo muchas variantes en cómo está escrito Phillips? Funciones Upper y Lower
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

CLASE 3

1)Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, 
mostrando la leyenda "Unknown" cuando no hay un color disponible

SELECT nombre, codigo_producto, categoria, coalesce(color,'Unknown')as Color_nulos
FROM stg.product_master
WHERE lower(nombre) LIKE '%philips%' or lower (nombre) LIKE '%samsung%' 

2)Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.

SELECT sm.pais, sm.provincia, sum(ols.venta) as gross_sale, sum(ols.impuestos) as tax 
FROM stg.order_line_sale as ols
JOIN stg.store_master as sm
ON ols.tienda=sm.codigo_tienda
GROUP BY sm.pais, sm.provincia

3)Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria
y moneda.

SELECT pm.subcategoria,ols.moneda,sum(ols.venta) as gross_sale
FROM stg.order_line_sale as ols
LEFT JOIN stg.product_master as pm
ON ols.producto=pm.codigo_producto
GROUP BY ols.moneda,pm.subcategoria 
ORDER BY subcategoria, moneda

4)Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia;
usar guion como separador y usarla para ordernar el resultado.

SELECT pm.subcategoria,(sm.pais||'-'||sm.provincia) as pais_pcia, sum(ols.cantidad) as unid_vendidas
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
WHERE date(ssc.fecha::text)>sm.fecha_apertura /*por las dudas para que sea mayor a la fecha de apertura*/
GROUP BY sm.nombre

6)Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; 
mostrar el resultado con el nombre de la tienda.

SELECT extract(month from inv.fecha) as mes,sm.nombre, inv.sku, trunc(avg((inicial+final)/2),2)as inv_prom
FROM stg.inventory as inv
JOIN stg.store_master as sm
ON inv.tienda=sm.codigo_tienda
GROUP BY mes, sm.nombre, inv.sku
ORDER BY sm.nombre

/* Inventario promedio mensual*/
SELECT extract(month from inv.fecha) as mes, inv.sku, trunc(avg(inicial +final),2)as inv_prom
FROM stg.inventory as inv
GROUP BY mes, inv.sku

7)Calcular la cantidad de unidades vendidas por material. 
Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.

SELECT 
	CASE
		WHEN pm.material is null then 'Unknown'
		else upper(pm.material)
		END as material_2,
	sum(ols.cantidad)
FROM stg.order_line_sale as ols
LEFT JOIN stg.product_master as pm
ON ols.producto=pm.codigo_producto
GROUP BY pm.material 
/*Al agrupar por material, no estoy agrupando por lo que definí en el Case, por eso el resultado
tiene dos líneas de "plastico", porque nunca estoy mostrando la nueva columna. Esto sale con un nuevo
Select que me traiga esa info*/

With material_1 as /*material_1 sería una nueva tabla*/
SELECT *,
	CASE
		WHEN material is null then 'Unknown'
		--WHEN material = 'plastico' then 'Plastico'
		--WHEN material = 'PLASTICO' then 'Plastico'
		--WHEN material = 'Metal' then 'Metal'
		else upper(material)
		END as material_consolidado /*Sería la nueva columna*/	
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

SELECT *,  /*Cuándo es necesario referenciar la tabla de origen en el case?? Donde está la columna "moneda" por ejemplo*/
	CASE
		WHEN moneda='ARS' then ols.venta/mafr.cotizacion_usd_peso
		WHEN moneda='EUR' then ols.venta/mafr.cotizacion_usd_eur
		WHEN moneda='URU' then ols.venta/mafr.cotizacion_usd_uru
	END AS venta_bruta_usd,
	(TO_CHAR (fecha, 'YYYY-MM')) AS fecha,
    (TO_CHAR (mes, 'YYYY-MM')) AS mes
FROM stg.order_line_sale as ols
LEFT JOIN stg.monthly_average_fx_rate as mafr
ON extract(month from ols.fecha)=extract(month from mafr.mes)
	
9)Calcular cantidad de ventas totales de la empresa en dolares.

With tabla_nueva as(
SELECT *,  
	CASE
		WHEN moneda='ARS' then (ols.venta+coalesce(ols.descuento,0)+coalesce(ols.creditos,0))/mafr.cotizacion_usd_peso
		WHEN moneda='EUR' then (ols.venta+coalesce(ols.descuento,0)+coalesce(ols.creditos,0))/mafr.cotizacion_usd_eur
		WHEN moneda='URU' then (ols.venta+coalesce(ols.descuento,0)+coalesce(ols.creditos,0))/mafr.cotizacion_usd_uru
	END AS venta_neta_usd
FROM stg.order_line_sale as ols
LEFT JOIN stg.monthly_average_fx_rate as mafr
ON extract(month from ols.fecha)=extract(month from mafr.mes)
)
SELECT trunc(sum(venta_neta_usd),2) as Tot_Venta_USD
FROM tabla_nueva

10)Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - promociones) - costo expresado en dolares.

With nueva_tabla as(
SELECT *,  
	CASE
		WHEN moneda='ARS' then (ols.venta+coalesce(ols.descuento,0)+coalesce(ols.creditos,0))/mafr.cotizacion_usd_peso
		WHEN moneda='EUR' then (ols.venta+coalesce(ols.descuento,0)+coalesce(ols.creditos,0))/mafr.cotizacion_usd_eur
		WHEN moneda='URU' then (ols.venta+coalesce(ols.descuento,0)+coalesce(ols.creditos,0))/mafr.cotizacion_usd_uru
	END AS venta_neta_usd
FROM stg.order_line_sale as ols
LEFT JOIN stg.monthly_average_fx_rate as mafr
ON extract(month from ols.fecha)=extract(month from mafr.mes)
LEFT JOIN stg.cost as cst
ON ols.producto=cst.codigo_producto
)
SELECT *, venta_neta_usd-costo_promedio_usd as margen
FROM nueva_tabla
	
11)Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.

SELECT orden, subcategoria, count(producto)
FROM stg.order_line_sale as ols
LEFT JOIN stg.product_master as pm
ON ols.producto=pm.codigo_producto
GROUP BY orden, subcategoria
