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
