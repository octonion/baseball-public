begin;

drop table if exists bbref.standard_pitching;

create table bbref.standard_pitching (
       year					integer,
       rank					integer,
       player_name				text,
       player_url				text,
       player_id				text,
       age					integer,
       team_id					text,
       lg					text,
       w					integer,
       l					integer,
       wlp					float,
       era					float,
       g					integer,
       gs					integer,
       gf					integer,
       cg					integer,
       sho					integer,
       sv					integer,
       ip					text,
       h					integer,
       r					integer,
       er					integer,
       hr					integer,
       bb					integer,
       ibb					integer,
       so					integer,
       hbp					integer,
       bk					integer,
       wp					integer,
       bf					integer,
       "era+"					float,
       fip					float,
       whip					float,
       h9					float,
       hr9					float,
       bb9					float,
       so9					float,
       so_bb					float
-- Need to generate stint ID
--       primary key (year, player_id, team_id, lg)
);

copy bbref.standard_pitching from '/tmp/standard-pitching.csv' csv;

commit;
