sink("framing_lmer.txt")

library(lme4)
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, host="localhost", port="5432", dbname="baseball")

query <- dbSendQuery(con, "
select

extract(year from g.game_dt::text::date) as year,

(case when e.bat_team_id=e.away_team_id then 'home'
      else 'away' end) as field,

'count-'||p.balls::text||'/'||p.strikes::text as count,

--e.pit_id as p_id,
--e.bat_id as b_id,

e.pos2_fld_id as c_id,
g.base4_ump_id as uhp_id,

sum(case when p.outcome='C' then 1 else 0 end) as cs,
sum(case when p.outcome='B' then 1 else 0 end) as b,
sum(case when p.outcome='C' then 1 else 0 end)::float/count(*)::float as cs_p,

count(*) as n
from retrosheet.games g
join retrosheet.events e
  on (e.game_id)=(g.game_id)
join retrosheet._pitches p
  on (p.game_id,p.event_id::text)=(e.game_id,e.event_id)

where
    extract(year from g.game_dt::text::date) between 2011 and 2014

and p.outcome in ('B','C')

and p.balls between 0 and 3
and p.strikes between 0 and 2

group by year,field,count,c_id,uhp_id --,p_id,b_id
;")

pitches <- fetch(query,n=-1)
dim(pitches)

pitches$year <- as.factor(pitches$year)
pitches$field <- as.factor(pitches$field)
pitches$count <- as.factor(pitches$count)
pitches$uhp_id <- as.factor(pitches$uhp_id )
pitches$c_id <- as.factor(pitches$c_id)
#pitches$b_id <- as.factor(pitches$b_id)
#pitches$p_id <- as.factor(pitches$p_id)

# Base model does not include umpires

model0 <- cs_p ~ field + count + (1|c_id)
outcome0 <- glmer(model0,data=pitches,weights=n,family=binomial(link="logit"),verbose=T)

# Include umpires

model1 <- cs_p ~ field + count + (1|c_id) + (1|uhp_id)
outcome1 <- glmer(model1,data=pitches,weights=n,family=binomial(link="logit"),verbose=T)

# Do umpires impacts ball/called strike decisions?

anova(outcome0,outcome1)

outcome1
summary(outcome1)
AIC(outcome1)

fixef(outcome1)
ranef(outcome1)
(ranef(outcome1)$c_id)[,1]
rownames(ranef(outcome1)$c_id)

framing <- data.frame(c_id=rownames(ranef(outcome1)$c_id),framing=ranef(outcome1)$c_id[,1])
framing

q("no")
