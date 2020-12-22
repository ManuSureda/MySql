/*------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------*/
			/*BACKOFFICE*/
			/*Permitir el manejo de clientes, líneas y tarifas*/
/*------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------------*/
			/*Alta de Empleado*/
DELIMITER $$
CREATE PROCEDURE sp_insert_employee(pName varchar(50), pLastName varchar(50), pDni varchar(9), pUserPassword varchar(50), pIdCity int, out idEmployee int)
BEGIN 

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect user data', MYSQL_ERRNO = 136;
    END;    

	INSERT INTO users(name, last_name, dni, user_password, role_name, id_city)      
	VALUES (pName, pLastName, pDni, pUserPassword, "Employee", pIdCity);
    set idEmployee = last_insert_id();
END;
$$
DELIMITER ;

/*------------------------------------------------------------------------------------*/
			/*Manejo de Clientes*/
/*------------------------------------------------------------------------------------*/
/*FUNCION*/
/*Funcion para generar un numero de linea random*/
DELIMITER $$
CREATE FUNCTION getPhoneLineRandom()
RETURNS VARCHAR (8)
DETERMINISTIC
BEGIN
    DECLARE vRandom varchar(8);
	DECLARE flag int default 1;
    
	while (flag = 1) do
		SELECT FLOOR(RAND()*(7000000 - 4500000+1)+4500000) INTO vRandom;
		select exists(select number_line from phone_lines where number_line = vRandom) INTO flag;
    end while;
    
    return vRandom;
END
$$;
DELIMITER $$

/*Alta de cliente y su linea telefonica*/
DELIMITER $$
CREATE PROCEDURE sp_insert_client_and_phone_lines(pName varchar(50), pLastName varchar(50), pDni varchar(9), pUserPassword varchar(50), pIdCity int, pLineType varchar(50), out idUser int)
BEGIN 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect user data', MYSQL_ERRNO = 136;
        ROLLBACK;
    END;    
	
    start transaction;
		INSERT INTO users(name, last_name, dni, user_password, role_name, id_city)      
		VALUES (pName, pLastName, pDni, pUserPassword, "Client", pIdCity);
		set idUser = last_insert_id();
		call sp_phone_lines(idUser, pLineType, @idLine);
	commit;
END;
$$
DELIMITER ;

			/*Suspension de un cliente y las lineas telefonicas vinculadas*/
DELIMITER $$
CREATE PROCEDURE sp_client_line_suspend(pDni varchar(8))
BEGIN 
	declare vIdUser int default 0;
    
	start transaction;
    
	SELECT ifnull(u.id_user,0) INTO vIdUser FROM users u WHERE u.dni = pDni and u.available = 1 and u.role_name = "Client";
    if (vIdUser = 0) then
		rollback;
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Inexistent client or data client is incorrect', MYSQL_ERRNO = 1;
	else
		UPDATE users SET available = 0 where id_user = vIdUser;
        UPDATE phone_lines SET available = 0 where id_user = vIdUser;
        commit;
	end if;
END;
$$
DELIMITER ;

		/*Reactivar un cliente y las lineas telefonicas vinculadas a ese usuario*/
DELIMITER $$
CREATE PROCEDURE sp_client_reactive(pDni varchar(8))
BEGIN 
    declare vIdUser int default 0;

    start transaction;

    SELECT ifnull(u.id_user,0) INTO vIdUser FROM users u WHERE u.dni = pDni and u.available = 0 and u.role_name = "Client";
    if (vIdUser = 0) then
        rollback;
        SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Inexistent client or data client is incorrect', MYSQL_ERRNO = 1;
    else
        UPDATE users SET available = 1 where id_user = vIdUser;
        UPDATE phone_lines SET available = 1 where id_user = vIdUser;
        commit;
    end if;
END;
$$
DELIMITER ;

			/*Modificar un cliente*/
DELIMITER $$
CREATE PROCEDURE sp_modify_client(pIdUser int, pName varchar(50), pLastName varchar(50), pDni varchar(8),pPassword varchar(50), pIdCity int)
BEGIN 
	declare vIdUser int default 0;
    declare vIdCity int default 0;
    declare vIdDni int default 0;
	declare aux tinyint default 0;

	SELECT ifnull(u.id_user,0) INTO vIdUser FROM users u WHERE u.role_name = "Client" and u.available = 1 and u.id_user = pIdUser;
    SELECT ifnull(c.id_city,0) INTO vIdCity FROM cities c WHERE c.id_city = pIdCity;
    select ifnull(u.dni,0) INTO vIdDni from users u where u.dni = pDni AND id_user <> pIdUser;
    
    
    set aux = isNumeric(pDni);
    
    start transaction;
    
    if (vIdUser = 0 or vIdCity = 0 or aux = 0 or vIdDni <> 0) then
		rollback;
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect client data', MYSQL_ERRNO = 1;
	else
		UPDATE users
		SET name=pName, last_name=pLastName, dni=pDni, user_password=pPassword, id_city=pIdCity where id_user = pIdUser and role_name = "Client";
		commit;
	end if;
END;
$$
DELIMITER ;

		/*Eliminar un cliente con su linea (Eliminado fisico - Opcional)*/
DELIMITER $$
CREATE PROCEDURE sp_delete_user(pDni varchar(8))
BEGIN 
    declare vIdUser int default 0;
    SELECT ifnull(u.id_user,0) INTO vIdUser FROM users u WHERE u.dni = pDni and u.role_name = "Client";
    if (vIdUser <> 0) then
        SET foreign_key_checks = 0;
        delete from users where id_user = vIdUser;
        SET foreign_key_checks = 1;
    else
        SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Inexistent user', MYSQL_ERRNO = 6;
    end if;
END;
$$
DELIMITER ;

/*------------------------------------------------------------------------------------*/
            /*Manejo de Lineas*/
/*------------------------------------------------------------------------------------*/

            /*Agregar lineas telefonicas al cliente (Solo clientes)*/
DELIMITER $$
CREATE PROCEDURE sp_phone_lines(pIdUser int, plineType varchar(50), out idLine int)
BEGIN 
	declare vNumberLine varchar(8);
	declare aux tinyint default 0;
    
    set vNumberLine = getPhoneLineRandom(); 
	
	if (plineType = "Mobile" or plineType = "Home") then 
		set aux = 1;
	end if;

	if (aux = 0) then
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Phone line type is incorrect', MYSQL_ERRNO = 13;
    end if;
	INSERT INTO phone_lines(number_line,line_type,id_user) 
	VALUES (vNumberLine, plineType, pIdUser);
    
    set idLine = last_insert_id();
END;
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_phone_lines_by_dni(pDni varchar(15), plineType varchar(50), out idLine int)
BEGIN 
	declare vNumberLine varchar(8);
	declare aux tinyint default 0;
    declare vIdUser int default 0;

	select ifnull(u.id_user,0) INTO vIdUser FROM users u where u.dni = pDni;
    
    set vNumberLine = getPhoneLineRandom(); 
	
	if (plineType = "Mobile" or plineType = "Home") then 
		set aux = 1;
	end if;

	if (aux = 0) then
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Phone line type is incorrect', MYSQL_ERRNO = 13;
    end if;
    if (vIdUser = 0) then
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect dni data', MYSQL_ERRNO = 13;
	end if;
    
	INSERT INTO phone_lines(number_line,line_type,id_user) 
	VALUES (vNumberLine, plineType, vIdUser);
    
    set idLine = last_insert_id();
END;
$$
DELIMITER ;


			/*Desactivar una linea (Opcional)*/
DELIMITER $$
CREATE PROCEDURE sp_line_suspend(pIdLine int)
BEGIN 
	declare vIdLine int default 0;
	SELECT ifnull(pl.id_line,0) INTO vIdLine FROM phone_lines pl WHERE pl.id_line = pIdLine and pl.available = 1;
	if (vIdLine = 0) then
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Inexistent line or this line is not active', MYSQL_ERRNO = 1;
	else
		UPDATE phone_lines SET available = 0 where id_line = pIdLine;
	end if;
END;
$$
DELIMITER ;

			/*Eliminar una linea (Opcional)*/
DELIMITER $$
CREATE PROCEDURE sp_delete_line(pIdLine int)
BEGIN 
    declare vIdLine int default 0;
	SELECT ifnull(pl.id_line,0) INTO vIdLine FROM phone_lines pl WHERE pl.id_line = pIdLine;
	if (vIdLine = 0) then
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Inexistent line', MYSQL_ERRNO = 15;
	else
		SET foreign_key_checks = 0;
		delete from phone_lines where id_line = 3;
		SET foreign_key_checks = 1;
	end if;
END;
$$
DELIMITER ;


			/*Activar una linea*/
DELIMITER $$
CREATE PROCEDURE sp_line_active(pIdLine int)
BEGIN 
    declare vIdUser int default 0;
    declare vIdLine int default 0;
    declare vAvailable tinyint default 0;
    SELECT ifnull(pl.id_line,0) INTO vIdLine FROM phone_lines pl WHERE pl.id_line = pIdLine and pl.available = 0;
    SELECT ifnull(pl.id_user,0) INTO vIdUser FROM phone_lines pl WHERE pl.id_line = vIdLine limit 1;
    SELECT u.available INTO vAvailable FROM users u WHERE u.id_user = vIdUser;
    if (vIdLine <> 0 and vIdUser <> 0 AND vAvailable <> 0) then
        UPDATE phone_lines SET available = 1 where id_line = pIdLine;
    else
        SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Inexistent line or this line is active', MYSQL_ERRNO = 1;
    end if;
END;
$$
DELIMITER ;

			/*Modificar una linea*/
DELIMITER $$
CREATE PROCEDURE sp_modify_phone_line(pIdLine int, pPline_type varchar(50), pId_user int)
BEGIN 
    declare vIdUser int default 0;
    declare vIdLine int default 0;
    declare vAvailable tinyint default 0;
    declare aux tinyint default 0;
    
    SELECT ifnull(pl.id_line,0) INTO vIdLine FROM phone_lines pl WHERE pl.id_line = pIdLine and pl.available = 1;
    SELECT ifnull(pl.id_user,0) INTO vIdUser FROM phone_lines pl WHERE pl.id_line = vIdLine AND id_user = pId_user limit 1;
    SELECT u.available INTO vAvailable FROM users u WHERE u.id_user = vIdUser;
    
    if (pPline_type = "Mobile" or pPline_type = "Home") then 
		set aux = 1;
	end if;
    
    if (vIdLine <> 0 and vIdUser <> 0 AND vAvailable <> 0 AND aux = 1) then
        UPDATE phone_lines SET line_type = pPline_type where id_line = pIdLine;
    else
        SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect phone line data', MYSQL_ERRNO = 12;
    end if;
END;
$$
DELIMITER ;
            

/*------------------------------------------------------------------------------------*/
            /*Manejo de Tarifas*/
/*------------------------------------------------------------------------------------*/

DELIMITER $$
CREATE PROCEDURE sp_create_tariff_by_id_city(pOriginCityId Integer, pDestinationCityId integer, pPrice_per_minute long, pCost_per_minute long, out idTariff int)
BEGIN 
    start transaction;
		Insert into tariffs (id_city_origin, id_city_destination, price_per_minute, cost_per_minute) 
		values (pOriginCityId, pDestinationCityId, pPrice_per_minute, pCost_per_minute);
    commit;
    set idTariff = last_insert_id();
END;
$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE sp_modify_tariff_by_id(pIdTariffId Integer, pPrice_per_minute long, pCost_per_minute long)
BEGIN 
    
    declare vIdTariff2 int default 0;
    SELECT ifnull(id_tariff,0) INTO vIdTariff2 FROM tariffs WHERE id_tariff = pIdTariffId;
    
    
    if (vIdTariff2 = 0) then
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect tariff data', MYSQL_ERRNO = 10;
	end if;
    
    start transaction;
	
	UPDATE tariffs SET price_per_minute = pPrice_per_minute, cost_per_minute = pCost_per_minute 
    WHERE id_tariff = pIdTariffId;
    
    commit;
END;
$$
DELIMITER ;

