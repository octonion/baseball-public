-- Requires the PostgreSQL Levenshtein functionfound in the contributed
-- fuzzystrmatch module

-- To install:
-- apt-get install postgresql-contrib
-- CREATE EXTENSION fuzzystrmatch;

begin;

drop table if exists ncaa_pbp.lev_mappings;

create table ncaa_pbp.lev_mappings (
       team_id	       integer,
       player_name     text,
       hashed_name     text,
       lev_distance    integer,
       matched_hash    text,
       matched_name    text,
       id	       integer
);

insert into ncaa_pbp.lev_mappings
(team_id,player_name,hashed_name)
(select
team_id,player_name,hashed_name
from ncaa_pbp.name_mappings
);

update ncaa_pbp.lev_mappings
set lev_distance=
(
select min(levenshtein(lev_mappings.hashed_name,r.hashed_name))
from ncaa_pbp.team_rosters r
where r.team_id=lev_mappings.team_id
);

update ncaa_pbp.lev_mappings
set matched_name=r.player_name,
    matched_hash=r.hashed_name,
    id=r.id
from ncaa_pbp.team_rosters r
where
    lev_mappings.lev_distance=levenshtein(lev_mappings.hashed_name,r.hashed_name)
and r.team_id=lev_mappings.team_id;

commit;
