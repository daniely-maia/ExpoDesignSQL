	-- DQL: consultas sql úteis

-- 1. Pódio de autores com mais projetos publicados
-- (contando solo ou em equipe)
select 
    a.username,
    u.nome_usuario,
    count(distinct p1.codigo_proj) as projetos_solo,
    count(distinct p2.codigo_proj) as projetos_em_equipe,
    count(distinct p1.codigo_proj) + count(distinct p2.codigo_proj) as total_projetos
from usuario u
join autor a on u.username = a.username
join projeto p1 on a.matricula = p1.matricula
join trabalho_em_equipe t on a.matricula in (
	select matricula from membros_equipe where codigo_equipe = t.codigo_equipe
)
join projeto p2 on t.codigo_proj = p2.codigo_proj
group by a.username, u.nome_usuario
order by total_projetos desc
limit 3;

-- 2. Top 5 dos anos com mais projetos por disciplina
select 
	p.ano,
	count(p.codigo_proj) as qtd_projetos,
	d.nome_disc
from projeto p
join disciplina d on p.codigo_disc = d.codigo_disc
group by p.ano, d.nome_disc
order by qtd_projetos desc
limit 5;

-- 3. Ferramentas utilizadas e a quantidade de projetos que as utilizam
-- (por ordem das mais utilizadas)
select
	f.nome_ferr,
	count(f.nome_ferr) as qtd_projetos
from ferramenta f
join ferr_proj fp on f.id_ferr = fp.id_ferr
join projeto p on fp.codigo_proj = p.codigo_proj
group by f.nome_ferr
order by qtd_projetos desc;

-- 4. Equipes formadas (e a quantidade de integrantes) que não têm nenhum
-- projeto publicado
-- (aqui tem equipes com só um integrante, IA inseriu mal)
select 
	e.codigo_equipe,
	e.nome_equipe,
	count(m.codigo_equipe) as qtd_integrantes
from equipe e
join membros_equipe m on e.codigo_equipe = m.codigo_equipe
and e.codigo_equipe not in (
    select t.codigo_equipe 
    from trabalho_em_equipe t, equipe e
    where t.codigo_equipe = e.codigo_equipe
)
group by e.codigo_equipe
order by e.codigo_equipe;

-- 5. Autores que não estão em nenhuma equipe
select a.username, u.nome_usuario
from autor a
join usuario u on a.username = u.username
and a.matricula not in (
    select matricula from membros_equipe
);

-- 6. Quantidades totais na plataforma de usuários (comuns e autores),
-- equipes e projetos (solo e em equipe) publicados
select 
    (select count(*) from usuario) as total_usuarios,
	(select count(*) from usuario
	 where username not in(
		select username from autor
	 )) as qtd_usuarios_comuns,
    (select count(*) from autor) as qtd_autores,
    (select count(*) from equipe) as qtd_equipes,
    (select count(*) from projeto) as total_projetos,
	(select count(*) from projeto
	 where matricula is not null) as qtd_projetos_solo,
	(select count(*) from trabalho_em_equipe) as qtd_projetos_em_equipe;

-- 7. Projetos por ordem de maior complexidade
-- (que usaram mais ferramentas)
select p.titulo, count(fp.id_ferr)
from projeto p
join ferr_proj fp on p.codigo_proj = fp.codigo_proj
group by p.titulo
order by count(fp.id_ferr) desc;

-- 8. Pegar informação de contato de autores que
-- tenham projetos publicados na disciplina de 'Modelagem',
-- mostrando também tais projetos
select 
    a.matricula,
    a.email,
    u.username,
    u.nome_usuario,
    d.nome_disc,
    p.titulo as nome_projeto,
	g.url_capa as capa
from autor a
join usuario u on a.username = u.username
join projeto p on a.matricula = p.matricula
join disciplina d on p.codigo_disc = d.codigo_disc
join galeria g on p.codigo_proj = g.codigo_proj
where d.nome_disc like '%Modelagem%';

-- 9. Equipes que estão acima da média de publicação
select
	e.codigo_equipe,
	e.nome_equipe,
	count(t.codigo_equipe) as qtd_projetos
from trabalho_em_equipe t
join equipe e on t.codigo_equipe = e.codigo_equipe
group by e.codigo_equipe, e.nome_equipe
having count(t.codigo_equipe) > (
    select round(avg(qtd))
    from (
        select count(codigo_equipe) as qtd
        from trabalho_em_equipe
        group by codigo_equipe
    )
)
order by count(t.codigo_equipe) desc, e.nome_equipe;

-- 10. Pódio de autores com mais links no perfil
select
	a.username,
	u.nome_usuario,
	count(l.matricula) as qtd_links
from links l
join autor a on l.matricula = a.matricula
join usuario u on a.username = u.username
group by a.username, u.nome_usuario
order by count(l.matricula) desc
limit 3;

-- 11. Projeto mais antigo e mais recente dos autores,
-- que tenham pelo menos 2 anos de intervalo
select 
    a.username,
    u.nome_usuario,
    max(p.ano) as proj_mais_recente,
    min(p.ano) as proj_mais_antigo,
    (max(p.ano) - min(p.ano)) as intervalo
from usuario u
join autor a on u.username = a.username
join projeto p on a.matricula = p.matricula
group by a.username, u.nome_usuario
having (max(p.ano) - min(p.ano)) >= 2
order by intervalo desc, u.nome_usuario;

-- 12. Projetos ordenados pela quantidade de imagens nas galerias
select 
    p.codigo_proj,
    p.titulo,
    count(ig.id_imagem) as qtd_imagens
from projeto p
join galeria g on p.codigo_proj = g.codigo_proj
join imagem_galeria ig on g.codigo_galeria = ig.codigo_galeria
group by p.codigo_proj, p.titulo, g.codigo_galeria
order by qtd_imagens desc, codigo_proj;

-- 13. Todos os links do domínio 'github', e os autores a quem pertencem
select l.url_link, a.username, u.nome_usuario
from links l
join autor a on l.matricula = a.matricula
join usuario u on a.username = u.username
where l.url_link like '%github%';

-- 14. Projetos publicados (e seus autores) no ano de lançamento da plataforma
-- (projetos do ano mais antigo)

-- Certificando que não tem nenhum trabalho em equipe no ano mais antigo
select
	p.titulo,
	p.ano,
	d.nome_disc,
	e.nome_equipe
from projeto p
join disciplina d on p.codigo_disc = d.codigo_disc
join trabalho_em_equipe te on p.codigo_proj = te.codigo_proj
join equipe e on te.codigo_equipe = e.codigo_equipe
where p.ano = (select min(ano) from projeto);

-- Agora sim
select
	p.titulo,
	a.username,
	u.nome_usuario,
	d.nome_disc
from projeto p
join disciplina d on p.codigo_disc = d.codigo_disc
join autor a on p.matricula = a.matricula
join usuario u on a.username = u.username
where p.ano in (
    select min(ano)from projeto
);
