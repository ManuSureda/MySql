use guia0;

#1) Realizar una vista que muestre todos los jugadores de un equipo
drop view v_ver_jugadores_x_equipo;
CREATE VIEW v_ver_jugadores_x_equipo
as
select 
	e.nombre_equipo as equipo,j.nombre,j.apellido,j.fecha_nacimiento
from 
	jugador j inner join equipo e on e.id_equipo = j.id_equipo;
    
select * from v_ver_jugadores_x_equipo;
select * from v_ver_jugadores_x_equipo where equipo = 'equipo_1';

#2) Realizar una vista que muestre nombre un equipo con sus jugadores
#es justo lo que hice arriba
CREATE VIEW v_ver_jugadores_x_equipo_2
as
select 
	e.id_equipo as id,e.nombre_equipo as equipo,j.nombre,j.apellido,j.fecha_nacimiento
from 
	jugador j inner join equipo e on e.id_equipo = j.id_equipo;

#3) Realizar una vista que muestre el jugador con más puntos realizados
select * from jugadores_x_equipo_x_partido;
select id_jugador,sum(puntos) as puntos from jugadores_x_equipo_x_partido group by id_jugador order by puntos desc limit 1;

CREATE VIEW v_maximo_goleador
as
select 
	jxp.id_jugador,j.nombre,j.apellido,sum(puntos) as puntos 
from 
	jugadores_x_equipo_x_partido jxp inner join jugador j on j.id_jugador = jxp.id_jugador
group by id_jugador 
order by puntos desc limit 1;

select * from v_maximo_goleador;

#4) Realizar una vista que muestre todos los partidos del año en curso dividido por mes
CREATE VIEW v_partidos_del_anio
as
select 
	el.nombre_equipo as e_local,ev.nombre_equipo as e_visitante,month(p.fecha) 
from 
	partido p inner join equipo el on p.id_equipo_local = el.id_equipo
    inner join equipo ev on p.id_equipo_visitante = ev.id_equipo
where year(fecha) = year(now()) order by fecha;

select * from v_partidos_del_anio;

#5) Al ingresar un jugador disparar una vista que muestre como quedo compuesto el equipo
#EL PROBLEMA CON ESTO ES QUE UN TRIGGER NO PUEDE RETORNAR UN RESULT SET...~
#INCLUSO SI LO MANDO A UN SP TAMPOCO ME DEJA
#SERIA CARGAR UNA TABLA TEMPORAL Y DESPUES MOSTRARLA? RE MOLESTO ESO JAJA
DELIMITER $$
CREATE TRIGGER tai_jugador AFTER INSERT ON jugador FOR EACH ROW
BEGIN
	call sp_ver_equipo(new.id_equipo);
END
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_ver_equipo(pId_equipo Integer)
BEGIN
	select * from v_ver_jugadores_x_equipo where id = new.id_equipo; 
END
$$
DELIMITER ;

insert into jugador (id_equipo,nombre,apellido,fecha_nacimiento) values (1,"soyNuevo","reNuevo","2012-05-03");

explain select * from jugadores_x_equipo_x_partido;

explain extended select * from jugadores_x_equipo_x_partido;
