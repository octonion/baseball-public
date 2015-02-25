
begin;

drop table if exists njcaa._schedule_factors;

create table njcaa._schedule_factors (
        team_id			integer,
	year			integer,
        park                    float,
        offensive               float,
        defensive		float,
        strength                float,
        park_offensive          float,
        park_defensive          float,
        schedule_park           float,
        schedule_offensive      float,
        schedule_defensive      float,
        schedule_strength       float,
        schedule_park_offensive float,
        schedule_park_defensive float,
        schedule_offensive_all	float,
        schedule_defensive_all	float,
        primary key (team_id,year)
);

--truncate njcaa._schedule_factors;

-- park
-- defensive
-- offensive
-- strength 
-- schedule_park
-- schedule_offensive
-- schedule_defensive
-- schedule_strength 
-- schedule_park_offensive
-- schedule_park_defensive

insert into njcaa._schedule_factors
(team_id,year,park,offensive,defensive)
(
select o.level::integer,o.year,p.exp_factor,o.exp_factor,d.exp_factor
from njcaa._factors o
left outer join njcaa._factors d
  on (d.level,d.year,d.parameter)=(o.level,o.year,'defense')
left outer join njcaa._factors p
  on (p.level,p.parameter)=(o.level,'park')
where o.parameter='offense'
);

update njcaa._schedule_factors
set strength=offensive/defensive,
    park_offensive=park*offensive,
    park_defensive=park*defensive;

----

drop table public.r;

create table public.r (
         team_id		integer,
	 team_div		integer,
         opponent_id		integer,
	 opponent_div		integer,
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
(team_id,team_div,opponent_id,opponent_div,park_id,game_date,year,field_id)
(
select
r.team_id,
r.team_div,
r.opponent_id,
r.opponent_div,
r.park_id,
r.game_date,
r.year,
r.field
from njcaa.results r
where r.year between 2002 and 2012
);

update public.r
set
offensive=o.offensive,
defensive=o.defensive,
park=o.park,
strength=o.strength
from njcaa._schedule_factors o
where (r.opponent_id,r.year)=(o.team_id,o.year);

-- neutral park

--update public.r
--set park=f.exp_factor
--from njcaa._factors f
--where (f.parameter,f.level)=('park','0')
--and r.park_id=0;

-- field

update public.r
set field=f.exp_factor
from njcaa._factors f
where (f.parameter,f.level)=('field',r.field_id);

-- opponent h_div

update public.r
set h_div=f.exp_factor
from njcaa._factors f
where (f.parameter,f.level::integer)=('h_div',r.opponent_div);

-- opponent p_div

update public.r
set p_div=f.exp_factor
from njcaa._factors f
where (f.parameter,f.level::integer)=('p_div',r.opponent_div);

create temporary table rs (
         team_id		integer,
         year                   integer,
         park                   float,
         offensive              float,
         defensive              float,
         strength               float,
         park_offensive         float,
         park_defensive         float,
         offensive_all		float,
         defensive_all		float
);

insert into rs
(team_id,year,
 park,offensive,defensive,
 strength,park_offensive,park_defensive,
 offensive_all,defensive_all)
(
select
team_id,
year,
exp(avg(log(park))),
exp(avg(log(offensive*h_div))),
exp(avg(log(defensive*p_div))),
exp(avg(log(strength*(h_div/p_div)*(field*field)))),
exp(avg(log(park*offensive*h_div))),
exp(avg(log(park*defensive*p_div))),
exp(avg(log(park*offensive*h_div*field))),
exp(avg(log(park*defensive*p_div/field)))
from r
group by team_id,year
);

update njcaa._schedule_factors
set
  schedule_park=rs.park,
  schedule_offensive=rs.offensive,
  schedule_defensive=rs.defensive,
  schedule_strength=rs.strength,
  schedule_park_offensive=rs.park_offensive,
  schedule_park_defensive=rs.park_defensive,
  schedule_offensive_all=rs.offensive_all,
  schedule_defensive_all=rs.defensive_all
from rs
where
  (_schedule_factors.team_id,_schedule_factors.year)=
  (rs.team_id,rs.year);

commit;
