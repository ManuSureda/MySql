/*------------------------------------------------------------------------------------*/

/*FACTURACIÓN*/
/*Proceso automático de facturación*/


/*ESTE ES EL PROCESO QUE SE VA A LLAMAR CADA 1º DE MES*/
DELIMITER $$
CREATE PROCEDURE sp_load_bills()
BEGIN
	DECLARE vCallsQuantity INTEGER DEFAULT 0;
    DECLARE vIdLine INTEGER DEFAULT 0;
    DECLARE vTotalPrice INTEGER DEFAULT 0;
    DECLARE vTotalCost INTEGER DEFAULT 0;
    DECLARE vIdBill INTEGER DEFAULT 0;
    
	DECLARE vFinished INTEGER DEFAULT 0;/*CURSOR PARA RECORRES TODAS LAS LINEAS*/
	DECLARE cur_lines CURSOR FOR SELECT	id_line FROM phone_lines group by id_line;/*ACA TAMBIEN CUENTAN LAS LINEAS QUE ESTAN DESACTIVADAS, LO QUE PODEMOS HACER ES UN WHERE = AVAILABLE <> 0 Y QUE AL MOMENTO DE SETEAR EN 0 UN AVAILABLE QUE LE GENERE LA FACTURA EN ESE MOMENTO?*/    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;
    OPEN cur_lines;

    get_lines : LOOP
		FETCH cur_lines INTO vIdLine;
        IF vFinished = 1 THEN /*preguntar si esto se podia hacer*/
			LEAVE get_lines;
		END IF;
        /*cuento la cantidad de llamadas realizadas no facturadas*/
        
        select ifnull(count(*),0) INTO vCallsQuantity FROM calls WHERE id_line_origin = vIdLine AND billed = 0;
        select ifnull(sum(total_price),0) INTO vTotalPrice FROM calls WHERE id_line_origin = vIdLine AND billed = 0;
        select ifnull(sum(total_cost),0) INTO vTotalCost FROM calls WHERE id_line_origin = vIdLine AND billed = 0;
		
        INSERT INTO bills(id_line, calls_quantity, total_cost, total_price, bill_date, expiration_date)
        VALUES (vIdLine,vCallsQuantity,vTotalCost,vTotalPrice, CURDATE(), (CURDATE() + INTERVAL 15 day));
		
        set vIdBill = last_insert_id();
        update calls SET billed = 1, id_bill = vIdBill WHERE id_line_origin = vIdLine AND billed = 0; 
        
    END LOOP get_lines;
    CLOSE cur_lines;
END
$$
DELIMITER ;

SET GLOBAL event_scheduler = ON;
CREATE EVENT IF NOT EXISTS e_load_bills
ON SCHEDULE EVERY 1 MONTH STARTS '2020-07-01'
DO
	call sp_load_bills;
SET GLOBAL event_scheduler = OFF;
#call sp_load_bills;

DELIMITER $$
CREATE PROCEDURE sp_pay_bills(pIdBill int)
BEGIN
	declare vIdBill int default 0;
    declare vPaid tinyint default 0;
    
    select ifnull(id_bill,0) into vIdBill from bills where id_bill = pIdBill;
	select paid into vPaid from bills where id_bill = pIdBill;


	if (vIdBill = 0 or vPaid = 1) then
		signal sqlstate '45000' SET MESSAGE_TEXT = 'Incorrect bill data or it is all ready paid', MYSQL_ERRNO = 14;
    end if;
	update bills SET paid = 1 WHERE id_bill = vIdBill; 
END
$$
DELIMITER ;

/*call sp_pay_bills(4);
*/