
begin;

drop table if exists naia._schedule_factors;

create table naia._schedule_factors (
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

--truncate naia._schedule_factors;

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

insert into naia._schedule_factors
(team_id,year,park,offensive,defensive)
(
select o.level::integer,o.year,p.exp_factor,o.exp_factor,d.exp_factor
from naia._factors o
left outer join naia._factors d
  on (d.level,d.year,d.parameter)=(o.level,o.year,'defense')
left outer join naia._factors p
  on (p.level,p.parameter)=(o.level,'park')
where o.parameter='offense'
);

update naia._schedule_factors
set strength=offensive/defensive,
    park_offensive=park*offensive,
    park_defensive=park*defensive;

----

drop table public.r;

create table public.r (
         team_id		integer,
         opponent_id		integer,
         park_id		integer,
         game_date              date,
         year                   integer,
	 field_id		text,
         park                   float,
         offensive              float,
         defensive		float,
         strength               float,
	 field			float
);

insert into public.r
(team_id,opponent_id,park_id,game_date,year,field_id)
(
select
r.team_id,
r.opponent_id,
r.park_id,
r.game_date,
r.year,
r.field
from naia.results r
where r.year between 2004 and 2015
);

update public.r
set
offensive=o.offensive,
defensive=o.defensive,
park=o.park,
strength=o.strength
from naia._schedule_factors o
where (r.opponent_id,r.year)=(o.team_id,o.year);

-- neutral park

update public.r
set park=f.exp_factor
from naia._factors f
where (f.parameter,f.level)=('park','0')
and r.park_id=0;

-- field

update public.r
set field=f.exp_factor
from naia._factors f
where (f.parameter,f.level)=('field',r.field_id);

--update r
--set offensive=0.707
--where offensive is null;

--update r
--set defensive=0.707
--where defensive is null;

--update r
--set strength=offensive/defensive;

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
exp(avg(log(offensive))),
exp(avg(log(defensive))),
exp(avg(log(strength))),
exp(avg(log(park*offensive))),
exp(avg(log(park*defensive))),
exp(avg(log(park*offensive))),
exp(avg(log(park*defensive*field)))
from r
group by team_id,year
);

update naia._schedule_factors
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
