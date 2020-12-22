/*------------------------------------------------------------------------------------*/
/*DATABASE*/
/*Creacion de las tablas*/

drop database backoffice;
create database backoffice;
use backoffice;

create table Provinces(
	id_province Integer auto_increment,
	name Varchar(50) unique not null,
	
	constraint pk_province_id_province primary key (id_province)
);


create table Cities (
	id_city integer auto_increment,
	id_province integer not null,
	name varchar(50) not null,
	prefix varchar(10) not null,
	
	constraint pk_cities_id_city primary key (id_city),
	constraint fk_cities_id_province foreign key (id_province) references Provinces(id_province) on DELETE CASCADE
);

create table Users(
	id_user integer auto_increment,
    name varchar(50) not null,
	last_name varchar(50) not null,
	dni varchar(8) unique not null,
	user_password varchar(50) not null,
    available TINYINT NOT NULL DEFAULT 1,
	role_name ENUM("Client", "Employee", "Admin"),
    
	id_city Integer not null,
	
	constraint pk_users_id_user primary key(id_user),
    constraint fk_users_id_city foreign key (id_city) references Cities (id_city) on DELETE CASCADE
);

create table phone_lines(
	id_line integer auto_increment,
    number_line varchar(50) unique not null,
    available TINYINT NOT NULL DEFAULT 1,
	line_type ENUM("Mobile", "Home"),
    
	id_user integer not null,
	
	constraint pk_phone_lines_id_lines primary key (id_line),
	constraint fk_phone_lines_id_user foreign key (id_user) references Users (id_user) on DELETE CASCADE
);


create table Tariffs(
	id_tariff integer auto_increment,
	id_city_origin integer not null,
	id_city_destination integer not null,
	price_per_minute long,
	cost_per_minute float,
	
	constraint pk_tariffs_id_tariff primary key (id_tariff),
	constraint fk_tariffs_city_origin foreign key (id_city_origin) references Cities (id_city) on DELETE CASCADE,
	constraint fk_tariffs_city_destination foreign key (id_city_destination) references Cities	(id_city) on DELETE CASCADE
);


create table Bills(
	id_bill integer auto_increment,
    id_line integer, 
	calls_quantity Integer,
	total_cost long,
	total_price long ,
	bill_date date not null,
	expiration_date date not null,
    paid TINYINT NOT NULL DEFAULT 0,
	
	constraint pk_bills_id_bill primary key (id_bill),
    constraint pk_bills_id_phone_line foreign key (id_line) references phone_lines (id_line)
);

create table Calls(
	id_call integer auto_increment,
	call_date datetime not null,
	id_line_origin integer not null,
	id_line_destination integer not null,
	duration long,
	total_price integer not null,
    total_cost integer not null,
	id_city_origin integer not null, 
	id_city_destination integer not null,
    billed tinyint,
    id_bill integer,
	
	constraint pk_calls_id_call primary key (id_call),
	constraint fk_calls_id_line_origin foreign key (id_line_origin) references phone_lines (id_line),
	constraint fk_calls_id_line_destination foreign key (id_line_destination) references phone_lines(id_line),
	constraint fk_calls_city_origin foreign key (id_city_origin) references Cities(id_city),
	constraint fk_calls_city_destination foreign key (id_city_destination) references Cities(id_city),
    constraint fk_calls_id_bill foreign key (id_bill) references bills(id_bill)
);

