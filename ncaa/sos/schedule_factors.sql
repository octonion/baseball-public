
begin;

drop table if exists ncaa._schedule_factors;

create table ncaa._schedule_factors (
        school_id			integer,
	year				integer,
	year_factor			float,
        park                    	float,
        offensive               	float,
        defensive			float,
        strength                	float,
        park_offensive          	float,
        park_defensive          	float,
        schedule_park           	float,
        schedule_offensive      	float,
        schedule_defensive      	float,
        schedule_strength       	float,
        schedule_field          	float,
        schedule_park_offensive 	float,
        schedule_park_defensive 	float,
        schedule_field_park_offensive 	float,
        schedule_field_park_defensive 	float,
        primary key (school_id,year)
);

-- park
-- defensive
-- offensive
-- strength
-- schedule_field
-- schedule_park
-- schedule_offensive
-- schedule_defensive
-- schedule_strength 
-- schedule_park_offensive
-- schedule_park_defensive
-- schedule_field_park_offensive
-- schedule_field_park_defensive

insert into ncaa._schedule_factors
(school_id,year,year_factor,park,offensive,defensive)
(
select o.level::integer,o.year,
y.exp_factor,p.exp_factor,o.exp_factor,d.exp_factor
from ncaa._factors o
--left outer join ncaa._factors d
join ncaa._factors d
  on (d.level,d.year,d.parameter)=(o.level,o.year,'defense')
--left outer join ncaa._factors p
join ncaa._factors p
  on (p.level,p.parameter)=(o.level,'park')
--left outer join ncaa._factors y
join ncaa._factors y
  on (y.level::integer,y.parameter)=(o.year,'year')
where o.parameter='offense'
);

update ncaa._schedule_factors
set strength=offensive/defensive,
    park_offensive=park*offensive,
    park_defensive=park*defensive;

----

drop table if exists public.r;

create table public.r (
         school_id		integer,
	 school_div_id		integer,
         opponent_id		integer,
	 opponent_div_id	integer,
         park_id		integer,
         game_date              date,
         year                   integer,
	 field_id		text,
         park                   float,
         offensive              float,
         defensive		float,
         strength               float,
	 field			float,
	 h_div			float,
	 p_div			float
);

insert into public.r
(school_id,school_div_id,opponent_id,opponent_div_id,park_id,game_date,year,field_id)
(
select
r.school_id,
sd.div_id,
r.opponent_id,
od.div_id,
(case when site='Home' then r.school_id
      when site='Away' then r.opponent_id
      when site='Neutral' then 0 end) as park_id,
r.game_date,
r.year,
(case when site='Home' then 'hitting_home'
      when site='Away' then 'pitching_home'
      when site='Neutral' then 'none' end) as field
from ncaa.games r
join ncaa.schools_divisions sd
  on (sd.school_id,sd.year)=(r.school_id,r.year)
join ncaa.schools_divisions od
  on (od.school_id,od.year)=(r.opponent_id,r.year)
where r.year between 2002 and 2014
);

update public.r
set
offensive=o.offensive,
defensive=o.defensive,
--park=o.park,
strength=o.strength
from ncaa._schedule_factors o
where (r.opponent_id,r.year)=(o.school_id,o.year);

-- park

update public.r
set park=p.park
from ncaa._schedule_factors p
where (p.school_id,p.year)=(r.park_id,r.year);

-- neutral park

update public.r
set park=f.exp_factor
from ncaa._factors f
where (f.parameter,f.level)=('park','0')
and r.park_id=0;

-- field

update public.r
set field=f.exp_factor
from ncaa._factors f
where (f.parameter,f.level)=('field',r.field_id);

-- opponent h_div

update public.r
set h_div=f.exp_factor
from ncaa._factors f
where (f.parameter,f.level::integer)=('h_div',r.opponent_div_id);

-- opponent p_div

update public.r
set p_div=f.exp_factor
from ncaa._factors f
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
         park                   float,
         offensive              float,
         defensive              float,
         strength               float,
         field                  float,
         park_offensive         float,
         park_defensive         float,
         field_park_offensive	float,
         field_park_defensive	float
);

insert into rs
(school_id,year,
 park,offensive,defensive,strength,field,
 park_offensive,park_defensive,
 field_park_offensive,field_park_defensive)
(
select
school_id,
year,
exp(avg(log(park))), -- schedule_park
exp(avg(log(offensive*h_div))), -- schedule_offensive
exp(avg(log(defensive*p_div))), -- schedule_defensive
exp(avg(log(strength*(h_div/p_div)*(field*field)))), -- schedule_strength
exp(avg(log(field))), -- schedule_field
exp(avg(log(park*offensive*h_div))), -- schedule_park_offensive
exp(avg(log(park*defensive*p_div))), -- schedule_park_defensive
exp(avg(log(park*offensive*h_div/field))), -- schedule_field_park_offensive
exp(avg(log(park*defensive*p_div*field))) -- schedule_field_park_defensive
from r
group by school_id,year
);

update ncaa._schedule_factors
set
  schedule_park=rs.park,
  schedule_offensive=rs.offensive,
  schedule_defensive=rs.defensive,
  schedule_strength=rs.strength,
  schedule_field=rs.field,
  schedule_park_offensive=rs.park_offensive,
  schedule_park_defensive=rs.park_defensive,
  schedule_field_park_offensive=rs.field_park_offensive,
  schedule_field_park_defensive=rs.field_park_defensive
from rs
where
  (_schedule_factors.school_id,_schedule_factors.year)=
  (rs.school_id,rs.year);

commit;
