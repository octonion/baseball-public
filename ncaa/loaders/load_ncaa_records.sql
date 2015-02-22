begin;

drop table if exists ncaa.records;

create table ncaa.records (
	team_id		      integer,
	team_name	      text,
	year		      integer,
	wins		      integer,
	losses		      integer,
	ties		      integer,
	games		      integer
);

copy ncaa.records from '/tmp/ncaa_records.csv' with delimiter as ',' csv quote as '"';

commit;
