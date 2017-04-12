
begin;

drop table if exists ncaa._schedule_factors_logistic;

create table ncaa._schedule_factors_logistic (
        school_id			integer,
	year			integer,
        offensive               float,
        defensive		float,
        strength                float,
        schedule_offensive      float,
        schedule_defensive      float,
        schedule_strength       float,
        primary key (school_id,year)
);

--truncate ncaa._schedule_factors_logistic;

-- defensive
-- offensive
-- strength 
-- schedule_offensive
-- schedule_defensive
-- schedule_strength 

insert into ncaa._schedule_factors_logistic
(school_id,year,offensive,defensive)
(
select o.level::integer,o.year,o.exp_factor,d.exp_factor
from ncaa._factors_logistic o
left outer join ncaa._factors_logistic d
  on (d.level,d.year,d.parameter)=(o.level,o.year,'defense')
where o.parameter='offense'
);

update ncaa._schedule_factors_logistic
set strength=offensive/defensive;

----

drop table if exists public.r;

create table public.r (
         school_id		integer,
	 school_div_id		integer,
         opponent_id		integer,
	 opponent_div_id	integer,
         game_date              date,
         year                   integer,
	 field_id		text,
         offensive              float,
         defensive		float,
         strength               float,
	 field			float,
	 h_div			float,
	 p_div			float
);

insert into public.r
(school_id,school_div_id,opponent_id,opponent_div_id,game_date,year,field_id)
(
select
r.school_id,
r.school_div_id,
r.opponent_id,
r.opponent_div_id,
r.game_date,
r.year,
r.field
from ncaa.results r
where r.year between 2002 and 2017
);

update public.r
set
offensive=o.offensive,
defensive=o.defensive,
strength=o.strength
from ncaa._schedule_factors_logistic o
where (r.opponent_id,r.year)=(o.school_id,o.year);

-- field

update public.r
set field=f.exp_factor
from ncaa._factors_logistic f
where (f.parameter,f.level)=('field',r.field_id);

-- opponent h_div

update public.r
set h_div=f.exp_factor
from ncaa._factors_logistic f
where (f.parameter,f.level::integer)=('h_div',r.opponent_div_id);

-- opponent p_div

update public.r
set p_div=f.exp_factor
from ncaa._factors_logistic f
where (f.parameter,f.level::integer)=('p_div',r.opponent_div_id);

--update r
--set offensive=0.707
--where offensive is null;

--update r
--set defensive=0.707
--where defensive is null;

--update r
--set strength=offensive/defensive;

create temporary table rs (
         school_id		integer,
         year                   integer,
         offensive              float,
         defensive              float,
         strength               float
);

insert into rs
(school_id,year,
 offensive,defensive,
 strength)
(
select
school_id,
year,
exp(avg(log(offensive*h_div))),
exp(avg(log(defensive*p_div))),
exp(avg(log(strength*h_div/p_div)))
from r
group by school_id,year
);

update ncaa._schedule_factors_logistic
set
  schedule_offensive=rs.offensive,
  schedule_defensive=rs.defensive,
  schedule_strength=rs.strength
from rs
where
  (_schedule_factors_logistic.school_id,_schedule_factors_logistic.year)=
  (rs.school_id,rs.year);

commit;
