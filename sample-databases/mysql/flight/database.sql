create table customers (
	id integer auto_increment,
	name varchar(255) not null,
	constraint pk primary key (id)
);

create table airports (
	code varchar(3),
	name varchar(255) not null,
	constraint pk primary key (code)
);

create table airlines (
	code varchar(2),
	name varchar(255) not null,
	constraint pk primary key (code)
);

create table bookings (
	reference varchar(10),
	customer_id integer not null,
	primary key (reference, customer_id),
	foreign key (customer_id) references customers(id)
);

create table flight (
	airline_code varchar(2),
	id varchar(10),
	origin_airport_code varchar(3) not null,
	destination_airport_code varchar(3) not null,
	constraint pk primary key (airline_code, id),
	foreign key (origin_airport_code) references airports(code),
	foreign key (destination_airport_code) references airports(code)
);

create table flight_bookings (
	booking_reference varchar(10),
	customer_id integer,
	airline_code varchar(2) not null,
	flight_id varchar(16) not null,
	constraint pk primary key (booking_reference, customer_id, flight_id),
	foreign key (booking_reference, customer_id) references bookings(reference, customer_id),
	foreign key (airline_code, flight_id) references flight(airline_code, id)
);

insert into customers (id, name) values (1, 'Élodie Boily'), (2, 'அகவழகு தன்வி'), (3, 'Alexander Dvořák'), (4, 'Mike van Es'), (5, 'Donna West'), (6, 'Sorawut Kittakun'), (7, 'Spencer Shaw'), (8, 'Bianka Powązka'), (9, 'ศศิธร ทองอยู่'), (10, 'Marina Štšerbakov'), (11, 'Tomàs Ignacio Rodriguez'), (12, 'جناب آقای دکتر حسین کمالی'), (13, 'Jason Moore'), (14, 'Erik Pettersson'), (15, 'Makayla Hill'), (16, 'Teresa Piñeiro Parra'), (17, 'Jayeng Halimah'), (18, 'Ralph Pacheco'), (19, 'Magali Wattiez'), (20, 'Anders Eide'), (21, 'Štefanija Toplak'), (22, 'Mohanlal Sachdev'), (23, 'Diane Mason'), (24, 'Mauricio Felipe Narváez'), (25, 'Ilarion Ene'), (26, 'Gilbert Bochud'), (27, 'מגד אגבאריה'), (28, 'Louis Hastey'), (29, 'Brittany Bell'), (30, 'Núria Sá'), (31, 'Patrick-David Smith'), (32, 'Laimonis Zariņš'), (33, 'Albert Hogan'), (34, 'নন্দিতা রাও'), (35, 'Jay Russell'), (36, 'Timothy Lee'), (37, 'Thomas Johnson'), (38, 'Caroline Lopes'), (39, 'منيب الجنيدي'), (40, 'George Bader'), (41, 'Ruben Wheeler'), (42, 'Monica Burgess'), (43, '張飛'), (44, 'Richardt Jespersen'), (45, 'Arnau Álvaro'), (46, 'Herr Klaus Peter Tschentscher'), (47, 'Səfər Əmirli'), (48, 'Alisha Schwartz'), (49, 'السيدة ريم الجفالي'), (50, '斎藤 美加子'), (51, 'Antun Lukšić'), (52, 'Богуслава Ващенко-Захарченко'), (53, 'Abeiku Kyei'), (54, 'Kevin Gutierrez'), (55, 'Thomas Binder-Eberharter'), (56, 'Paige Harris'), (57, 'Jenaro Piquer Yáñez'), (58, 'Ángel Canales Ojeda'), (59, 'Manuel Coleman'), (60, 'รอกีเย๊าะ บุญบำรุง'), (61, 'शिलु शाह'), (62, 'Ernesto Cagnin-Carriera'), (63, '王彬'), (64, 'Daniel Patterson'), (65, 'Scott Franco'), (66, 'Arthur Bigot-Foucher'), (67, 'Galdikas, Evaldas'), (68, 'Elliot Butcher'), (69, 'Dr. Paye Nalân Sakarya'), (70, 'Prof. Mirjana Carsten B.Sc.'), (71, 'عبد الحقّ قرش'), (72, '이미숙'), (73, 'Daniel Gibbs'), (74, 'ნარგიზა დიასამიძე'), (75, 'Герман Харитонович Никитин'), (76, 'Antoine Verstraete'), (77, 'Г-ца Ерол Балахуров'), (78, 'Συμεών Δούνης'), (79, 'Joseph Allen'), (80, 'Mr. Victor Brún'), (81, 'ସୁଶ୍ରୀ ରତି ମହାଲିଙ୍ଗା'), (82, 'Kissné Dr. Soós Éva'), (83, 'Ներսես Շագոյան'), (84, 'Jamie Stephens'), (85, 'Felipe Horacio Campos Rodríguez'), (86, 'राजीव नूरानी'), (87, 'Seija Tolonen-Mäkinen');

insert into airports (code, name) values ('LIN', 'Linate airport'), ('BOM', 'Chhatrapati Shivaji International airport'), ('CDG', 'Charles de Gaulle International airport'), ('PBI', 'Palm Beach International airport'), ('EWR', 'Newark International airport'), ('PNQ', 'Pune airport'), ('RAO', 'Leite Lopes airport'), ('LYS', 'Lyon airport'), ('USH', 'Ushuaia airport'), ('MCM', 'Monte Carlo Heliport'), ('SAT', 'San Antonio International airport'), ('TNA', 'Shandong'), ('CGB', 'Marechal Rondon International airport'), ('DME', 'Domodedovo airport'), ('MUC', 'Franz-Josef-Strauss airport'), ('AUH', 'Abu Dhabi International airport'), ('VIX', 'Goiabeiras airport'), ('KUL', 'Kuala Lumpur International airport'), ('UDI', 'Coronel Aviador Cesar Bombonato airport'), ('DLC', 'Chou Shui Tzu airport'), ('MRV', 'Mineralnyye Vody'), ('DUS', 'Dusseldorf International airport'), ('ACE', 'Arrecife airport'), ('YHZ', 'Halifax International airport'), ('KTM', 'Tribhuvan International airport'), ('DCA', 'Washington National airport'), ('ITM', 'Osaka International airport'), ('HET', 'Huhehaote airport'), ('CCU', 'Netaji Subhash Chandra Bose International Airpor'), ('DTW', 'Detroit Metropolitan Wayne County airport'), ('TPA', 'Tampa International airport'), ('CUN', 'Cancun airport'), ('COR', 'Ingeniero Ambrosio L.V. Taravella International '), ('MDZ', 'El Plumerillo airport'), ('OPO', 'Porto airport'), ('ASU', 'Silvio Pettirossi International airport'), ('HOU', 'William P Hobby airport'), ('BGO', 'Bergen Flesland airport'), ('MSQ', 'Velikiydvor airport'), ('MAD', 'Barajas airport'), ('PUQ', 'Carlos Ibanez de Campo International airport'), ('TJA', 'Capitan Oriel Lea Plaza airport'), ('HKG', 'Hong Kong International airport'), ('SJC', 'Norman Y Mineta San Jose International airport'), ('NKG', 'Nanjing Lukou International airport'), ('IGR', 'Cataratas del Iguazu airport'), ('OAK', 'Oakland International airport');

insert into airlines (code, name) values ('AC', 'Air Canada'), ('AI', 'Air India'), ('AN', 'Air New Zealand'), ('BA', 'Batik Air'), ('BC', 'Beijing Capital Airlines'), ('CS', 'China Southern Airlines'), ('CU', 'China United Airlines'), ('FA', 'Frontier Airlines'), ('MI', 'Maya Island Air'), ('NA', 'Nok Air'), ('OA', 'Oman Air'), ('PA', 'Philippine Airlines'), ('SA', 'Shanghai Airlines'), ('SC', 'Sichuan Airlines'), ('SK', 'Skymark Airlines'), ('SP', 'Spirit Airlines'), ('TA', 'Tropic Air'), ('TK', 'Turkish Airlines'), ('VA', 'VietJet Air'), ('WA', 'West Air (China)');
