use guia0;

###no tengo ningun ejercicio, es solo practica random de funciones...
#por default si no especificas el deterministic queda en NON deterministic
#DETERMINISTIC es que si recive los mismos parametros SIEMPRE va a devolver el mismo resulado
#NON DETERMINISTIC quiere decir que no siempre va a devolver lo mismo
DELIMITER $$
CREATE FUNCTION get_sum(a Integer, b Integer)
RETURNS Integer
DETERMINISTIC #NON DETERMINISTIC por default
BEGIN
	declare ans Integer default 0;
    set ans = a + b;
    return ans;
END
$$
DELIMITER ;

select get_sum(1,2);

