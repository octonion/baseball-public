begin;

drop table if exists ncaa.conferences;

create table ncaa.conferences (
       year  		      integer,
       division_id	      integer,
       ranking_id	      integer,
       conference_key	      text,
       primary key (year,division_id,conference_key)
);

copy ncaa.conferences from '/tmp/conferences.tsv' with delimiter as E'\t' csv header;

commit;
