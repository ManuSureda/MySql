
/* DESCRIPCION DE LA BASE DE DATOS 


Tenemos un sistema de ventas y de sueldos. 

Cada vendedor tiene un sueldo basico que cobra todos los meses y luego a este sueldo basico se le agrega un porcentaje de las ventas que haya realizado en el mes .
 Esto esta especificado en el campo sueldo_basico y porcentaje_comision de la tabla VENDEDORES .
 Para calcular el sueldo se usa sueldo_basico + (total_ventas *  porcentaje_comision).

Se genera tambien una tabla de ventas que tiene las ventas que se hicieron sobre el sistema, la fecha , que cliente y que vendedor la realizaron. A su vez hay una tabla 
ITEMS_VENTAS que tiene el detalle de cada venta, que producto y cuanto se cobro.
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
 
 
#PROCEDURES
drop PROCEDURE sp_agregar_cliente;
DELIMITER $$
CREATE PROCEDURE sp_agregar_cliente(pRazon_social varchar(50),pCuit varchar(20),jamon varchar(10))
BEGIN
	/*DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Info mal cargada', MYSQL_ERRNO = 1;
	END;  */
	IF jamon <=> null or jamon = '' THEN
		signal sqlstate '45000' set message_text = 'jamon es nulo o vacio', mysql_errno = 2;
	END IF;
	insert into clientes (razon_social,cuit) values (pRazon_social, pCuit);
END
$$
DELIMITER ;

#generar una venta y sus item_venta pasando el nombre del cliente, vendedor e items. 
#aca practique de hacer un trigger que evite que el stock quede negativo
#cursores para poder recorrer la temp_productos
#procedure por obvias razones
#y si queres practicar transactions:
#abrite la consola en el wampp
#create la tabla temp con el 3º registro con mas cantidad que el stock disponible de ese producto
#llama al sp, te va a tirar error, pero va a haber cargado los primeros dos registros
#hace un select * from items_productos, vas a ver 2 id_venta el que le corresponda, con los dos primeros
#productos que si daba
#hace un rollback
#y otro select para ver como se borro todo.
drop TEMPORARY TABLE temp_productos;
CREATE TEMPORARY TABLE temp_productos(
	descripcion_producto VARCHAR(50),
    cantidad Integer
);

insert into temp_productos (descripcion_producto,cantidad) values ("Mouse estandar",2),
														("Mouse Inalambrico",1),
                                                        ("Teclado español",7),
                                                        ("Monitor LED 24",2);

DELIMITER $$
CREATE TRIGGER tbi_items_ventas BEFORE INSERT ON items_ventas FOR EACH ROW
BEGIN
	declare v_stock Integer default 0;
    select ifnull(stock,0) into v_stock from productos where id_producto = new.id_producto;
    IF v_stock = 0 THEN
		signal sqlstate '45000' set message_text = 'No hay stock', mysql_errno = 12;
	END IF;
    IF (v_stock - new.cantidad) < 0 THEN
		signal sqlstate '45000' set message_text = 'No hay suficientes existencias',mysql_errno =13;
	END IF;
    UPDATE productos set stock = v_stock - new.cantidad where id_producto = new.id_producto;
END
$$
DELIMITER ;

drop PROCEDURE sp_cargar_items_ventas;
call sp_cargar_items_ventas ('Rick Grimes','Michael Jordan SA',now());
select * from items_ventas;

drop PROCEDURE sp_cargar_items_ventas;
DELIMITER $$
CREATE PROCEDURE sp_cargar_items_ventas(pVendedor varchar(50),pCliente varchar(50),pFecha DateTime)
BEGIN
	#tabla ventas
    declare v_id_cliente Integer default 0;
    declare v_id_vendedor Integer default 0;
    declare v_numero Integer default 0;
    
    declare v_id_venta Integer default 0;
    #tabla items_ventas
    declare v_id_producto Integer default 0;
    #temp_productos
    declare v_desc_product varchar(50) default '';
    declare v_cant_product Integer default 0;
    #producto
    declare v_precio_unitario Float default 0;
    declare v_precio_total Float default 0;
    #cursor
    declare vFinished Integer default 0;
    declare cur_items cursor for select descripcion_producto,cantidad from temp_productos;
    declare continue handler for not found set vFinished = 1;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		rollback;
    END;
	start transaction;
    
    
    select ifnull(id_cliente,0) into v_id_cliente from clientes where razon_social = pCliente;
    select ifnull(id_vendedor,0) into v_id_vendedor from vendedores where nombre_vendedor = pVendedor;
    IF v_id_cliente = 0 OR v_id_vendedor = 0 OR pFecha <=> null THEN
		signal sqlstate '45000' set message_text = 'cliente/vendedor/fecha incorrectas', mysql_errno = 2;
	END IF;
    select ifnull(numero,1) into v_numero from ventas order by numero desc limit 1 ;
    set v_numero = v_numero + 1;
    
    insert into ventas (id_cliente,id_vendedor,fecha,numero) values (v_id_cliente,v_id_vendedor,pFecha,v_numero);
    set v_id_venta = last_insert_id();
    
    open cur_items;
    get_item : LOOP
		fetch cur_items into v_desc_product,v_cant_product;
		IF vFinished = 1 THEN
			LEAVE get_item;
		END IF;
        
        select ifnull(id_producto,0) into v_id_producto from productos where descripcion_producto = v_desc_product;
        IF v_id_producto = 0 THEN
			signal sqlstate '45000' set message_text = 'item mal cargado', mysql_errno = 3;
        END IF;
        
        select precio_unitario into v_precio_unitario from productos where id_producto = v_id_producto;
        set v_precio_total = v_precio_unitario * v_cant_product;
        
        insert into items_ventas (id_venta,id_producto,cantidad,precio_unitario,precio_total)
						  values (v_id_venta,v_id_producto,v_cant_product,v_precio_unitario,v_precio_total);
        
    END LOOP get_item;
    close cur_items;
    
    commit;
END
$$
DELIMITER ;

select ifnull(numero,1) from ventas order by numero desc limit 1;