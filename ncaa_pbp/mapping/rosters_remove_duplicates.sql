begin;

create temporary table duplicates (
       team_id	       integer,
       player_name     text,
       id_1	       integer,
       ncaa_id_1     integer,
       id_2	       integer,
       ncaa_id_2     integer
);

insert into duplicates
select
r1.team_id,
r1.player_name,
r1.id,
r1.ncaa_id,
r2.id,
r2.ncaa_id
from ncaa_pbp.team_rosters r1
join ncaa_pbp.team_rosters r2
 on (r2.team_id,r2.player_name)=(r1.team_id,r1.player_name)
and r1.id<r2.id;

update ncaa_pbp.team_rosters
set id=d.id_1
from duplicates d
where team_rosters.id = d.id_2
and d.ncaa_id_1 is not null
and d.ncaa_id_2 is not null;

delete from ncaa_pbp.team_rosters
where id in (
select id_2 from duplicates
where (ncaa_id_1 is not null) and (ncaa_id_2 is null)
union
select id_1 from duplicates
where (ncaa_id_1 is null) and (ncaa_id_2 is not null)
union
select id_2 from duplicates
where (ncaa_id_1 is null) and (ncaa_id_2 is null)
);

--select * from duplicates
--order by team_id,player_name;

commit;
