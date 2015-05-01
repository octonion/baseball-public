begin;

drop table if exists ncaa_pbp.years;

create table ncaa_pbp.years (
	sport_code	      text,
	year		      integer,
	primary key (sport_code, year)
);

copy ncaa_pbp.years from '/tmp/years.csv' with delimiter as E'\t' csv header;

commit;
