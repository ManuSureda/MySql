-- Indices

create index idx_calls on calls (call_date) using btree; 

explain select plo.number_line, co.name, pld.number_line, cd.name, c.total_price, c.duration, c.call_date
from calls as c join phone_lines as plo
on c.id_line_origin=plo.id_line
join phone_lines as pld
on c.id_line_destination=pld.id_line
join users as u
on plo.id_user = u.id_user
join cities as co
on c.id_city_origin = co.id_city
join cities as cd
on c.id_city_destination = cd.id_city
where u.dni = "41686701" AND call_date BETWEEN "2015-03-21" AND "2021-10-15" ;



/*
DELIMITER $$
CREATE PROCEDURE insert_random_calls(pCant int)
BEGIN 
    declare aux int default 0;
    declare vIdUser int default 0;
    declare vLineOrigin varchar(11);
    declare vLineDestination varchar(11);
    declare vCant int default 0;

    while (aux < pCant) do
        SELECT FLOOR(RAND()*(11 - 5)+5) INTO vIdUser;
        select full_number INTO vLineOrigin from v_client_info where id_user = vIdUser;

        if (vIdUser < 10) then
            set vIdUser = vIdUser+1;
        else 
            set vIdUser = 5;
        end if;
        select full_number INTO vLineDestination from v_client_info where id_user = vIdUser;

        call sp_insert_call(vLineOrigin,vLineDestination,FLOOR(RAND()*(30 - 1)+1),now(), @id);
        set aux = aux +1;
    end while;
END;
$$
DELIMITER ;
select * from calls;*/