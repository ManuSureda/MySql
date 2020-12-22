/*------------------------------------------------------------------------------------*/

/*DATA*/
/*Insercion de datos estandares en la base de datos*/

/*------------------------------------------------------------------------------------*/
/*Ingresar provincias al sistema*/
insert into provinces(name) values ("Buenos Aires");
insert into provinces(name) values ("Catamarca");
insert into provinces(name) values ("Chaco");
insert into provinces(name) values ("Chubut");
insert into provinces(name) values ("Córdoba");
insert into provinces(name) values ("Corrientes");
insert into provinces(name) values ("Entre Ríos");
insert into provinces(name) values ("Formosa");
insert into provinces(name) values ("Jujuy");
insert into provinces(name) values ("La Pampa");
insert into provinces(name) values ("La Rioja");
insert into provinces(name) values ("Mendoza");
insert into provinces(name) values ("Misiones");
insert into provinces(name) values ("Neuquén");
insert into provinces(name) values ("Río Negro");
insert into provinces(name) values ("Salta");
insert into provinces(name) values ("San Juan");
insert into provinces(name) values ("San Luis");
insert into provinces(name) values ("Santa Cruz");
insert into provinces(name) values ("Santa Fe");
insert into provinces(name) values ("Santiago del Estero");
insert into provinces(name) values ("Tierra del Fuego");
insert into provinces(name) values ("Tucumán");

/*------------------------------------------------------------------------------------*/
/*Ingresar ciudades al sistema*/
insert into cities (name,prefix,id_province) values ("Buenos Aires","0011",1);
insert into cities (name,prefix,id_province) values ("Mar del Plata","0223",1);
insert into cities (name,prefix,id_province) values ("La Plata","0221",1);
insert into cities (name,prefix,id_province) values ("Miramar","2291",1);
insert into cities (name,prefix,id_province) values ("Villa Gesell","2255",1);
insert into cities (name,prefix,id_province) values ("Balcarce","2266",1);
insert into cities (name,prefix,id_province) values ("Catamarca","3833",2);
insert into cities (name,prefix,id_province) values ("Resistencia","0362",3);
insert into cities (name,prefix,id_province) values ("Rawson","0280",4);
insert into cities (name,prefix,id_province) values ("Córdoba","0351",5);
insert into cities (name,prefix,id_province) values ("Corrientes","0379",6);
insert into cities (name,prefix,id_province) values ("Paraná","0343",7);
insert into cities (name,prefix,id_province) values ("Formosa","3717",8);
insert into cities (name,prefix,id_province) values ("San Salvador de Jujuy","0388",9);
insert into cities (name,prefix,id_province) values ("Santa Rosa","2954",10);
insert into cities (name,prefix,id_province) values ("La Rioja","3822",11);
insert into cities (name,prefix,id_province) values ("Mendoza","0261",12);
insert into cities (name,prefix,id_province) values ("Posadas","0376",13);
insert into cities (name,prefix,id_province) values ("Neuquén","0299",14);
insert into cities (name,prefix,id_province) values ("Viedma","2920",15);
insert into cities (name,prefix,id_province) values ("Salta","0387",16);
insert into cities (name,prefix,id_province) values ("San Juan","0264",17);
insert into cities (name,prefix,id_province) values ("San Luis","2652",18);
insert into cities (name,prefix,id_province) values ("Río Gallegos","2966",19);
insert into cities (name,prefix,id_province) values ("Santa Fé","0342",20);
insert into cities (name,prefix,id_province) values ("Santiago del Estero","0385",21);
insert into cities (name,prefix,id_province) values ("Ushuaia","2901",22);
insert into cities (name,prefix,id_province) values ("San Miguel de Tucumán","0381",23);

/*------------------------------------------------------------------------------------*/
/*Ingreso de datos por defecto (FUNCION DE RANDOM DE TARIFA)*/
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (1, 1, 3, 0.3);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (1, 2, 3, 0.3);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (1, 3, 2, 0.2);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (2, 1, 8, 0.5);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (2, 2, 9, 1.5);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (2, 3, 10, 4);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (3, 1, 6, 0.7);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (3, 2, 8, 0.9);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (3, 3, 7, 1);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (7, 8, 10, 1);
insert into tariffs(id_city_origin, id_city_destination, price_per_minute, cost_per_minute) value (8, 7, 12, 3);

/*------------------------------------------------------------------------------------*/