begin;

create temporary table years (
       first_year      integer,
       last_year       integer
);

insert into years
(first_year,last_year)
values
(2002,2014);

drop table if exists ncaa._factors_logistic;

create table ncaa._factors_logistic (
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

--truncate ncaa._factors;

-- this can/should be rewritten agnostically
-- do random/fixed separately
-- test for the prescence of '/' using like

-- Random factors

-- defense,offense

insert into ncaa._factors_logistic
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
from ncaa._parameter_levels_logistic npl
left outer join ncaa._basic_factors_logistic nbf
  on (nbf.factor,nbf.level,nbf.type)=(npl.parameter,npl.level,npl.type)
where
    npl.type='random'
and npl.parameter in ('defense','offense')
);

-- other random

insert into ncaa._factors_logistic
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
from ncaa._parameter_levels_logistic npl
left outer join ncaa._basic_factors_logistic nbf
  on (nbf.factor,nbf.level,nbf.type)=(npl.parameter,npl.level,npl.type)
where
    npl.type='random'
and npl.parameter not in ('defense','offense')
);

-- Fixed factors

-- year

/*
insert into ncaa._factors_logistic
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
from ncaa._parameter_levels_logistic npl
left outer join ncaa._basic_factors_logistic nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter in ('year')
);
*/

-- field

insert into ncaa._factors_logistic
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
from ncaa._parameter_levels_logistic npl
left outer join ncaa._basic_factors_logistic nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter in ('field')
and npl.level not in ('none')
);

-- other fixed

insert into ncaa._factors_logistic
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
from ncaa._parameter_levels_logistic npl
left outer join ncaa._basic_factors_logistic nbf
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
from ncaa._factors_logistic
where parameter not in ('h_div','p_div')
group by parameter
);

update ncaa._factors_logistic
set raw_factor=raw_factor-s.mean
from scale s
where s.parameter=_factors_logistic.parameter;

update ncaa._factors_logistic
set exp_factor=exp(raw_factor);

-- 'neutral' park confounded with 'none' field; set factor = 1.0 for field 'none'

insert into ncaa._factors_logistic
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
values
('field','none','fixed','log_regression',null,null,null,0.0,1.0);

commit;
