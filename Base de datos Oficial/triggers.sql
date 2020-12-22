/*------------------------------------------------------------------------------------*/

			/*TRIGGERS*/
			/*Insercion de triggers en la base de datos*/
/*------------------------------------------------------------------------------------*/

		/*Verifica que el string solo contenga enteros*/
CREATE FUNCTION isNumeric (sIn varchar(1024)) 
RETURNS tinyint deterministic
RETURN sIn REGEXP '^-?[0-9]+$';

			/*TRIGGERS TARIFFS*/
			/*Antes de insertar una tarifa*/

DELIMITER $$
CREATE TRIGGER tbi_tariffs before insert on tariffs FOR EACH ROW
BEGIN
	declare vIdCityOrigin int default 0;
    declare vIdCityDestination int default 0;
    declare vIdTariff int default 0;
    
    SELECT ifnull(id_tariff,0) INTO vIdTariff FROM tariffs WHERE id_city_origin = new.id_city_origin AND id_city_destination = new.id_city_destination;
    
    SELECT ifnull(id_city,0) INTO vIdCityOrigin FROM cities WHERE id_city = new.id_city_origin;
    SELECT ifnull(id_city,0) INTO vIdCityDestination FROM cities WHERE id_city = new.id_city_destination;
    
	/*No verifico que el precio sea mayor que el costo por que considero que eso ya depende las estrategias o deciciones de la empresa*/
	if (vIdCityOrigin = 0 or vIdCityDestination = 0) then
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect tariff data', MYSQL_ERRNO = 10;
	end if;
    if (vIdTariff <> 0) then
    	signal sqlstate '45000' SET MESSAGE_TEXT = 'There is already a tariff for those cities ', MYSQL_ERRNO = 10;
	end if;
    if (new.price_per_minute < 0 or new.cost_per_minute < 0) then
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Price or cost cannot be negative ', MYSQL_ERRNO = 10;
	end if;
END
$$
DELIMITER ;


			/*Antes de modificar una tarifa*/
DELIMITER $$
CREATE TRIGGER tbu_tariffs before update on tariffs FOR EACH ROW
BEGIN

	if (new.price_per_minute < 0 or new.cost_per_minute < 0) then
    	signal sqlstate '45000' SET MESSAGE_TEXT = 'Cost or Price can not be lower than 0', MYSQL_ERRNO = 10;
	end if;
END
$$
DELIMITER ;

		/*Antes de eliminar una tarifa*/
DELIMITER $$
CREATE TRIGGER tbd_tariffs before delete on tariffs FOR EACH ROW
BEGIN
	if (old.id_city_origin <> 0 or old.id_city_destination <> 0) then
    	signal sqlstate '45000' SET MESSAGE_TEXT = 'Before deleting the tariff, you must delete the cities to which it refers', MYSQL_ERRNO = 10;
	end if;
END
$$
DELIMITER ;


/*------------------------------------------------------------------------------------*/
			/*TRIGGERS USERS*/
			/*Antes de insertar un usuario*/
            
DELIMITER $$
CREATE TRIGGER tbi_users before insert on users FOR EACH ROW
BEGIN
	declare vIdCity int default 0;
	declare vIdDni int default 0;
	declare vDniNumber int default 0;
	
    select ifnull(id_user,0) into vIdDni from users where dni = new.dni;
	select ifnull(c.id_city,0) into vIdCity from cities c where c.id_city = new.id_city;
    set vDniNumber = isNumeric(new.dni); 
    
    if(vIdCity = 0 or vIdDni <> 0 or vDniNumber = 0 )then 
		signal sqlstate '45000' SET MESSAGE_TEXT = "", MYSQL_ERRNO = 136;
	end if;
END
$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER tad_phone_lines after delete on users FOR EACH ROW
BEGIN
    delete from phone_lines where id_user = old.id_user;
END
$$
DELIMITER ;

/*------------------------------------------------------------------------------------*/
			/*TRIGGERS PHONE LINES*/
			/*Antes de insertar una linea telefonica*/
DELIMITER $$
CREATE TRIGGER tbi_phone_lines before insert on phone_lines FOR EACH ROW
BEGIN
	declare vIdUser int default 0;

	SELECT ifnull(u.id_user,0) INTO vIdUser FROM users u WHERE u.role_name = "Client" and u.available = 1 and u.id_user = new.id_user;
    
	if (vIdUser = 0) then
		SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect phone lines data', MYSQL_ERRNO = 1;
	end if;
END
$$
DELIMITER ;
/*------------------------------------------------------------------------------------*/
			/*TRIGGERS CALLS*/
			/*No permitir la insersion de llamadas cuyos datos no existan, ni que se realice la misma llamada
            ni tampoco que se permita la realizacion de una llamada entre misma linea telefonica, ni que la tarifa no exista, ni que la
            duracion sea negativa y que además, la fecha y hora de la llamada no debe ser futura.*/
DELIMITER $$
CREATE TRIGGER tbi_insert_call before insert on calls FOR EACH ROW
BEGIN
	declare vIdLineOrigin int default 0;
	declare vIdLineDestination int default 0;
    declare vIdBill int default 0;
    declare vIdCityOrigin int default 0;
    declare vIdCityDestination int default 0;
    declare vCall int default 0;
    declare vIdTariff int default 0;
    
    /*Comprobar que las lineas de origen y destino existan y además, esten disponibles*/
	SELECT ifnull(id_line,0) INTO vIdLineOrigin FROM phone_lines WHERE id_line = new.id_line_origin AND available = 1;
	SELECT ifnull(id_line,0) INTO vIdLineDestination FROM phone_lines WHERE id_line = new.id_line_destination AND available = 1;
    /*Comprobar que las ciudades de origen y destino existan*/
    SELECT ifnull(id_city,0) INTO vIdCityOrigin FROM cities WHERE id_city = new.id_city_origin;
    SELECT ifnull(id_city,0) INTO vIdCityDestination FROM cities WHERE id_city = new.id_city_destination;
    /*Comprobar que la tarifa exista*/
	SELECT ifnull(id_tariff,0) INTO vIdTariff FROM tariffs WHERE id_city_origin = vIdCityOrigin and id_city_destination = vIdCityDestination;
    
    /*Comprobar que no se realice la misma llamada*/
    set vCall = (select ifnull(c.id_call,0) from calls c 
    where (c.id_line_origin=vIdLineOrigin AND c.id_line_destination = vIdLineDestination AND c.call_date = new.call_date AND c.duration = new.duration));
    
    if (vIdTariff = 0 or new.duration < 0 or new.call_date > now() or vIdLineOrigin = 0 OR vIdLineDestination = 0 or vIdCityOrigin = 0 or vIdCityDestination = 0 or vCall <> 0 or
    #Comprobar que no se pueda realizar una llamada entre misma linea
    (new.id_line_origin = new.id_line_origin  AND new.id_line_destination = new.id_line_origin)) then
     	SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect call data', MYSQL_ERRNO = 1;
    end if;
END
$$
DELIMITER ;

