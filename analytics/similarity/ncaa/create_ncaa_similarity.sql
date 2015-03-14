begin;

drop table if exists ncaa._player_similarity;

create table ncaa._player_similarity (
       player_id	text,
       year		integer,
       type		text,
       comp_name	text,
       comp_id		text,
       comp_year	integer,
       comp_class	text,
       d		float,
       rank		integer
--       primary key (player_id,year,type,rank)
);

commit;
