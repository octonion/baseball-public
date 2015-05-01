begin;

drop table if exists ncaa_pbp.years_divisions;

create table ncaa_pbp.years_divisions (
	sport_code	      text,
	year		      integer,
	division	      integer,
	primary key (sport_code, year, division)
);

copy ncaa_pbp.years_divisions from '/tmp/years_divisions.csv' with delimiter as E'\t' csv header;

commit;
