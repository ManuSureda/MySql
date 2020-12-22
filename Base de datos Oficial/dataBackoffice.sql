/*ADMINISTRADOR*/
INSERT INTO users(name, last_name, dni, user_password, role_name, id_city)      
VALUES ("Administrador", "Administrador", "123", "admin", "Admin", 1);

/* EMPLEADOS */
call sp_insert_employee("Santiago", "Labatut", "41686701", "admin123", 1, @id);
call sp_insert_employee("Manuel", "Sureda", "40831341", "pass", 2, @id);

/* CLIENTES */
call sp_insert_client_and_phone_lines("Palo", "Kell", "42231231", "asd", 2, "Home", @id);
call sp_insert_client_and_phone_lines("Juan", "Alman", "42231232", "dsa", 3, "Mobile", @id);
call sp_insert_client_and_phone_lines("juan", "Ramirez", "42231233", "qwe", 3, "Home", @id);
call sp_insert_client_and_phone_lines("Santiago", "Vazquez", "42231234", "dsa", 3, "Home", @id);
call sp_insert_client_and_phone_lines("Pedro", "Gomez", "42231235", "qwe", 7, "Home", @id);
call sp_insert_client_and_phone_lines("Franco", "Lissoti", "42231236", "qwe", 8, "Mobile", @id);

/* LINEAS TELEFONICAS AL CLIENTE */
call sp_phone_lines(5,"Mobile",@id);




