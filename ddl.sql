	-- DDL: criação das tabelas
-- DDL: disciplina, ferramenta, usuario

create table disciplina (
	codigo_disc varchar(8) primary key,
	nome_disc varchar(100) not null
);

create table ferramenta (
	id_ferr serial primary key,
	nome_ferr varchar(50) not null
);

create table usuario (
	username varchar(20) primary key,
	nome_usuario varchar(80) not null
);

-- DDL: autor, links, equipe, membros_equipe

create table autor (
	matricula char(6) primary key,
	email varchar(75) not null unique,
	username varchar(20) not null,
	constraint fk_usuario_autor foreign key(username) references usuario(username)
);

create table links (
	id_link serial primary key,
	url_link varchar(500) not null unique,
	nome_link varchar(50),
	matricula char(6) not null,
	constraint fk_autor_link foreign key(matricula) references autor(matricula)
);

create table equipe (
	codigo_equipe serial primary key,
	nome_equipe varchar(30) not null default 'Equipe sem nome definido'
);

create table membros_equipe (
	matricula char(6),
	codigo_equipe integer,
	primary key (matricula, codigo_equipe),
	constraint fk_matricula_equipe foreign key(matricula) references autor(matricula),
	constraint fk_cod_equipe foreign key(codigo_equipe) references equipe(codigo_equipe)
);

-- DDL: projeto, ferr_proj, trabalho_em_equipe, imagem, galeria, imagem_galeria

create table projeto (
	codigo_proj serial primary key,
	titulo varchar(100) not null,
	descricao varchar(1000),
	ano integer,
	matricula char(6),
	codigo_disc varchar(8) not null,
	constraint fk_matricula_projeto foreign key(matricula) references autor(matricula),
	constraint fk_cod_disc_projeto foreign key(codigo_disc) references disciplina(codigo_disc)
);

create table ferr_proj (
	id_ferr integer,
	codigo_proj integer,
	primary key (id_ferr, codigo_proj),
	constraint fk_id_ferr_proj foreign key(id_ferr) references ferramenta(id_ferr),
	constraint fk_cod_proj foreign key(codigo_proj) references projeto(codigo_proj)
);

create table trabalho_em_equipe (
	codigo_proj integer,
	codigo_equipe integer,
	primary key (codigo_proj, codigo_equipe),
	constraint fk_cod_proj_equipe foreign key(codigo_proj) references projeto(codigo_proj),
	constraint fk_cod_equipe foreign key(codigo_equipe) references equipe(codigo_equipe)
);

create table imagem (
	id_imagem serial primary key,
	url_imagem varchar(500) not null unique
	
);

create table galeria (
	codigo_galeria serial primary key,
	url_capa varchar(500) not null unique,
	codigo_proj integer not null unique,
	constraint fk_url_capa foreign key(url_capa) references imagem(url_imagem),
	constraint fk_cod_proj_galeria foreign key(codigo_proj) references projeto(codigo_proj)
);

create table imagem_galeria (
	id_imagem integer primary key,
	codigo_galeria integer not null,
	constraint fk_id_imagem foreign key(id_imagem) references imagem(id_imagem),
	constraint fk_codigo_galeria foreign key(codigo_galeria) references galeria(codigo_galeria)
);
