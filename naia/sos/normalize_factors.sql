begin;

create temporary table years (
       first_year      integer,
       last_year       integer
);

insert into years
(first_year,last_year)
(select min(level::integer),max(level::integer)
from naia._parameter_levels
where parameter='year'
);

--drop table naia._factors;

create table naia._factors (
       parameter		text,
       level			text,
       type			text,
       method			text,
       year			integer,
       first_year		integer,
       last_year		integer,
       raw_factor		float,
       exp_factor		float,
       factor			float
--       primary key (team_name,type,method,year,first_year,last_year)
);

--truncate naia._factors;

-- this can/should be rewritten agnostically
-- do random/fixed separately
-- test for the prescence of '/' using like

-- Random factors

-- defense,offense

insert into naia._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
split_part(npl.level,'/',2) as level,
npl.type as type,
'log_regression' as method,
split_part(npl.level,'/',1)::integer as year,
split_part(npl.level,'/',1)::integer as first_year,
split_part(npl.level,'/',1)::integer as last_year,
estimate as raw_factor,
null as exp_factor
--exp(estimate) as exp_factor
from naia._parameter_levels npl
left outer join naia._basic_factors nbf
  on (nbf.factor,nbf.level,nbf.type)=(npl.parameter,npl.level,npl.type)
where
    npl.type='random'
and npl.parameter in ('defense','offense')
);

-- other random

insert into naia._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
estimate as raw_factor,
null as exp_factor
--exp(estimate) as exp_factor
from naia._parameter_levels npl
left outer join naia._basic_factors nbf
  on (nbf.factor,nbf.level,nbf.type)=(npl.parameter,npl.level,npl.type)
where
    npl.type='random'
and npl.parameter not in ('defense','offense')
);

-- Fixed factors

-- year

insert into naia._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
npl.level::integer as year,
npl.level::integer as first_year,
npl.level::integer as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
--coalesce(exp(estimate),1.0) as exp_factor
from naia._parameter_levels npl
left outer join naia._basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter in ('year')
);

-- field

insert into naia._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
--coalesce(exp(estimate),1.0) as exp_factor
from naia._parameter_levels npl
left outer join naia._basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter in ('field')
and npl.level not in ('none')
);

-- other fixed

insert into naia._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
--coalesce(exp(estimate),1.0) as exp_factor
from naia._parameter_levels npl
left outer join naia._basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter not in ('field','year')
);

create temporary table scale (
       parameter		text,
       mean			float,
       primary key (parameter)
);

insert into scale
(parameter,mean)
(select
parameter,
avg(raw_factor)
from naia._factors
group by parameter
);

update naia._factors
set raw_factor=raw_factor-s.mean
from scale s
where s.parameter=_factors.parameter;

update naia._factors
set exp_factor=exp(raw_factor);

-- 'neutral' park confounded with 'none' field; set factor = 1.0 for field 'none'

insert into naia._factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
values
('field','none','fixed','log_regression',null,null,null,0.0,1.0);

commit;

/*

update naia.factors
set raw_factor=0.0::float,
    exp_factor=1.0::float
where raw_factor is null;

-- null park

insert into naia.factors
(team_name,factor_type,split_type,method,year,first_year,last_year,
 raw_factor,exp_factor)
(select
 g.team_name as team_name,
 g.factor_type as factor_type,
 g.split_type as split_type,
 'log_regression'::text as method,
 g.year as year,
 2007 as first_year,
 2011 as last_year,
 0.00::float as raw_factor,
 1.00::float as exp_factor
 from naia.game_totals g
 left join naia.factors n
   on (g.team_name,g.factor_type,g.split_type,g.year) =
      (n.team_name,n.factor_type,n.split_type,n.year)
 where
     g.factor_type = 'park'
 and g.year = 2007
 and n.raw_factor is null);

-- park years

create temporary table park_years (
       team_name       		  text,
       year			  integer,
primary key (team_name,year)
);

insert into park_years
(team_name,year)
(select
 g.team_name as team_name,
 g.year as year
 from naia.game_totals g
 where
    (g.factor_type,g.split_type)=('park','all')
 and g.games > 0);

insert into naia.factors
(team_name,factor_type,split_type,method,year,first_year,last_year,
 raw_factor,exp_factor)
(select
 n.team_name as team_name,
 n.factor_type as factor_type,
 n.split_type as split_type,
 n.method as method,
 py.year as year,
 n.first_year as first_year,
 n.last_year as last_year,
 n.raw_factor as raw_factor,
 n.exp_factor as exp_factor
 from naia.factors n
 left join park_years py
   on (py.team_name)=(n.team_name)
 where
     (n.factor_type,n.split_type,n.method)=('park','all','log_regression')
 and not(n.year=py.year));

delete from naia.factors
where
    (factor_type,split_type,method)=('park','all','log_regression')
and (team_name,year) not in
(select g.team_name,g.year
 from naia.game_totals g
 where
     (g.factor_type,g.split_type)=('park','all')
 and g.games > 0);

-- null other

insert into naia.factors
(team_name,factor_type,split_type,method,year,first_year,last_year,
 raw_factor,exp_factor)
(select
 g.team_name as team_name,
 g.factor_type as factor_type,
 g.split_type as split_type,
 'log_regression'::text as method,
 g.year as year,
 g.year as first_year,
 g.year as last_year,
 0.00::float as raw_factor,
 1.00::float as exp_factor
 from naia.game_totals g
 left join naia.factors n
   on (g.team_name,g.factor_type,g.split_type,g.year) =
      (n.team_name,n.factor_type,n.split_type,n.year)
 where
     n.raw_factor is null
 and g.games > 0);

/*
select avg(exp_factor)
from naia.factors
where factor_type='park';

select avg(exp_factor)
from naia.factors
where factor_type='park'
and team_name='neutral';
*/

update naia.factors
set factor=factors.exp_factor/
(select exp(avg(raw_factor))
 from naia.factors n
 where
 (factors.factor_type,factors.method,
  factors.first_year,factors.last_year)=
 (n.factor_type,n.method,n.first_year,n.last_year));

update naia.factors
set factor=(select
  regr_slope(exp(g.log_rs)-1,o.factor*d.factor*p.factor)
  from public.game_results g
  join naia.factors o on
    (o.team_name,o.factor_type,o.split_type,o.method,o.year)=
    (g.team,'offense','all',factors.method,g.year)
  join naia.factors d on
    (d.team_name,d.factor_type,d.split_type,d.method,d.year)=
    (g.team,'defense','all',factors.method,g.year)
  join naia.factors p on
    (p.team_name,p.factor_type,p.split_type,p.method,p.year)=
    (g.team,'park','all',factors.method,g.year)
  where
      (g.year)=(factors.year)
 )
 where (team_name,factor_type,split_type,method)=
       ('all','year','all','log_regression');

commit;
*/
