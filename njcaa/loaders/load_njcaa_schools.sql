begin;

drop table if exists njcaa.schools;

create table njcaa.schools (
       year					integer,
       division_id				integer,
       school_id				text,
       school_name				text,
       school_url				text,
       primary key (year,division_id,school_id)
);

/*
create table njcaa.schools (
       year					integer,
       season_id				integer,
       sport_id					integer,
       gender_id				char,
       division_id				integer,
       school_id				text,
       school_name				text,
       school_url				text,
       primary key (year,school_id)
);
*/

copy njcaa.schools from '/tmp/njcaa_schools.csv' with delimiter as E'\t' csv header;

create table njcaa.schools_older (
       year					integer,
       sport_id					integer,
       school_id				integer,
       school_name				text,
       school_url				text,
       division_id				integer,
       division_name				text,
       primary key (year,school_id)
);

copy njcaa.schools_older from '/tmp/njcaa_schools_older.csv' with delimiter as E'\t' csv header;

commit;
