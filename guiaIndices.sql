use guia0;

#prueba random
drop index uidx_jn_ja on jugador;
select * from jugador;
CREATE UNIQUE INDEX uidx_jn_ja
ON jugador(nombre,apellido);

explain
select nombre,apellido
from jugador 
force index (uidx_jn_ja) 
where nombre like '_u%';#justo aca uso un like y no empiesa po % con lo cual tendria que ser una estructura
#B-TREE pero me entere despues de eso ajja

#ahi le clave que nombre y apellido tienen que ser unique, quiero ver que pasa si le repito un
#nombre y apellido
insert into jugador (id_equipo,nombre,apellido,fecha_nacimiento) values (1,"juan","apellido_2",now());
#en ese caso no te deja por que ya existe un juan apellido_2 en el equipo 1 peeeeero....

select * from jugador;
CREATE UNIQUE INDEX uidx_jn_ja
ON jugador(id_equipo,nombre,apellido);

insert into jugador (id_equipo,nombre,apellido,fecha_nacimiento) values (2,"juan","apellido_2",now());
#ahora si ya que busca que no halla un juan apellido_2 en el equipo 2 jeje izi pizi
select * from jugador where nombre = "juan";


drop table tabla;
CREATE TABLE tabla (
    c1 INT PRIMARY KEY AUTO_INCREMENT,
    c2 VARCHAR(50),
    c3 DATE NOT NULL,
    c4 VARCHAR(15) NOT NULL,
    INDEX prueba (c3, c4)
);

INSERT INTO tabla VALUES
(NULL, 'Casilla 1', CURDATE(), 'OPEN'),
(NULL, 'Casilla 2', CURDATE(), 'OPEN'),
(NULL, 'Casilla silenciosa', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'CLOSED'),
(NULL, 'Casilla cuadrada', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'CLOSED'),
(NULL, 'Casilla no cuadrada', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'OPEN'),
(NULL, 'Casilla que no debe cerrarse', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'CLOSED'),
(NULL, 'Casilla 3', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'CLOSED'),
(NULL, 'Casilla de pensamientos', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 'OPEN');

-- usa el índice
EXPLAIN
SELECT c1, c2
FROM tabla
WHERE c3 = CURDATE() AND c4 IN ('OPEN', 'CLOSED');

-- usa el índice
-- el orden de las columnas no es problema para MySQL
EXPLAIN
SELECT c1, c2
FROM tabla
WHERE c4 IN ('OPEN', 'CLOSED') AND c3 = CURDATE();

-- usa el índice
-- a pesar que en el WHERE primero se encuentre c2
-- que no es parte del índice
EXPLAIN
SELECT c1, c2
FROM tabla
WHERE c2 LIKE '%silenciosa%'
 AND c3 = CURDATE() AND c4 IN ('OPEN', 'CLOSED');

-- usa el índice
-- a pesar que en el WHERE se encuentre c2 entre c3 y c4
EXPLAIN
SELECT c1, c2
FROM tabla
WHERE c3 = CURDATE()
 AND c2 LIKE '%silenciosa%'
 AND c4 IN ('OPEN', 'CLOSED');
 
 
/*
Cabe resaltar que puedes forzar el uso de un índice en particular mediante la sentencia
 FORCE INDEX tal como se verá en los siguientes casos:
*/

-- no usará el índice porque MySQL detecta
-- que al usar >= para c3 es igual que
-- realizar un full scan a la tabla
EXPLAIN
SELECT c1, c2
FROM tabla
WHERE c3 >= CURDATE() AND c4 IN ('OPEN', 'CLOSED');

-- usa el índice
-- se fuerza al motor a utilizar el índice con la sentencia
-- FORCE INDEX (<nombre del índice a utilizar>)
EXPLAIN
SELECT c1, c2
FROM tabla
FORCE INDEX (prueba)
WHERE c3 >= CURDATE() AND c4 IN ('OPEN', 'CLOSED');


use guia0;

select nombre,apellido from jugador;

drop index ft_idx_jug on jugador;
explain extended select nombre,apellido from jugador where apellido like 'd%' order by apellido desc;

CREATE FULLTEXT INDEX ft_idx_jug ON jugador (apellido,nombre);
CREATE INDEX ft_idx_jug ON jugador (apellido,nombre) USING BTREE;
