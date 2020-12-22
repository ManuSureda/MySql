use guia0;

#en realidad aca la posta seria abrir dos ventanas del powershell para ver la posta de la magia
/*
	abrite el wampp y tea arbis dos consolas de mysql
    para hacer por ejemplo algo suuuper izi
    en ambas consolas pone: 
    use guia0;
    
    en la de la izq:
    select * from jugador;
    derecha:
    select * from jugador;
    
    VAN A ESTAR IGUALES...
    
    IZQ:
    update jugador set nombre = "pepe" where id_jugador = 2;
    select * from jugador;
    DER:
    select * from jugador;
    
    VAN A ESTAR IGUALES...
    
    
    AMBOS:
    set autocommit = 0;
    IZQ:
    start transaction;
    update jugador set nombre = "juan" where id_jugador = 3;
    select * from jugador;
    va a aparecer el nombre juan hagas el commit o no... 
    
    DER:
    select * from jugador;
    NO va a aparecer juan...
    commit;
    sigue SIN aparecer juan... 
    
    IZQ:
    commit;
    select * from jugador;
    aparece tal como antes juan...
    
    DER:
    select * from jugador;
    todabia NO aparece juan...
    commit;
    select * from jugador;
    ahora SI aparece juan...
    
    EN CONCLUCION...
    derecha no va a recibir los cambios echos por izquierda hasta que 1º izquierda no haga el commit y 2º derecha haga un commit...
    
    que pasa si ambos modifican el mismo registro?
    
    IZQ:
    START TRANSACTION;
    update jugador set nombre = "ZZZ" where id_jugador = 3;
    select * from jugador
    ... aparece el zzz...
    
    DER:
    START TRANSACTION;
    update jugador set nombre = "jamon" where id_jugador = 3;
    la consola no deja apretar el enter, es decir que bloqueo ese registro
    pero si cambiamos el id_jugador por otro numero, ahi si nos deja aplicarlo
    si hacemos el commit en ambos veremos los cambios... 
    
    ----------------------
    NIVELES DE AISLAMIENTO
    ----------------------
    READ UNCOMMITED
    puede recuperar datos modificados pero no confirmados por otras transacciones
	(lecturas sucias - dirty reads). En este nivel se pueden producir todos los efectos
	secundarios de simultaneidad (lecturas sucias, lecturas no repetibles y lecturas
	fantasma - ej: entre dos lecturas de un mismo registro en una transacción A, otra
	transacción B puede modificar dicho registro), pero no hay bloqueos ni versiones de
	lectura, por lo que se minimiza la sobrecarga
    
    ambos: por alguna razon si lo pones en mayuscula se enoja y no te deja... usa minuscula
    SET TRANSACTION ISOLATTION LEVEL READ UNCOMMITTED;
    START TRANSACTION;
    
    izq:
    update jugador set nombre = "aaaaa" where id_jugador = 6;
	
    der:
    select * from jugador;
    va a aparecer el aaaaa 
    
    izq:
    rollback;
    
    der:
    select * from jugador;
    ya no aparece el aaaaa
    
    izq:
    update jugador set nombre = "aaaaa" where id_jugador = 6;
	
    der:
    select * from jugador;
    aparece aaaaa
    commit;
    select * from jugador;
    ya no esta el aaaaa supongo que termino la transaction por lo cual volvio al modo normal
    donde no puede leer los uncommitted
    ahora si volvemos a poner lo del set uncommited y volvemos a empezar la transaction
    y volvemos a poner select, ahi si vuelve el aaaa
    
    izq:
    select * from jugador;
    sigue estando el aaaaa
    
    der:
    (volviendo a hacer lo del isolation y el transaction)
    update... la misma id que esta el de la izq;
    queda como """"suspendido"""" osea no se rompe pero queda bloqueado hasta que la izq haga su commit;
    
    
    -------------
    READ COMMITED
    -------------
    Permite que entre dos lecturas de un mismo registro en una transacción A, otra
	transacción B pueda modificar dicho registro, obteniéndose diferentes resultados de la
	misma lectura
    
    ambos:
    set transaction isolation level read committed;
    start transaction;
    
    izq:
    update jugador set nombre = "aaaaa" where id_jugador = 1;
    select * from jugador;
    aparece aaaaa
    
    der:
    select * from jugador;
    NO aparece aaaaaa
    
    izq:
    commit;
    
    der:
    select * from jugador;
    aparece aaaaaa
    
    
	---------------
    REPEATABLE READ
    ---------------
    Evita que entre dos lecturas de un mismo registro en una transacción A, otra
	transacción B pueda modificar dicho registro, con el efecto de que en la segunda
	lectura de la transacción A se obtuviera un dato diferente
    
    osea que si yo leo el jugador 1 en la izq y me dice que su nombre es juan por mas que
    lo modifique a la derecha y commitee y toda la bola, a la izq me va a seguir diciendo que es juan
    
	
    ------------
    SERIALIZABLE
    ------------
    Garantiza que una transacción recuperará exactamente los mismos datos cada vez que
	repita una operación de lectura (es decir, la misma sentencia SELECT con la misma
	cláusula WHERE devolverá el mismo número de filas, luego no se podrán insertar filas
	nuevas en el rango cubierto por la WHERE, etc. - se evitarán las lecturas fantasma),
	aunque para ello aplicará un nivel de bloqueo que puede afectar a los demás usuarios
	en los sistemas multiusuario.

	ambos:
	set transaction isolation level serializable;
    start transaction;
    select * from jugador;
    
    izq:
    insert en jugador;
    ...queda suspendido...
    
    der:
    select
    no aparece
    commit;
    ... el izq se desbloquea ... 
    select
    no aparece
    
    izq:
    commit;
    
    der 
    select
    aparece
    
    
*/