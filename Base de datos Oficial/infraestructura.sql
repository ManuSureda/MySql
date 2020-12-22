/*------------------------------------------------------------------------------------*/
/*INFRAESTRUCTURA*/
/*Enviar la información de llamadas a la base de datos
1) Linea de origen
2) Linea de destino
3) Duracion de la llamada
4) Fecha y hora de la llamada	
*/

DELIMITER $$
CREATE PROCEDURE sp_insert_call(pLineOrigin varchar(11), pLineDestination varchar(11), pDuration long, pCallDate datetime, out idCall int)
BEGIN
	declare vIdCityOrigin int default 0;
    declare vIdCityDestination int default 0;
    declare vTotalPrice long default 0;
    declare vTotalCost float default 0;
	declare vIdUser int default 0;

    declare vOriginPrefix varchar(4);
    declare vOriginNumber varchar(7);
    declare vDestinationPrefix varchar(4);
    declare vDestinationNumber varchar(7);
    declare vIdLineOrigin int default 0;
	declare vIdLineDestination int default 0;
        
    select substring(pLineOrigin, 1, 4) INTO vOriginPrefix; 
	select substring(pLineOrigin, 5, 11) INTO vOriginNumber; 
    select substring(pLineDestination, 1, 4) INTO vDestinationPrefix; 
	select substring(pLineDestination, 5, 11) INTO vDestinationNumber; 

	/*CIUDAD DE LA LINEA DE ORIGEN*/
	select ifnull(pl.id_user,0) into vIdUser from phone_lines pl where pl.number_line = vOriginNumber;
    select u.id_city into vIdCityOrigin from users u where u.id_user = vIdUser;
	/*CIUDAD DE LA LINEA DE DESTINO*/
    select ifnull(pl.id_user,0) into vIdUser from phone_lines pl where pl.number_line = vDestinationNumber;
    select u.id_city into vIdCityDestination from users u where u.id_user = vIdUser;
    
    /*COMPROBAMOS EL PREFIX*/
    if (vOriginPrefix = (select c.prefix from cities c where c.id_city = vIdCityOrigin) AND vDestinationPrefix = (select c.prefix from cities c where c.id_city = vIdCityDestination) ) then
		/*ID LINEA ORIGEN*/
		select ifnull(pl.id_line,0) into vIdLineOrigin from phone_lines pl where pl.number_line = vOriginNumber;
		/*ID LINEA DESTINO*/
		select ifnull(pl.id_line,0) into vIdLineDestination from phone_lines pl where pl.number_line = vDestinationNumber;
		/*PRECIO TOTAL*/  
		select (t.price_per_minute * pDuration) into vTotalPrice from tariffs t where t.id_city_origin = vIdCityOrigin and t.id_city_destination = vIdCityDestination;
		/*COSTO TOTAL*/
		select (t.cost_per_minute * pDuration) into vTotalCost from tariffs t where t.id_city_origin = vIdCityOrigin and t.id_city_destination = vIdCityDestination;
		
		INSERT INTO calls(call_date, id_line_origin, id_line_destination, duration, total_price, total_cost, id_city_origin, id_city_destination, billed, id_bill)
		values (pCallDate, vIdLineOrigin, vIdLineDestination, pDuration, vTotalPrice, vTotalCost, vIdCityOrigin, vIdCityDestination, 0, null);
        set idCall = last_insert_id();
	else
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect number data', MYSQL_ERRNO = 10;
    end if;
END
$$
DELIMITER ;

/*---------*/
#call sp_insert_call("38335373558","00115657250",50,now(),@id);


