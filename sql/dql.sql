  -- DQL: useful sql queries

-- 1. Authors podium with most published projects
-- (counting solo or in teams)
select 
    a.username,
    u.user_fullname,
    count(distinct p1.proj_id) as solo_projects,
    count(distinct p2.proj_id) as team_projects,
    count(distinct p1.proj_id) + count(distinct p2.proj_id) as total_projects
from "user" u
join author a on u.username = a.username
join project p1 on a.registration_number = p1.registration_number
join team_project t on a.registration_number in (
	select registration_number from team_members where team_id = t.team_id
)
join project p2 on t.proj_id = p2.proj_id
group by a.username, u.user_fullname
order by total_projects desc
limit 3;

-- 2. Top 5 years with most projects per course
select 
	p.year,
	count(p.proj_id) as project_count,
	c.course_name
from project p
join course c on p.course_id = c.course_id
group by p.year, c.course_name
order by project_count desc
limit 5;

-- 3. Tools used and the number of projects that use them
-- (ordered by most used)
select
	t.tool_name,
	count(t.tool_name) as project_count
from tool t
join tool_proj tp on t.tool_id = tp.tool_id
join project p on tp.proj_id = p.proj_id
group by t.tool_name
order by project_count desc;

-- 4. Formed teams (and their member count) that have no
-- published projects
-- (there are teams with only one member, AI inserted poorly)
select 
	t.team_id,
	t.team_name,
	count(tm.team_id) as member_count
from team t
join team_members tm on t.team_id = tm.team_id
and t.team_id not in (
    select tp.team_id 
    from team_project tp, team t
    where tp.team_id = t.team_id
)
group by t.team_id
order by t.team_id;

-- 5. Authors who are not in any team
select a.username, u.user_fullname
from author a
join "user" u on a.username = u.username
and a.registration_number not in (
    select registration_number from team_members
);

-- 6. Total counts on the platform of users (regular and authors),
-- teams and published projects (solo and in teams)
select 
    (select count(*) from "user") as total_users,
	(select count(*) from "user"
	 where username not in(
		select username from author
	 )) as regular_users,
    (select count(*) from author) as authors_count,
    (select count(*) from team) as teams_count,
    (select count(*) from project) as total_projects,
	(select count(*) from project
	 where registration_number is not null) as solo_projects,
	(select count(*) from team_project) as team_projects;

-- 7. Projects ordered by greatest complexity
-- (that used more tools)
select p.title, count(tp.tool_id)
from project p
join tool_proj tp on p.proj_id = tp.proj_id
group by p.title
order by count(tp.tool_id) desc;

-- 8. Get contact information from authors who
-- have published projects in the 'Modelagem' course,
-- also showing such projects
select 
    a.registration_number,
    a.email,
    u.username,
    u.user_fullname,
    c.course_name,
    p.title as project_name,
	g.cover_url as cover
from author a
join "user" u on a.username = u.username
join project p on a.registration_number = p.registration_number
join course c on p.course_id = c.course_id
join gallery g on p.proj_id = g.proj_id
where c.course_name like '%Modelagem%';

-- 9. Teams that are above the publication average
select
	t.team_id,
	t.team_name,
	count(tp.team_id) as project_count
from team_project tp
join team t on tp.team_id = t.team_id
group by t.team_id, t.team_name
having count(tp.team_id) > (
    select round(avg(qtd))
    from (
        select count(team_id) as qtd
        from team_project
        group by team_id
    )
)
order by count(tp.team_id) desc, t.team_name;

-- 10. Authors podium with most profile links
select
	a.username,
	u.user_fullname,
	count(u_r.registration_number) as links_count
from urls u_r
join author a on u_r.registration_number = a.registration_number
join "user" u on a.username = u.username
group by a.username, u.user_fullname
order by count(u_r.registration_number) desc
limit 3;

-- 11. Oldest and newest project of authors,
-- who have at least a 2-year gap
select 
    a.username,
    u.user_fullname,
    max(p.year) as newest_project,
    min(p.year) as oldest_project,
    (max(p.year) - min(p.year)) as gap
from "user" u
join author a on u.username = a.username
join project p on a.registration_number = p.registration_number
group by a.username, u.user_fullname
having (max(p.year) - min(p.year)) >= 2
order by gap desc, u.user_fullname;

-- 12. Projects ordered by the number of images in galleries
select 
    p.proj_id,
    p.title,
    count(ig.img_id) as image_count
from project p
join gallery g on p.proj_id = g.proj_id
join image_gallery ig on g.gallery_id = ig.gallery_id
group by p.proj_id, p.title, g.gallery_id
order by image_count desc, proj_id;

-- 13. All links from the 'github' domain, and their authors
select u_r.url_link, a.username, u.user_fullname
from urls u_r
join author a on u_r.registration_number = a.registration_number
join "user" u on a.username = u.username
where u_r.url_link like '%github%';

-- 14. Published projects (and their authors) in the platform's launch year
-- (projects from the oldest year)

-- Ensuring there are no team projects in the oldest year
select
	p.title,
	p.year,
	c.course_name,
	t.team_name
from project p
join course c on p.course_id = c.course_id
join team_project tp on p.proj_id = tp.proj_id
join team t on tp.team_id = t.team_id
where p.year = (select min(year) from project);

-- Now for real
select
	p.title,
	a.username,
	u.user_fullname,
	c.course_name
from project p
join course c on p.course_id = c.course_id
join author a on p.registration_number = a.registration_number
join "user" u on a.username = u.username
where p.year in (
    select min(year) from project
);
