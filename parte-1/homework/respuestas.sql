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
ORDER BY fecha_apertura    --**Qué pasa con las fechas null?

6)Cuales fueron las ultimas 5 ordenes de ventas?
SELECT *
FROM stg.order_line_sale
ORDER BY fecha DESC
LIMIT 5

7)Mostrar los primeros 10 registros del conteo de trafico por Super store ordenados por fecha.
SELECT tienda,fecha
FROM stg.super_store_count
ORDER BY fecha                        	--Está okk?
LIMIT 10

8)Cuales son los productos de electro que no son Soporte de TV ni control remoto.
SELECT *
FROM stg.product_master
WHERE categoria='Electro' and subsubcategoria NOT IN ('Soporte','Control remoto')

--?????????? Qué pasa si tengo subsubcategoría null? Trae el producto?

9)Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
SELECT *
FROM stg.order_line_sale
WHERE moneda='ARS'and venta > 100000

10)Mostrar todas las lineas de ventas de Octubre 2022.

SELECT *
FROM stg.order_line_sale
WHERE fecha LIKE '%-10-%' --????NO SIRVE POR EL TIPO DE DATO?

SELECT *
FROM stg.order_line_sale
WHERE EXTRACT(MONTH FROM fecha)=10   --También puede ser con un Between entre fechas

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
