begin;

drop table if exists bbref.draft_picks;

create table bbref.draft_picks (
       overall_pick				integer,
       year					integer,
       round					text,
       draft_type				text,
       fr_rnd					text,
       round_pick				integer,
       team_name				text,
       team_key					text,
       signed					text,
       player_name				text,
       mlb_url					text,
       player_id				text,
       milb_url					text,
       minors_id				text,
       position					text,
       war					float,
       b_g					integer,
       ab					integer,
       hr					integer,
       ba					float,
       ops					float,
       p_g					integer,
       w					integer,
       l					integer,
       era					float,
       whip					float,
       sv					integer,
       school_type				text,
       school_name				text,
       school_key				text

--       primary key (year_id,player_id),
--       unique (year,player_id)
);

copy bbref.draft_picks from '/tmp/draft_picks.csv' csv header;

--copy bbref.draft_picks from '/tmp/draft_picks.csv' with delimiter as E'\t' csv header;

commit;
