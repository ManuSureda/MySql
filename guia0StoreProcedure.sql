drop database guia0;
create database guia0;

use guia0;

create table equipo(
	id_equipo Integer auto_increment,
    nombre_equipo varchar(50),
    
    constraint pk_equipo_id_equipo primary key (id_equipo)
);

create table partido(
	id_partido Integer auto_increment,
    id_equipo_local Integer not null,
    id_equipo_visitante Integer not null,
    fecha DateTime,
    
    constraint pk_partido_id_partido primary key (id_partido),
    constraint fk_id_equipo_local foreign key (id_equipo_local) references equipo(id_equipo),
    constraint fk_id_equipo_visitante foreign key (id_equipo_visitante) references equipo(id_equipo)
);

create table jugador(
	id_jugador Integer auto_increment,
    id_equipo Integer not null,
    nombre varchar(50),
    apellido varchar(50),
    
	constraint pk_jugador primary key (id_jugador),
	constraint fk_jugador_id_equipo foreign key (id_equipo) references equipo(id_equipo)
);

create table jugadores_x_equipo_x_partido(
	id_jugador Integer not null,
    id_partido Integer not null,
    puntos Integer default 0,
    rebotes Integer default 0,
    asistencias Integer default 0,
    minutos Integer default 0,
	faltas  Integer default 0,
    
    constraint pk_jugadores_x_equipo_x_partido primary key (id_jugador,id_partido),
	constraint fk_jugadores_x_equipo_x_partido_jugador foreign key (id_jugador) references jugador(id_jugador),
	constraint fk_jugadores_x_equipo_x_partido_partido foreign key (id_partido) references partido(id_partido)
);

#1) Generar un Stored Procedure que permite ingresar un equipo.
DELIMITER $$
CREATE PROCEDURE sp_insertar_equipo(pName varchar(50))
BEGIN    

	INSERT INTO equipo(nombre_equipo) VALUES (pName);

END;
$$
DELIMITER ;

call sp_insertar_equipo("equipo_1");
call sp_insertar_equipo("equipo_2");

#2) Generar un Stored Procedure que permita agregar un jugador. Se debe generar un error con código 1 si el equipo no existe.
DELIMITER $$
CREATE PROCEDURE sp_insertar_jugarod(pId_equipo Integer, pNombre varchar(50), pApellido varchar(50))
BEGIN 

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN #medio trampa esto... deberia hacer un if pId_equipo = null or ..... signal sqlstate....
		signal sqlstate '45000' SET MESSAGE_TEXT = 'El equipo no existe', MYSQL_ERRNO = 1;
    END;    

	INSERT INTO jugador(id_equipo,nombre,apellido) VALUES (pId_equipo,pNombre,pApellido);

END;
$$
DELIMITER ;

call sp_insertar_jugarod(1,"jugador_1","apellido_1");
call sp_insertar_jugarod(1,"jugador_2","apellido_2");
call sp_insertar_jugarod(1,"jugador_3","apellido_3");

call sp_insertar_jugarod(2,"jugador_4","apellido_4");
call sp_insertar_jugarod(2,"jugador_5","apellido_5");
call sp_insertar_jugarod(2,"jugador_6","apellido_6");

call sp_insertar_jugarod(3,"jugador_1","apellido_1");

#3) Generar un Stored Procedure que permita agregar un jugador pero se debe pasar el nombre del equipo y no el Id.
DELIMITER $$
CREATE PROCEDURE sp_insertar_jugarod_x_nombre_equipo(pNombre_equipo varchar(50), pNombre varchar(50), pApellido varchar(50))
BEGIN 
	declare vId_equipo Integer;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		signal sqlstate '45000' SET MESSAGE_TEXT = 'El equipo no existe', MYSQL_ERRNO = 1;
    END;    

    select ifnull(id_equipo,0) into vId_equipo from equipo where nombre_equipo = pNombre_equipo;

	INSERT INTO jugador(id_equipo,nombre,apellido) VALUES (vId_equipo,pNombre,pApellido);

END;
$$
DELIMITER ;

call sp_insertar_jugarod_x_nombre_equipo("equipo_2","jugador_7","apellido_7");
call sp_insertar_jugarod_x_nombre_equipo("noexiste","jugador_7","apellido_7");

select * from jugador;

#4) Generar un Stored Procedure que permita dar de alta un equipo y sus jugadores. Devolver en un parámetro output el id del equipo.
CREATE TEMPORARY TABLE temp_jugadores(
	id_jugador_temp Integer auto_increment,
    nombre varchar(50),
    apellido varchar(50),
    
	constraint pk_jugador primary key (id_jugador_temp)
);

select * from jugador;

insert into temp_jugadores (nombre,apellido) values ("jugador_8","apellido_8");
insert into temp_jugadores (nombre,apellido) values ("jugador_9","apellido_9");
insert into temp_jugadores (nombre,apellido) values ("jugador_10","apellido_10");
insert into temp_jugadores (nombre,apellido) values ("jugador_11","apellido_11");

select * from temp_jugadores;

DELIMITER $$
CREATE PROCEDURE sp_insertar_equipo_y_jugadores(pNombre_equipo varchar(50))
BEGIN
	declare vNombre varchar(50);
    declare vApellido varchar(50);
    declare vId_equipo Integer default 0;
    
    DECLARE vFinished INTEGER DEFAULT 0;
    DECLARE cur_jugador CURSOR FOR SELECT nombre,apellido from temp_jugadores;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET vFinished = 1;
    OPEN cur_jugador;
    
    call sp_insertar_equipo(pNombre_equipo);
    set vId_equipo = last_insert_id();
    
    get_jugadores : LOOP
		FETCH cur_jugador INTO vNombre,vApellido;
        IF vFinished = 1 THEN
			LEAVE get_jugadores;
		END IF;
		
        call sp_insertar_jugarod(vId_equipo,vNombre,vApellido);
        
    END LOOP get_jugadores;
    CLOSE cur_jugador;   
END;
$$
DELIMITER ;

call sp_insertar_equipo_y_jugadores("equipo_3");
drop table temp_jugadores;

select * from equipo;
select * from jugador;

#5) Generar un Stored Procedure que liste los partidos de un mes y año pasado por parametro
insert into partido (id_equipo_local,id_equipo_visitante,fecha) values (1,2,'2020-12-1');
insert into partido (id_equipo_local,id_equipo_visitante,fecha) values (2,1,'2020-12-2');
insert into partido (id_equipo_local,id_equipo_visitante,fecha) values (1,3,'2020-12-3');

insert into partido (id_equipo_local,id_equipo_visitante,fecha) values (3,1,'2020-11-1');
insert into partido (id_equipo_local,id_equipo_visitante,fecha) values (2,3,'2020-11-2');

insert into partido (id_equipo_local,id_equipo_visitante,fecha) values (1,2,'2019-12-1');
insert into partido (id_equipo_local,id_equipo_visitante,fecha) values (2,1,'2019-12-2');

select * from partido;
select * from partido where fecha between '2020-11-01' and '2020-12-03';
select month('2020-11-01');

DELIMITER $$
CREATE PROCEDURE sp_listar_partidos_x_mes_y_anio(pMes varchar(2),pAnio varchar(4))
BEGIN
	select * from partido where month(fecha) = pMes and year(fecha) = pAnio;
END
$$
DELIMITER ;

call sp_listar_partidos_x_mes_y_anio("11","2020");

#6) Generar un Stored Procedure que devuelva el resultado de un partido pasando por
#parámetro los nombres de los equipos. El resultado debe ser devuelto en dos variables output
select * from partido;
select * from jugador;
        
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (1,1,1,0,1,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (2,1,1,0,1,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (3,1,1,0,1,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (4,1,1,0,1,10,0);

insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (5,1,0,0,1,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (6,1,3,0,1,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (7,1,5,0,1,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (8,1,0,0,1,10,0);

select * from jugadores_x_equipo_x_partido;

select e.id_equipo, sum(puntos) 
	from jugadores_x_equipo_x_partido jxp join jugador j on j.id_jugador = jxp.id_jugador
    join equipo e on e.id_equipo = j.id_equipo
    group by id_equipo
    order by id_partido;
    
DELIMITER $$
CREATE PROCEDURE sp_resultado_por_nombre(in pVisitante varchar(50),in pLocal varchar(50), out o_puntos_l Integer,out o_puntos_v Integer)
BEGIN
	declare vId_local Integer default 0;
    declare vId_visitante Integer default 0;
    
    select id_equipo into vId_local from equipo where nombre_equipo = pLocal;
    select id_equipo into vId_visitante from equipo where nombre_equipo = pVisitante;
	
    select
		puntos into o_puntos_l
	from
		(select 
			e.id_equipo as equipo,sum(puntos) as puntos
		from equipo e join jugador j on j.id_equipo = e.id_equipo
		join jugadores_x_equipo_x_partido jxp on jxp.id_jugador = j.id_jugador
		group by e.id_equipo) as t
	where t.equipo = vId_local;
    
    select
		puntos into o_puntos_v
	from
		(select 
			e.id_equipo as equipo,sum(puntos) as puntos
		from equipo e join jugador j on j.id_equipo = e.id_equipo
		join jugadores_x_equipo_x_partido jxp on jxp.id_jugador = j.id_jugador
		group by e.id_equipo) as t
	where t.equipo = vId_visitante;
    
END
$$
DELIMITER ;

call sp_resultado_por_nombre("equipo_1","equipo_2",@rl,@rv);
select @rl;
select @rv;

#7) Generar un stored procedure que muestre las estadisticas promedio de los jugadores de un equipo.
####
drop procedure sp_promedio_equipo;
DELIMITER $$
CREATE PROCEDURE sp_promedio_equipo(pId_equipo Integer)
BEGIN
select 
	e.nombre_equipo,avg(puntos),avg(rebotes),avg(asistencias),avg(minutos),avg(faltas)
from jugadores_x_equipo_x_partido jxp join jugador j on j.id_jugador = jxp.id_jugador
	join equipo e on e.id_equipo = j.id_equipo
where 
	e.id_equipo = pId_equipo
group by
	jxp.id_partido;
END
$$
DELIMITER ;

call sp_promedio_equipo(1);

#### v2
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (1,2,1,1,1,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (2,2,2,0,1,5,1);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (3,2,3,2,1,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (4,2,4,0,1,3,1);

insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (5,2,1,1,1,20,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (6,2,2,1,5,10,0);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (7,2,4,1,1,5,2);
insert into jugadores_x_equipo_x_partido (id_jugador,id_partido,puntos,rebotes,asistencias,minutos,faltas) values (8,2,3,1,1,10,0);

DELIMITER $$
CREATE PROCEDURE sp_estadisticas_jugador_x_equipo(pEquipo Integer)
BEGIN
	select 
		j.id_jugador, j.nombre, j.apellido, avg(puntos) as puntos, avg(rebotes) as rebotes,avg(asistencias) as asistencias, avg(minutos) as minutos,avg(faltas) as faltas
	from 
		jugadores_x_equipo_x_partido jxp join jugador j on jxp.id_jugador = j.id_jugador
		join equipo e on e.id_equipo = j.id_equipo
	where j.id_equipo = pEquipo
	group by jxp.id_jugador;
END
$$
DELIMITER ;

call sp_estadisticas_jugador_x_equipo(2);


select * from jugador;