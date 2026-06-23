  -- DDL: tables creation
-- DDL: course, tool, user

create table course (
	course_id varchar(8) primary key,
	course_name varchar(100) not null
);

create table tool (
	tool_id serial primary key,
	tool_name varchar(50) not null
);

create table "user" (
	username varchar(20) primary key,
	user_fullname varchar(80) not null
);

-- DDL: author, urls, team, team_members

create table author (
	registration_number char(6) primary key,
	email varchar(75) not null unique,
	username varchar(20) not null,
	constraint fk_user_author foreign key(username) references "user"(username)
);

create table urls (
	url_id serial primary key,
	url_link varchar(500) not null unique,
	url_name varchar(50),
	registration_number char(6) not null,
	constraint fk_author_url foreign key(registration_number) references author(registration_number)
);

create table team (
	team_id serial primary key,
	team_name varchar(30) not null default 'Unnamed Team'
);

create table team_members (
	registration_number char(6),
	team_id integer,
	primary key (registration_number, team_id),
	constraint fk_registration_team foreign key(registration_number) references author(registration_number),
	constraint fk_team_id foreign key(team_id) references team(team_id)
);

-- DDL: project, tool_proj, team_project, image, gallery, image_gallery

create table project (
	proj_id serial primary key,
	title varchar(100) not null,
	description varchar(1000),
	year integer,
	registration_number char(6),
	course_id varchar(8) not null,
	constraint fk_registration_project foreign key(registration_number) references author(registration_number),
	constraint fk_course_project foreign key(course_id) references course(course_id)
);

create table tool_proj (
	tool_id integer,
	proj_id integer,
	primary key (tool_id, proj_id),
	constraint fk_tool_proj foreign key(tool_id) references tool(tool_id),
	constraint fk_proj_tool foreign key(proj_id) references project(proj_id)
);

create table team_project (
	proj_id integer,
	team_id integer,
	primary key (proj_id, team_id),
	constraint fk_proj_team foreign key(proj_id) references project(proj_id),
	constraint fk_team_proj foreign key(team_id) references team(team_id)
);

create table image (
	img_id serial primary key,
	img_url varchar(500) not null unique
);

create table gallery (
	gallery_id serial primary key,
	cover_url varchar(500) not null unique,
	proj_id integer not null unique,
	constraint fk_cover_image foreign key(cover_url) references image(img_url),
	constraint fk_proj_gallery foreign key(proj_id) references project(proj_id)
);

create table image_gallery (
	img_id integer primary key,
	gallery_id integer not null,
	constraint fk_img_image foreign key(img_id) references image(img_id),
	constraint fk_gallery_image foreign key(gallery_id) references gallery(gallery_id)
);
