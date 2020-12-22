# TEST

#TARIFFS

/*Empleados*/
select * from v_employee_info;
/*Clientes*/
select * from v_client_info;
/*Llamadas*/
explain select * from v_calls_info;
select * from v_calls_info;
/*Facturas*/
select * from v_bills_info;
/*Tarifas*/
select * from v_tariffs_info;

select * from cities;

#CREARLA
CALL sp_create_tariff_by_id_city(1,8,5,2,@id); #ok

#no repetir tarifas
CALL sp_create_tariff_by_id_city(1,8,5,2,@id); #ok

#ciudad q no existe
CALL sp_create_tariff_by_city_name(1,200,5,2,@id);#OK

CALL sp_create_tariff_by_city_name(200,1,5,2,@id);#OK

CALL sp_create_tariff_by_city_name(200,200,5,2,@id);#OK


#costo Y PRECIO QUE NO SE NEGATIVO
CALL sp_create_tariff_by_id_city(1,9,-5,2,@id); #ok
CALL sp_create_tariff_by_id_city(1,9,5,-2,@id); #ok
CALL sp_create_tariff_by_id_city(1,9,-5,-2,@id); #ok

#modificar
call sp_modify_tariff_by_id(1,10,2);#ok

#no modificar negativo
call sp_modify_tariff_by_id(1,-4,2);#ok
call sp_modify_tariff_by_id(1,4,-2);#ok
call sp_modify_tariff_by_id(1,-4,-2);#ok

#modificar algo que no existe
call sp_modify_tariff_by_id(200,4,2);#ok

#no te deje borrar tarifas 
delete from tariffs where id_tariff = 1;#ok


#--------------------------------------------CLIENTES

#CREAR CLIENTE
call sp_insert_client_and_phone_lines("JUAN", "RAMON", "42231231", "marian", 2, "Home", @id);#OK

#REPETIR DNI 
call sp_insert_client_and_phone_lines("Palo", "Kell", "42231232", "marian", 2, "Home", @id);#OK

#ciudad no existe
call sp_insert_client_and_phone_lines("Palo", "Kell", "42231232", "marian", 2, "Home", @id);#OK

#tipo no existe
call sp_insert_client_and_phone_lines("Palo", "Kell", "42231232", "marian", 2, "jamon", @id);#OK
call sp_insert_client_and_phone_lines("Palo", "Kell", "-42231230", "marian", 2, 1, @id);#OK

#dni sin letras
call sp_insert_client_and_phone_lines("Palo", "Kell", "jamon", "marian", 2, "Home", @id);#OK

#dni muy grande
call sp_insert_client_and_phone_lines("Palo", "Kell", "4223123211", "marian", 2, "Home", @id);#OK

#dni negativo
call sp_insert_client_and_phone_lines("Palo", "Kell", "-42231230", "marian", 2, "Home", @id);#OK

call sp_insert_client_and_phone_lines("Palo", "Kell", -4223123011, "marian", 2, "Home", @id);#OK

#SUSPENDE - SI YA ESTA DESACTIVADO NO LO DESACTIVA
CALL sp_client_line_suspend("42231232");#OK
SELECT * FROM V_CLIENT_INFO;
SELECT * FROM USERS;
select * from phone_lines;

#REACTIVE - SI YA ESTA ACTIVO NO LO ACTIVA
CALL sp_client_reactive("42231232");#OK
SELECT * FROM V_CLIENT_INFO;
SELECT * FROM USERS;


#MODIFICAR CLIENTE
CALL sp_modify_client(5 , "Palo", "Kell", "40831340", "MAMA" , 1);#ok

CALL sp_modify_client(2 , "MODIFY", "MODI", "42231232", "MAMA" , 1);#ok

#MODIFICAR: id mal
#pIdUser int, pName varchar(50), pLastName varchar(50), pDni varchar(8),pPassword varchar(50), pIdCity int, pLineType varchar(50)
CALL sp_modify_client(700, "MODIFY", "MODI", "42231232", "MAMA" , 1);#ok

#INTENTAR MODIFICAR UN EMPLEADO
CALL sp_modify_client(6 , "MODIFY", "MODI", "42231232", "MAMA" , 1);#ok

#MODIFICAR CIUDAD NO EXISTE
CALL sp_modify_client(2 , "MODIFY", "MODI", "42231232", "MAMA" , 800);#ok

#QUE EL DNI ESTE MAL
CALL sp_modify_client(2 , "MODIFY", "MODI", "asASa", "MAMA" , 1);#ok


#--------------------------------------------EMPLEADO
call sp_insert_employee("Santiago", "Labatut", "4111111", "admin123", 1, @id);#OK

#REPETIR
call sp_insert_employee("Santiago", "Labatut", "41686701", "admin123", 1, @id);#OK

#CIUDAD INEXISTENTE 
call sp_insert_employee("Santiago", "Labatut", "41686701", "admin123", -5, @id);#OK

#dni mal
call sp_insert_employee("Santiago", "Labatut", "asdasd", "admin123", 1, @id);#OK



#--------------------------------------------PHONE_LINES
#CREAR 
call sp_phone_lines(5,"Mobile",@id);#OK

select * from phone_lines;
#Crear por dni
call sp_phone_lines_by_dni("40831340","Home",@id);#ok

#DNI MAL
call sp_phone_lines_by_dni("f","Home",@id);#ok

call sp_phone_lines_by_dni("40","Home",@id);#ok

#SI DESACTIVAS UN USUARIO DEBERIA DESACTIVAR TODAS SUS PHONE_LINES
CALL sp_client_line_suspend(42231232);#OK
CALL sp_client_reactive("42231232");#OK

# sp_modify_phone_line(pIdLine int, pPline_type varchar(50), pId_user int)
select * from phone_lines;
#pIdLine int, pPline_type varchar(50), pId_user int

#MODIFICAR LINEA
call sp_modify_phone_line(1,"Mobile",2);#OK
call sp_modify_phone_line(1,"Mobile",2);#OK


#LINEA MAL
call sp_modify_phone_line(-5,"Mobile",2);#OK

#TIPO MAL
call sp_modify_phone_line(1,"F",2);#OK

#id line no corresponde a ese user
call sp_modify_phone_line(1,"Mobile",80);#OK

SELECT * FROM phone_lines;
#SUSPENDER LINEA 
CALL sp_line_suspend(1);#OK

#SUSPENDER LINEA YA SUSPENDIDA
CALL sp_line_suspend(1);#OK

#LINEA INEXISTENTE
CALL sp_line_suspend(-1);#OK

#REACTIVAR LINEA
CALL sp_line_active(1);#OK

#REACTIVAR UNA YA ACTIVA
CALL sp_line_active(1);#OK

#-----------------------------------------------------CALLS
SELECT * FROM v_calls_info;
SELECT * FROM v_client_info;
SELECT * FROM Phone_lines;
#CRAR
#sp_insert_call(pLineOrigin varchar(11), pLineDestination varchar(11), pDuration long, pCallDate datetime, out idCall int)
CALL sp_insert_call("00114503412","02214901609",10,now(),@id);#OK

#LINEAS MAL
CALL sp_insert_call("A","02215751062",10,now(),@id);#OK
CALL sp_insert_call("02235049382","A",10,now(),@id);#OK
CALL sp_insert_call("A","A",10,now(),@id);#OK

#NUMERO BIEN PERO PREFIJO MAL
CALL sp_insert_call(" 5049382","02215751062",10,now(),@id);#OK
CALL sp_insert_call("02285049382","02215751062",10,now(),@id);#OK
CALL sp_insert_call("02215049382","02235751062",10,now(),@id);#OK

#DURATION NEGATIVO
CALL sp_insert_call("02235049382","02215751062",-5,now(),@id);#OK

#TIEMPO FUTURO
CALL sp_insert_call("02235049382","02215751062",5,"2020-06-30 16:15:50",@id);#OK

#LLAMADA CUANDO LA TARIFA TODABIA NO FUE CARGADA 
select * from v_tariffs_info;
SELECT * FROM v_client_info;
CALL sp_insert_call("02235049382","38334591611",5,NOW(),@id);#OK


CALL sp_insert_call("02235049382","02215751062","A",now(),@id);#OK


#LLAMAR A DESACTIVADO Y VICEVERSA 
SELECT * FROM PHONE_LINES;
CALL sp_insert_call("02235049382","02215751062",10,now(),@id);#OK
CALL sp_insert_call("02215751062","02235049382",10,now(),@id);#OK



#-----------------------------------------------------BILLS
CALL sp_load_bills();#OK
SELECT * FROM V_BILLS_INFO;
select * from bills;

CALL sp_pay_bills(23);#ok






