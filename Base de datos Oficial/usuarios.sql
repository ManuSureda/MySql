/* Sistema MOBILE y Sistema WEB */
	create user 'web'@'localhost' identified by '1234'; /*'web'@'10.0.1.%'*/

	/* Login de clientes */
	grant select(dni,user_password) on backoffice.users to 'web'@'localhost';
    
	/* Consulta de llamadas del usuario logueado por rango de fechas y consulta de destinos más llamados por el usuario. */ 
	grant select on backoffice.v_calls_info to 'web'@'localhost';

	/* Consulta de facturas del usuario logueado por rango de fechas. */
	grant select on backoffice.v_bills_info to 'web'@'localhost';


	/* Sistema Backoffice */ 
	create user 'backoffice'@'localhost' identified by '1234';

	/* Login de empleados */
	grant select(dni,user_password) on backoffice.users to 'backoffice'@'localhost';

	#Permisos para el usuario
    grant insert,update,delete on backoffice.users to 'backoffice'@'localhost';
	grant insert,delete on backoffice.provinces to 'backoffice'@'localhost';
    grant insert,delete on backoffice.cities to 'backoffice'@'localhost';
	grant insert,update(available,line_type),delete on backoffice.phone_lines to 'backoffice'@'localhost';
    
    #Manejo de clientes
    GRANT EXECUTE ON PROCEDURE backoffice.sp_insert_client_and_phone_lines TO 'backoffice'@'localhost';
    GRANT EXECUTE ON PROCEDURE backoffice.sp_client_line_suspend TO 'backoffice'@'localhost';
	GRANT EXECUTE ON PROCEDURE backoffice.sp_modify_client TO 'backoffice'@'localhost';
	GRANT EXECUTE ON PROCEDURE backoffice.sp_client_reactive TO 'backoffice'@'localhost';
		#Delete user (Opcional)
		GRANT EXECUTE ON PROCEDURE backoffice.sp_delete_user TO 'backoffice'@'localhost';
    
	#Alta, baja, suspension de lineas
    GRANT EXECUTE ON PROCEDURE backoffice.sp_phone_lines TO 'backoffice'@'localhost';
    GRANT EXECUTE ON PROCEDURE backoffice.sp_phone_lines_by_dni TO 'backoffice'@'localhost';
	GRANT EXECUTE ON PROCEDURE backoffice.sp_line_suspend TO 'backoffice'@'localhost';
    GRANT EXECUTE ON PROCEDURE backoffice.sp_modify_phone_line TO 'backoffice'@'localhost';
	GRANT EXECUTE ON PROCEDURE backoffice.sp_line_active TO 'backoffice'@'localhost';
    	#Delete line (Opcional)
    GRANT EXECUTE ON PROCEDURE backoffice.sp_delete_line TO 'backoffice'@'localhost';
	
    #Consultas de tarifas
    grant select on backoffice.v_tariffs_info to 'backoffice'@'localhost';
    
     #Consultas de llamadas
	grant select on backoffice.v_calls_info to 'backoffice'@'localhost';
    
     #Consultas de facturacion
    grant select on backoffice.v_bills_info to 'backoffice'@'localhost';


/* Sistema Infraestructura - Administrador */ 
create user 'admin'@'localhost' identified by '1234';

	#Login de admin
	grant select(dni,user_password) on backoffice.users to 'admin'@'localhost';

	#Crear empleado
    grant insert on backoffice.users to 'admin'@'localhost';
    GRANT EXECUTE ON PROCEDURE backoffice.sp_insert_employee TO 'admin'@'localhost';
    
	#Consulta de empleado
	grant select on backoffice.v_employee_info to 'admin'@'localhost';
    
    #Crear tarifa y modificar
    grant insert,update on backoffice.tariffs to 'admin'@'localhost';
    GRANT EXECUTE ON PROCEDURE backoffice.sp_create_tariff_by_id_city TO 'admin'@'localhost';
    GRANT EXECUTE ON PROCEDURE backoffice.sp_modify_tariff_by_id TO 'admin'@'localhost';
    
    #Realizar una llamada
    grant insert on backoffice.calls to 'admin'@'localhost';
    GRANT EXECUTE ON PROCEDURE backoffice.sp_insert_call TO 'admin'@'localhost';


#CREAR USUARIO
CREATE USER 'nombreUser'@'localhost'
	IDENTIFIED BY 'password';

#ASIGNAR PRIVILEGIOS
/*
GRANT privilegio(SELECT (A,B,C...), INSERT... O ALL) 
	ON LA_BASEDE_DATOS.LA_TABLA
    TO 'nombreUser'@'localhost'
    y aga podes agregar WITH GRANT OPTION o no y poner el ; en la linea de arriba

SHOW GRANTS FOR 'nombreUser'@'localhost';º
    
    
*/