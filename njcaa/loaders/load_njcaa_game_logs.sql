begin;

drop table if exists njcaa.game_logs;

create table njcaa.game_logs (
       year					integer,
       division_id				integer,
       school_id				text,
       date					text,
       site					text,
       opponent					text,
       outcome					text,
       winning_score				integer,
       losing_score				integer,
       score					text,
       game_url					text,
       ab					integer,
       r					integer,
       h					integer,
       b2b					integer,
       b3b					integer,
       hr					integer,
       rbi					integer,
       bb					integer,
       k					integer,
       sb					integer,
       cs					integer
);

copy njcaa.game_logs from '/tmp/njcaa_game_logs.csv' with delimiter as E'\t' csv header;

commit;
