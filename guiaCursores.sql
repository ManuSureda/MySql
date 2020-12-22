#usa la misma bd que la guia de store procedure
use guia0;

#1) Generar un stored procedure que liste los jugadores y a que equipo pertenecen utilizando cursores.
drop table mostrar;

CREATE TEMPORARY TABLE mostrar(
	id_equipo Integer,
    nombre_equipo varchar(50),
    id_jugador Integer,
    nombre varchar(50),
    apellido varchar(50)
);

drop procedure sp_listar_jugadores_equipo;

DELIMITER $$
CREATE PROCEDURE sp_listar_jugadores_equipo()
BEGIN
	declare vFinished Integer default 0;#esto me ayuda a salir del loop
    
    declare vId_equipo Integer default 1;#esto va a guardar
    declare vNombre_equipo varchar(50) default "";#la info del cursor
    
    declare vId_jugador Integer default 0;
    declare vId_equipo_aux Integer default 0;
    declare vNombre varchar(50) default "";
    declare vApellido varchar(50) default "";
    
    #primero declaras las variables
    #y despues el cursor
    
    declare cur_equipo cursor for select id_equipo,nombre_equipo from equipo;#cursor
    declare cur_jugador cursor for select id_jugador,id_equipo,nombre,apellido from jugador where id_equipo = vId_equipo;#aca queria poner un where id_equipo = vId_equipo pero no funciona por alguna razon
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;#cuando el cursor me traiga null, esto vuelve vFinished = 1
    open cur_equipo;#abro el cursor
    fetch cur_equipo into vId_equipo,vNombre_equipo;#traigo la info
    
    get_equipo : LOOP #abro el loop
        
        IF vFinished = 1 THEN #si se quedo sin registros que traer, salgo del loop
			LEAVE get_equipo;
		END IF;
        
        open cur_jugador;
        
        get_jugador : LOOP 
			fetch cur_jugador into vId_jugador,vId_equipo_aux,vNombre,vApellido;
            
			IF vFinished = 1 THEN #si se quedo sin registros que traer, salgo del loop
				close cur_jugador;
                set vFinished = 0;
				LEAVE get_jugador;
			END IF;
            IF vId_equipo_aux = vId_equipo THEN
				insert into mostrar (id_equipo,nombre_equipo,id_jugador,nombre,apellido) values (vId_equipo_aux,vNombre_equipo,vId_jugador,vNombre,vApellido);
            END IF;
        
        END LOOP get_jugador;
        
        fetch cur_equipo into vId_equipo,vNombre_equipo;#traigo la info
        
    END LOOP get_equipo;#cierro el loop
    close cur_equipo;#cierro el cursor
    #close cur_jugador;
    select * from mostrar;
END
$$
DELIMITER ;

call sp_listar_jugadores_equipo();

select * from mostrar;

#2) Generar un stored procedure que liste los resultados de todos los partidos.
drop table temp_resultados;
CREATE TEMPORARY TABLE temp_resultados(
	id_partido Integer,
    resultado_local Integer,
    resultado_visitante Integer
);

drop procedure sp_listar_resultado_partidos;
DELIMITER $$
CREATE PROCEDURE sp_listar_resultado_partidos()
BEGIN
	declare vFinished Integer default 0;
    declare cantidad_partidos Integer default 0;
    declare cant Integer default 0;
    declare puntos_local Integer default 0;
    declare puntos_visitante Integer default 0;
	#jxp
    declare jxp_id_jugador Integer default 0;
    declare jxp_id_partido Integer default 0;
    declare jxp_puntos Integer default 0;
    #partido
    declare p_id_partido Integer default 0;
    declare p_id_equipo_local Integer default 0;
    declare p_id_equipo_visitante Integer default 0;
    #jugador
    declare j_id_jugador Integer default 0;
    declare j_id_equipo Integer default 0;
    #cursor
    declare cur_jxp cursor for select id_partido,id_jugador,puntos from jugadores_x_equipo_x_partido where id_partido = p_id_partido order by id_jugador;
    declare cur_partido cursor for select id_partido,id_equipo_local,id_equipo_visitante from partido;
    #handler
    declare continue handler for not found set vFinished = 1;
    
    open cur_partido;
    
    select count(*) into cantidad_partidos from partido;
    
    WHILE cant < cantidad_partidos DO
		fetch cur_partido into p_id_partido,p_id_equipo_local,p_id_equipo_visitante;#primero tengo que hacer este fetch para tener el p_id_partido que va en el cur_jxp
        open cur_jxp;
        set puntos_local = 0;
        set puntos_visitante = 0;
        get_jxp : LOOP
			fetch cur_jxp into jxp_id_partido,jxp_id_jugador,jxp_puntos;
            IF vFinished = 1 THEN
				close cur_jxp;
                set vFinished = 0;
				LEAVE get_jxp;
			END IF;
            
            select id_equipo into j_id_equipo from jugador where id_jugador = jxp_id_jugador;
            
            IF j_id_equipo = p_id_equipo_local THEN
				set puntos_local = puntos_local + jxp_puntos;
            END IF;
            IF j_id_equipo = p_id_equipo_visitante THEN
				set puntos_visitante = puntos_visitante + jxp_puntos;
			END IF;
        END LOOP get_jxp;
        insert into temp_resultados (id_partido,resultado_local,resultado_visitante) values (p_id_partido,puntos_local,puntos_visitante);
		set cant = cant + 1;
    END WHILE;
    close cur_partido;
    select * from temp_resultados;
END
$$
DELIMITER ;

call sp_listar_resultado_partidos();
select * from temp_resultados;


