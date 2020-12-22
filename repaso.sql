#REPASO

#TRIGGERS
/*
CREATE TRIGGER nombre del trigger BEFORE/AFTER INSERT/UPDATE/DELETE ON tabla FOR EACH ROW
BEGIN
	podes declarar variables
	CUERPO
    SI ES UN INSERT O UPDATE TENES ACCESO A new. y old. 
    si es DELETE solo old.
    
    OBIAMENTE 
    SI VAS A HACER UN TRIGGER DE INSERT NO LO PODES USAR PARA INSERTAR EN LA MISMA TABLA
    SI VAS A HACER UN TRIGGER DE UPDATE NO LO PODES USAR PARA UPDATEAR EN LA MISMA TABLA
    SI VAS A HACER UN TRIGGER DE DELETE NO LO PODES USAR PARA DELETEAR EN LA MISMA TABLA
END
*/
drop TRIGGER tbi_clientes;
DELIMITER $$
CREATE TRIGGER tbi_clientes BEFORE INSERT ON clientes FOR EACH ROW
BEGIN
	declare v_id Integer default 0;
    set v_id = new.id_cliente;
    IF 1 = 2 THEN
		signal sqlstate '45000' set message_text = "mensaje", mysql_errno = 1;
	END IF;
    #MAAAAAAAAAAAAAL
    #UPDATE clientes SET razon_social = 'asd' where id_cliente = 1;
    #BIEEEEEEEEEEEEN
    SET new.razon_social = "jamon";
    #ESTO TAMBIEN SE PUEDO BRO
    UPDATE productos set stock = 10 where id_producto > 0;
END
$$
DELIMITER ;

#CURSORES
/*
DECLARE vFinished Integer default 0;es una variable que te va a ayudar para saber si te fetcheo info vacia.
DECLARE cur_nombre_del_cursor CURSOR FOR la query del cursor (select papapa from x_tabla);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;
OPEN cur_nombre_del_cursor;
get_x : LOOP
	fetch cur_nombre_del_cursor INTO (las variables aux que uses para guardar la info que trae el cursor);
    IF vFinished = 1 THEN
		LEAVE get_x;
	END IF;
	cuerpo del LOOP
END LOOP get_x;

briconsejo del dia...
si el cursor haces por ejemplo select bla bla bla from tabla x WHERE id = (variable pasada por parametro) o (variable declarada)
AAAAANTES DE ABRIR EL CURSOR carga esa variable ej:
declare v_id_aux integer default 0;
declare cur_hola CURSOR FOR select nombre from x where id = v_id_aux;
set v_id_aux = 22;
OPEN cur_hola; ahora si todo bien todo correcto
y si manejas dos cursores trata de hacer un set vFinished = 0 :
 open cur_jugador; <---
        get_jugador : LOOP 
			fetch cur_jugador into vId_jugador,vId_equipo_aux,vNombre,vApellido;
			IF vFinished = 1 THEN #si se quedo sin registros que traer, salgo del loop
				close cur_jugador; <---
                set vFinished = 0; <---
				LEAVE get_jugador;
			END IF;
*/

#TRANSACCIONES
/*
START TRANSACTION;
START TRANSACTION ISOLATION LEVEL READ UNCOMMITED | READ COMMITED | REPEATABLE READ | SERIALIZABLE
commit; o rollback;
*/
#mira guiaTransacciones

#FUNCIONES / VISTAS
###no tengo ningun ejercicio, es solo practica random de funciones...
#por default si no especificas el deterministic queda en NON deterministic
#DETERMINISTIC es que si recive los mismos parametros SIEMPRE va a devolver el mismo resulado
#NON DETERMINISTIC quiere decir que no siempre va a devolver lo mismo
/*
CREATE FUNCTION nombre_funcion (a tipo, b tipo, j Integer, k varchar(10)....) 
RETURNS el tipo de retorno Integer/Varchar/etc
DETERMINISTIC o NON DETERMINISTIC (<-- ese es por default)
*/

DELIMITER $$
CREATE FUNCTION get_sum(a Integer, b Integer)
RETURNS Integer
DETERMINISTIC #NON DETERMINISTIC por default
BEGIN
	declare ans Integer default 0;
    set ans = a + b;
    return ans;
END
$$
DELIMITER ;

select get_sum(1,2);

#PERFORMANCE

#SEGURIDAD
/*
CREATE USER 'usuario'@'localhost' identified by 'password'; 'web'@'10.0.1.%'
GRANT ACCION(que,parte,de,accion) ON basededato.tabla TO 'usuario'@'localhost';
GRANT SELECT/INSERT/UPDATE(id,nombre) ON myBD.personas TO 'usuario'@'localhost';
GRANT privilegio(SELECT (A,B,C...), INSERT... O ALL) 
	ON LA_BASEDE_DATOS.LA_TABLA
    TO 'nombreUser'@'localhost'
    y aga podes agregar WITH GRANT OPTION o no y poner el ; en la linea de arriba

SHOW GRANTS FOR 'nombreUser'@'localhost';º

PARA QUE PUEDA ACCEDER A SP:
GRANT EXECUTE ON PROCEDURE nombreBD.sp_nombre_del_sp TO 'nombreUser'@'localhost';
   
*/

#NOSQL
/*
Database -> Database
Collection -> Table
Document -> Row
Field -> Column
Value -> Value
http://campus.mdp.utn.edu.ar/pluginfile.php/12270/mod_resource/content/1/mongo.sql
*/
