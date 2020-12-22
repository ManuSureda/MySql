
/* DESCRIPCION DE LA BASE DE DATOS 


Tenemos un sistema de ventas y de sueldos. 

Cada vendedor tiene un sueldo basico que cobra todos los meses y luego a este sueldo basico se le agrega un porcentaje de las ventas que haya realizado en el mes . Esto esta especificado en el campo sueldo_basico y porcentaje_comision de la tabla
VENDEDORES . Para calcular el sueldo se usa sueldo_basico + (total_ventas *  porcentaje_comision).

Se genera tambien una tabla de ventas que tiene las ventas que se hicieron sobre el sistema, la fecha , que cliente y que vendedor la realizaron. A su vez hay una tabla ITEMS_VENTAS que tiene el detalle de cada venta, que producto y cuanto se cobro.
Finalmente la tabla PRODUCTOS indica los productos que tenemos en nuestro sistemas y que pueden ser vendidos y adquiridos por nuestros clientes. Hay un campo STOCK que especifica la cantidad de ejemplares de este producto que posee la empresa. 
No se deberia poder vender estos productos sin tener stock.

En la tabla sueldo se corre un procesdo una vez por mes que calcula las ventas del mes por cada vendedor y llena los sueldos con la formula previamente especificada
*/

DROP DATABASE IF EXISTS ventas_sueldos;
CREATE DATABASE ventas_sueldos;
USE ventas_sueldos;

CREATE TABLE vendedores (id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
			nombre_vendedor VARCHAR(50) NOT NULL,
			cuil VARCHAR(20) NOT NULL,
			sueldo_basico FLOAT,
			porcentaje_comision FLOAT) ENGINE=INNODB;

CREATE TABLE clientes(id_cliente INT AUTO_INCREMENT PRIMARY KEY,
		      razon_social VARCHAR(50) NOT NULL,
		      cuit VARCHAR(20) NOT NULL) ENGINE=INNODB;
			
CREATE TABLE productos (id_producto INT AUTO_INCREMENT PRIMARY KEY,
			descripcion_producto VARCHAR(50),
			stock INT DEFAULT 0,
			precio_unitario FLOAT NOT NULL) ENGINE=INNODB;

CREATE TABLE ventas (id_venta INT AUTO_INCREMENT PRIMARY KEY,
		     id_cliente INT NOT NULL ,
		     id_vendedor INT NOT NULL,
		     fecha TIMESTAMP,
		     numero INT,
		     FOREIGN KEY fk_ventas_clientes (id_cliente) REFERENCES clientes(id_cliente),
		     FOREIGN KEY fk_ventas_vendedores (id_cliente) REFERENCES vendedores(id_vendedor)) ENGINE=INNODB;
CREATE TABLE items_ventas (id_venta INT NOT NULL,
			   id_producto INT NOT NULL,
			   cantidad FLOAT NOT NULL,
			   precio_unitario FLOAT NOT NULL,
			   precio_total FLOAT NOT NULL,
			   PRIMARY KEY pk_item_ventas (id_venta,id_producto),
			   FOREIGN KEY fk_productos_ventas (id_producto) REFERENCES productos(id_producto),
			   FOREIGN KEY fk_items_ventas (id_venta) REFERENCES ventas(id_venta)
			    ) ENGINE=INNODB;

INSERT INTO productos(descripcion_producto, stock,precio_unitario)
VALUES ('Mouse estandar',50,1300),
       ('Mouse Inalambrico',100,5000),
       ('Teclado español',100,1340),
       ('Monitor LED 24',10,23000);

INSERT INTO clientes (razon_social, cuit) 
VALUES ('Michael Jordan SA','1'),
       ('Roger Federer SA','2'),
       ('Marcelo Tinelli SA','3'),
       ('Alberto Fernandez SA','4');

INSERT INTO vendedores(nombre_vendedor,cuil,sueldo_basico,porcentaje_comision)
VALUES ('Rick Grimes','11',50000,0.05),
       ('Walter White','12',90000,0.07);

INSERT INTO ventas (id_cliente, id_vendedor,fecha,numero) VALUES
(1,1,NOW(),1);
INSERT INTO ventas (id_cliente, id_vendedor,fecha,numero) VALUES
(2,2,NOW(),2);


 INSERT INTO items_ventas VALUES (1,1,1,50,50),(1,2,3,100,300);
 INSERT INTO items_ventas VALUES (2,2,1,50,50),(2,3,3,100,300);
 
 
 CREATE INDEX idx_ventas ON ventas (id_cliente,fecha asc) BTREE;