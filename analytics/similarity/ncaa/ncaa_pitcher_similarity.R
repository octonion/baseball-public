library(RPostgreSQL)
library(plyr)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,dbname="baseball")

query <- dbSendQuery(con, "
select
h.player_name as name,
h.player_id::text as player_id,
h.year as year,
coalesce(h.class_year,'*') as class,

(coalesce(h.p_bb,0)::float)/(sqrt(sf.schedule_offensive)) as bb_rate,

(coalesce(h.p_so,0)::float)*(sqrt(sf.schedule_offensive)) as so_rate,

coalesce((3*split_part(p_ip,'.',1)::integer+(case when split_part(p_ip,'.',2)='' then 0 else split_part(p_ip,'.',2)::integer end))::float,0) as ip,

(coalesce(h.p_hits,0)::float/(sqrt(sf.year_factor*sf.schedule_park_offensive))) as aip
 
--(h.b_hits+h.b_doubles+2*coalesce(h.b_triples,0)+3*h.b_hr)::float/(h.b_ab::float)/(sqrt(sf.year_factor*sf.schedule_park_defensive)) as iso

from ncaa.player_statistics h
join ncaa._schedule_factors sf
  on (sf.school_id,sf.year)=(h.team_id,h.year)
join ncaa.schools_divisions td
  on (td.school_id,td.year)=(sf.school_id,sf.year)
--join ncaa._year_totals m
--  on (m.year)=(h.year)
where
    h.year between 2002 and 2014
--and td.division='I'
and (h.class_year ilike ('%jr%') or h.class_year is null)
and  (3*split_part(p_ip,'.',1)::integer+(case when split_part(p_ip,'.',2)='' then 0 else split_part(p_ip,'.',2)::integer end)) >= 150
and sf.schedule_defensive is not null
and sf.schedule_park_defensive is not null
;")

all <- fetch(query,n=-1)
all$bb_rate <- all$bb_rate/all$ip
all$so_rate <- all$so_rate/all$ip
all$aip <- all$aip/all$ip
players <- all
#players <- subset(all, year==2014)

statistics <- as.matrix(data.frame(all$bb_rate, all$so_rate, all$aip))
vars <- var(statistics)

f <- function(p, a, v, n) {

  player <- subset(a, player_id==p$player_id & year==p$year)
  if (nrow(player)==0) {return(NULL)};

  c <- as.matrix(data.frame(player$bb_rate,player$so_rate,player$aip))

  m <- as.matrix(data.frame(a$bb_rate,a$so_rate,a$aip))

  d <- mahalanobis(m,c,v)
  
  s <- data.frame(player_id=p$player_id,year=p$year,type="pitcher",comp_name=a$name,comp_id=a$player_id,comp_year=a$year,comp_class=a$class,d)
  return(data.frame(s[with(s, order(--d)), ][1:n,],rank=0:(n-1)))
  #return(p)
}

# n = 1 + #{non-self comps}

comps <- adply(players, 1, f, a=all, v=vars, n=21)

dbWriteTable(con,c("ncaa","_hitter_similarity"),as.data.frame(comps),append=TRUE)

q("no")
