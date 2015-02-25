begin;

create temporary table t (
       team_id	 integer,
       team_name text,
       year	 integer
);

insert into t
(team_id,team_name,year)
(
select distinct team_id,team_name,year
from naia.results
);

select t1.team_id,t1.team_name,t2.team_name,count(*)
from t t1
join t t2
  on (t2.team_id,t2.year)=(t1.team_id,t1.year)
where
  not(t1.team_name=t2.team_name)
group by t1.team_id,t1.team_name,t2.team_name
order by t1.team_id,t1.team_name,t2.team_name;

commit;
