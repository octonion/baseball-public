select
ps.year,
ps.player_name,
ps.team_name,
ps.class_year,
ps.position,
ps.p_games_started as p_gs,
ps.p_ip,
ps.p_so,
ps.p_bb,

3*split_part(p_ip,'.',1)::integer+
(
case when coalesce(split_part(p_ip,'.',2),'0')='' then '0'
     else coalesce(split_part(p_ip,'.',2),'0')
end)::integer as outs,

(
27*p_so/
(
3*split_part(p_ip,'.',1)::integer+
(
case when coalesce(split_part(p_ip,'.',2),'0')='' then '0'
     else coalesce(split_part(p_ip,'.',2),'0')
end)::integer
)*sqrt(sf.schedule_offensive)

)::numeric(4,2) as adj_so9,

(
27*p_bb/
(
3*split_part(p_ip,'.',1)::integer+
(
case when coalesce(split_part(p_ip,'.',2),'0')='' then '0'
     else coalesce(split_part(p_ip,'.',2),'0')
end)::integer
)/sqrt(sf.schedule_offensive)
)::numeric(4,2) as adj_bb9,


(3*
27*p_so/
(
3*split_part(p_ip,'.',1)::integer+
(
case when coalesce(split_part(p_ip,'.',2),'0')='' then '0'
     else coalesce(split_part(p_ip,'.',2),'0')
end)::integer
)*sqrt(sf.schedule_offensive)

-

(
10*
27*p_bb/
(
3*split_part(p_ip,'.',1)::integer+
(
case when coalesce(split_part(p_ip,'.',2),'0')='' then '0'
     else coalesce(split_part(p_ip,'.',2),'0')
end)::integer
)/sqrt(sf.schedule_offensive)
)
)::numeric(4,2) as index


--sd.year,
--sd.school_id,
--sd.school_name as school,
--sd.div_id as division,

--year_factor::numeric(4,3) as year_factor,

--park::numeric(4,3) as park_factor,

--(sf.offensive*h.exp_factor)::numeric(4,3) as offensive,

--(sf.defensive*p.exp_factor)::numeric(4,3) as defensive,

--(sf.strength*h.exp_factor/p.exp_factor)::numeric(4,3) as strength,

--park_offensive::numeric(4,3),
--park_defensive::numeric(4,3),
--schedule_park::numeric(4,3),
--schedule_offensive::numeric(4,3),
--schedule_defensive::numeric(4,3),
--schedule_strength::numeric(4,3),
--schedule_field::numeric(4,3),
--schedule_park_offensive::numeric(4,3),
--schedule_park_defensive::numeric(4,3),
--schedule_field_park_offensive::numeric(4,3),
--schedule_field_park_defensive::numeric(4,3)

from ncaa.player_statistics ps
join ncaa._schedule_factors sf
  on (sf.school_id,sf.year)=(ps.team_id,ps.year)
join ncaa.schools_divisions sd
  on (sd.school_id,sd.year)=(sf.school_id,sf.year)

join ncaa._factors h
  on (h.parameter,h.level::integer)=('h_div',sd.div_id)

join ncaa._factors p
  on (p.parameter,p.level::integer)=('p_div',sd.div_id)

where sf.year=2013
and ps.class_year='Jr'

and p_ip is not null
and not(p_ip='')

and
3*split_part(p_ip,'.',1)::integer+
(
case when coalesce(split_part(p_ip,'.',2),'0')='' then '0'
     else coalesce(split_part(p_ip,'.',2),'0')
end)::integer >= 250

and sd.div_id=1
and ps.p_games_started >= 10

order by index desc

limit 20;
