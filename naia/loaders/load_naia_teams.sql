begin;

drop table if exists naia.teams;

create table naia.teams (
       team_id		integer,
       team_name	text,
       year		integer,
       primary key (team_id, year)
);

insert into naia.teams
(team_id,team_name,year)
(
select distinct team_id,team_name,year
from naia.games
);

commit;
