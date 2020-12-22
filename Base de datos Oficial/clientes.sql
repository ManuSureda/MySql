/*------------------------------------------------------------------------------------*/
/*CLIENTES*/
/*Permitir consultas de llamadas y facturación*/

/*------------------------------------------------------------------------------------*/
/*Vista de llamadas*/

create view v_calls_info
as
select concat(uo.name," ",uo.last_name) as full_name_o ,uo.dni as dni_user_origin, concat(co.prefix,po.number_line) as origin_line, pro.name as origin_province, co.name as origin_city, 
concat(ud.name," ",ud.last_name) as full_name_d, ud.dni as dni_user_destination, concat(cd.prefix,pd.number_line) as destination_line, cd.name as destination_city, c.duration, c.total_price, c.total_cost, c.call_date, c.billed
from calls c 
inner join phone_lines po on c.id_line_origin = po.id_line 
inner join users uo on po.id_user = uo.id_user 
inner join cities co on uo.id_city = co.id_city
inner join provinces pro on pro.id_province = co.id_province
inner join phone_lines pd on c.id_line_destination = pd.id_line
inner join users ud on pd.id_user = ud.id_user 
inner join cities cd on ud.id_city = cd.id_city order by call_date;

/*------------------------------------------------------------------------------------*/
/*Vista de facturacion*/
create view v_bills_info
as
select concat(u.name," ",u.last_name) as complete_name,u.dni, concat(ci.prefix,pl.number_line) as full_number, b.calls_quantity, b.total_price, b.total_cost, b.bill_date, b.expiration_date, b.paid
from bills b inner join phone_lines pl on b.id_line = pl.id_line inner join users u on u.id_user = pl.id_user inner join cities ci on ci.id_city = u.id_city
where b.calls_quantity <> 0
order by b.bill_date;
/*------------------------------------------------------------------------------------*/
/*OPCIONAL*/
/*Ingresar una vista de un usuario con sus respectivos datos*/

/*Ingresar una vista de un cliente*/
create view v_client_info
as select s.id_user, s.role_name as rol, s.name, s.last_name , s.dni , s.user_password as password, c.name as city, pv.name as province,
concat(c.prefix,pl.number_line) as full_number, pl.line_type, pl.available as status
from users s
inner join cities c on c.id_city = s.id_city
inner join provinces pv on pv.id_province = c.id_province
inner join phone_lines pl on pl.id_user = s.id_user and pl.available = 1
where s.role_name = "Client"
order by s.id_user;

/*Ingresar una vista de un empleado*/
create view v_employee_info
as select s.id_user, s.role_name as rol, s.name, s.last_name , s.dni , s.user_password as password, c.name as city, pv.name as province
from users s 
inner join cities c on c.id_city = s.id_city
inner join provinces pv on pv.id_province = c.id_province
where s.role_name = "Employee";


/*Ingresar una vista de un tarifas*/
create view v_tariffs_info
as select t.id_tariff, co.name as city_origin, cd.name as city_destination, t.price_per_minute, t.cost_per_minute
from tariffs t
inner join cities co on co.id_city = t.id_city_origin
inner join cities cd on cd.id_city = t.id_city_destination
order by co.name;

/*------------------------------------------------------------------------------------*/
select * from phone_lines;
/*Empleados*/
select * from v_employee_info;
/*Clientes*/
select * from v_client_info;
/*Llamadas*/
explain select * from v_calls_info;
select * from v_calls_info;
/*Facturas*/
select * from v_bills_info;
/*Tarifas*/
select * from v_tariffs_info;

