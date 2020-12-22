use guia0;
#usa la misma bd que la guia de procedures

#1) Generar un trigger que evite la carga de nuevos jugadores.
drop trigger tbi_jugador ;
DELIMITER $$
CREATE TRIGGER tbi_jugador before insert on jugador FOR EACH ROW
BEGIN
	signal sqlstate '45000' SET MESSAGE_TEXT = 'YA NO SE PUEDE AGREGAR MAS JUGADORES, SORY BRO', MYSQL_ERRNO = 1;
END
$$
DELIMITER ;

INSERT INTO jugador (id_equipo,nombre,apellido) VALUES (1,"asdfas","asdfasf");
select * from jugador;

#2) Generar un trigger que evite la carga de jugadores con el mismo nombre y apellido en el mismo equipo.
drop trigger tbi_jugador_mismo_nombre_apellido;
DELIMITER $$
CREATE TRIGGER tbi_jugador_mismo_nombre_apellido BEFORE INSERT ON jugador FOR EACH ROW
BEGIN
	declare vNombre Integer default 0;
    declare vApellido Integer default 0;
    select ifnull(id_jugador,0) into vNombre from jugador where id_equipo = new.id_equipo AND nombre = new.nombre;
    select ifnull(id_jugador,0) into vApellido from jugador where id_equipo = new.id_equipo AND apellido = new.apellido;
    
	IF vNombre <> 0 THEN
		signal sqlstate '45000' set message_text = 'nombre no disponible', mysql_errno = 2;
	END IF;
    IF vApellido <> 0 THEN
		signal sqlstate '45000' set message_text = 'apellido no disponible', mysql_errno = 3;
	END IF;
END
$$
DELIMITER ;

insert into jugador (id_equipo,nombre,apellido) values (1,"asd","asd");
select * from jugador;

#3) Generar un trigger que no permita ingresar los datos de un jugador a la tabla jugadores_x_equipo_x_partido que no haya juado el partido.
drop TRIGGER tbi_jugadores_x_equipo_x_partido ;
DELIMITER $$
CREATE TRIGGER tbi_jugadores_x_equipo_x_partido before insert on jugadores_x_equipo_x_partido for each row
BEGIN
    declare v_id_equipo Integer default 0;
    declare v_id_equipo_local Integer default 0;
    declare v_id_equipo_visitante Integer default 0;
    declare v_aux Integer default 0;
    
    select ifnull(id_equipo,0) into v_id_equipo from jugador where id_jugador = new.id_jugador;
    select ifnull(id_equipo_local,0) into v_id_equipo_local from partido where id_partido = new.id_partido;
    select ifnull(id_equipo_visitante,0) into v_id_equipo_visitante from partido where id_partido = new.id_partido;
    
    IF v_id_equipo = 0 THEN
		signal sqlstate '45000' set message_text = 'Este jugador no esta en ningun equipo', mysql_errno = 4;
	END IF;
    IF v_id_equipo_local <> v_id_equipo AND v_id_equipo <> v_id_equipo_visitante THEN
		signal sqlstate '45000' set message_text = 'Este jugador no participo de este partido', mysql_errno = 4;
	END IF;
END
$$
DELIMITER ; 
select * from partido;
select * from jugadores_x_equipo_x_partido;
select * from jugador;
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (200,3,1,1,1,1,1);

#4) Agregar el campo cantidad_jugadores a la tabla equipos y calcularlo mediante los triggers necesarios para ello.
ALTER TABLE equipo ADD cantidad_jugadores Integer;
select count(id_jugador) as cant, id_equipo from jugador group by id_equipo;

drop TRIGGER tai_equipo ;

DELIMITER $$#no lo probe por que tendria que quitarle el not null de id_equipo a jugador, crear varios con un equipo inexistente etc etc etc
CREATE TRIGGER tai_equipo BEFORE INSERT ON equipo FOR EACH ROW
BEGIN
    declare v_cantidad_jugadores Integer default 0;
    
    select count(id_jugador) into v_cantidad_jugadores from jugador where id_equipo = new.id_equipo group by id_equipo;
    set new.cantidad_jugadores = v_cantidad_jugadores;
END
$$
DELIMITER ;

#5) Agregar los campos fecha_nacimiento y edad a la tabla de jugadores y cuando se inserte o modifique la fecha de nacimiento recalcule la edad actual del jugador.
ALTER TABLE jugador ADD fecha_nacimiento DateTime;
ALTER TABLE jugador ADD edad Integer;

update jugador set fecha_nacimiento = '1997-12-06' where id_jugador > 0;
update jugador set edad = 23 where id_jugador > 0;
select * from jugador;

drop TRIGGER tbi_jugador ;
DELIMITER $$
CREATE TRIGGER tbi_jugador BEFORE INSERT ON jugador FOR EACH ROW
BEGIN
	declare v_edad Integer default 0;
    select timestampdiff(year, new.fecha_nacimiento, now()) into v_edad;
    set new.edad = v_edad;
END
$$
DELIMITER ;

drop TRIGGER tbu_jugador ;
DELIMITER $$
CREATE TRIGGER tbu_jugador BEFORE UPDATE ON jugador FOR EACH ROW
BEGIN
	declare v_edad Integer default 0;
    select timestampdiff(year, new.fecha_nacimiento, now()) into v_edad;
    set new.edad = v_edad;########ESTA ES LA FORMA DE MODIFICAR DATOS, NO HACIENDO UN UPDATE COMO VENIAS HACIENDO SALAME
END
$$
DELIMITER ;

select * from jugador;
INSERT INTO jugador (id_equipo,nombre,apellido,fecha_nacimiento,edad) VALUES (1,"eeee","eeee","1991-06-12",0);
UPDATE jugador SET fecha_nacimiento = '1993-12-06' where id_jugador = 1;


select timestampdiff(year, '1997-12-06', now()) as años;

#6) Agregar los campos puntos_equipo_local y puntos_equipo_visitante a la tabla de
#partidos y realizar los triggers necesarios para mantener automaticamente el resultado
#del partido en base a lo cargado en la tbala jugadores_x_equipo_x_partido.