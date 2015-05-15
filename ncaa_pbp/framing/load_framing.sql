begin;

drop table if exists ncaa_pbp._framing;

create table ncaa_pbp._framing (
	catcher_id	      integer,
	framing		      float,
	primary key (catcher_id)

);

copy ncaa_pbp._framing from '/tmp/framing.csv' csv;

commit;
