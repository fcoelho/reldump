create table one (
	id_one integer,
	constraint pk primary key (id_one)
);

create table two (
	id_one integer,
	id_two integer,
	constraint pk primary key (id_one, id_two),
	constraint fk_two_to_one foreign key (id_one) references one (id_one)
);

create table three (
	id_one integer,
	id_two integer,
	id_three integer,
	constraint pk primary key (id_one, id_two, id_three),
	constraint fk_three_to_two foreign key (id_one, id_two) references two (id_one, id_two)
);

create table four (
	id_one integer,
	id_two integer,
	id_three integer,
	id_four integer,
	constraint pk primary key (id_one, id_two, id_three, id_four),
	constraint fk_four_to_three foreign key (id_one, id_two, id_three) references three (id_one, id_two, id_three)
);

create table five (
	id_one integer,
	id_two integer,
	id_three integer,
	id_four integer,
	id_five integer,
	constraint pk primary key (id_one, id_two, id_three, id_four, id_five),
	constraint fk_five_to_four foreign key (id_one, id_two, id_three, id_four) references four (id_one, id_two, id_three, id_four)
);

create table multi_ref_five(
	id varchar(10),
	a_id_one integer,
	a_id_two integer,
	a_id_three integer,
	a_id_four integer,
	a_id_five integer,
	b_id_one integer,
	b_id_two integer,
	b_id_three integer,
	b_id_four integer,
	b_id_five integer,
	constraint pk primary key (id),
	constraint fk_a_to_five foreign key (a_id_one, a_id_two, a_id_three, a_id_four, a_id_five) references five (id_one, id_two, id_three, id_four, id_five),
	constraint fk_b_to_five foreign key (b_id_one, b_id_two, b_id_three, b_id_four, b_id_five) references five (id_one, id_two, id_three, id_four, id_five)
);

insert into one values (1);
insert into one values (2);
insert into one values (3);
insert into one values (4);
insert into one values (5);
insert into one values (6);
insert into one values (7);
insert into one values (8);
insert into one values (9);
insert into one values (10);
insert into two values (1, 1);
insert into two values (1, 2);
insert into two values (1, 3);
insert into two values (1, 4);
insert into two values (1, 5);
insert into two values (2, 1);
insert into two values (2, 2);
insert into two values (2, 3);
insert into two values (2, 4);
insert into two values (2, 5);
insert into three values (1, 1, 1);
insert into three values (1, 1, 2);
insert into three values (1, 1, 3);
insert into three values (1, 1, 4);
insert into three values (1, 1, 5);
insert into three values (2, 1, 1);
insert into three values (2, 1, 2);
insert into three values (2, 1, 3);
insert into three values (2, 1, 4);
insert into three values (2, 1, 5);
insert into four values (1, 1, 1, 1);
insert into four values (1, 1, 1, 2);
insert into four values (1, 1, 1, 3);
insert into four values (1, 1, 1, 4);
insert into four values (1, 1, 1, 5);
insert into four values (2, 1, 1, 1);
insert into four values (2, 1, 1, 2);
insert into four values (2, 1, 1, 3);
insert into four values (2, 1, 1, 4);
insert into four values (2, 1, 1, 5);
insert into five values (1, 1, 1, 1, 1);
insert into five values (1, 1, 1, 1, 2);
insert into five values (1, 1, 1, 1, 3);
insert into five values (1, 1, 1, 1, 4);
insert into five values (1, 1, 1, 1, 5);
insert into five values (2, 1, 1, 1, 1);
insert into five values (2, 1, 1, 1, 2);
insert into five values (2, 1, 1, 1, 3);
insert into five values (2, 1, 1, 1, 4);
insert into five values (2, 1, 1, 1, 5);
insert into multi_ref_five values ('a', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
insert into multi_ref_five values ('b', 1, 1, 1, 1, 1, 1, 1, 1, 1, 2);
insert into multi_ref_five values ('c', 1, 1, 1, 1, 1, 1, 1, 1, 1, 3);
insert into multi_ref_five values ('d', 1, 1, 1, 1, 1, 1, 1, 1, 1, 4);
insert into multi_ref_five values ('e', 1, 1, 1, 1, 1, 1, 1, 1, 1, 5);
insert into multi_ref_five values ('f', 2, 1, 1, 1, 1, 2, 1, 1, 1, 1);
insert into multi_ref_five values ('g', 2, 1, 1, 1, 1, 2, 1, 1, 1, 2);
insert into multi_ref_five values ('h', 2, 1, 1, 1, 1, 2, 1, 1, 1, 3);
insert into multi_ref_five values ('i', 2, 1, 1, 1, 1, 2, 1, 1, 1, 4);
insert into multi_ref_five values ('j', 2, 1, 1, 1, 1, 2, 1, 1, 1, 5);
insert into multi_ref_five values ('k', 1, 1, 1, 1, 2, 1, 1, 1, 1, 1);
insert into multi_ref_five values ('l', 1, 1, 1, 1, 2, 1, 1, 1, 1, 2);
insert into multi_ref_five values ('m', 1, 1, 1, 1, 2, 1, 1, 1, 1, 3);
insert into multi_ref_five values ('n', 1, 1, 1, 1, 2, 1, 1, 1, 1, 4);
insert into multi_ref_five values ('o', 1, 1, 1, 1, 2, 1, 1, 1, 1, 5);
insert into multi_ref_five values ('p', 2, 1, 1, 1, 2, 2, 1, 1, 1, 1);
insert into multi_ref_five values ('q', 2, 1, 1, 1, 2, 2, 1, 1, 1, 2);
insert into multi_ref_five values ('r', 2, 1, 1, 1, 2, 2, 1, 1, 1, 3);
insert into multi_ref_five values ('s', 2, 1, 1, 1, 2, 2, 1, 1, 1, 4);
insert into multi_ref_five values ('t', 2, 1, 1, 1, 2, 2, 1, 1, 1, 5);
insert into multi_ref_five values ('u', 1, 1, 1, 1, 3, 1, 1, 1, 1, 1);
insert into multi_ref_five values ('v', 1, 1, 1, 1, 3, 1, 1, 1, 1, 2);
insert into multi_ref_five values ('w', 1, 1, 1, 1, 3, 1, 1, 1, 1, 3);
insert into multi_ref_five values ('x', 1, 1, 1, 1, 3, 1, 1, 1, 1, 4);
insert into multi_ref_five values ('y', 1, 1, 1, 1, 3, 1, 1, 1, 1, 5);
insert into multi_ref_five values ('z', 2, 1, 1, 1, 3, 2, 1, 1, 1, 1);
