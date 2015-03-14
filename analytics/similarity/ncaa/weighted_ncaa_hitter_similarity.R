library(RPostgreSQL)
library(plyr)

library(WMDB)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,dbname="baseball")

query <- dbSendQuery(con, "
select
h.player_name as name,
h.player_id::text as player_id,
h.year as year,
coalesce(h.class_year,'*') as class,
coalesce(sf.schedule_strength,1.0)*(h.b_bb::float/m.b_bb::float)/((h.b_ab+h.b_bb)::float/(m.b_ab+m.b_bb)::float) as bb_rate,
(1/coalesce(sf.schedule_strength,1.0))*(h.b_so::float/m.b_so::float)/((h.b_ab+h.b_bb)::float/(m.b_ab+m.b_bb)::float) as so_rate,
coalesce(sf.schedule_strength,1.0)*(1/coalesce(sf.schedule_defensive,1.0))*((h.b_hits-h.b_hr)::float/(m.b_hits-m.b_hr)::float)/((h.b_ab-h.b_so-h.b_hr)::float/(m.b_ab-m.b_so-m.b_hr)::float) as aip,
coalesce(sf.schedule_strength,1.0)*(1/coalesce(sf.schedule_defensive,1.0))*((h.b_hits+h.b_doubles+2*coalesce(h.b_triples,0)+3*h.b_hr)::float/(m.b_hits+m.b_doubles+2*m.b_triples+3*m.b_hr)::float)/((h.b_ab)::float/(m.b_ab)::float) as iso
from ncaa.player_statistics h
left outer join ncaa._schedule_factors sf
  on (sf.school_id,sf.year)=(h.team_id,h.year)
join ncaa.schools_divisions td
  on (td.school_id,td.year)=(sf.school_id,sf.year)
join ncaa._year_totals m
  on (m.year)=(h.year)
where
    h.year between 2002 and 2014
and td.division='I'
and (h.class_year ilike ('%jr%') or h.class_year is null)
and ((h.b_ab+h.b_bb) >= 200 or (h.b_ab+h.b_bb >=100 and h.year=2014))
and h.b_ab>0
and (h.b_ab+h.b_bb)>0
and (h.b_ab-h.b_so-h.b_hr)>0
and (h.b_ab-h.b_so)>0
;")

all <- fetch(query,n=-1)
players <- subset(all, year==2014)
statistics <- as.matrix(data.frame(all$bb_rate, all$so_rate, all$aip, all$iso))
vars <- var(statistics)

vars

f <- function(p, a, v, n) {

  player <- subset(a, player_id==p$player_id & year==p$year)
  if (nrow(player)==0) {return(NULL)};

  c <- as.matrix(data.frame(player$bb_rate,player$so_rate,player$aip,player$iso))

  m <- as.matrix(data.frame(a$bb_rate,a$so_rate,a$aip,a$iso))

#  d <- mahalanobis(m,c,v)
  weight <- diag(c(2.0,1.0,0.8,1.0))
  d <- wmahalanobis(m, c, v, weight)

  s <- data.frame(player_id=p$player_id,year=p$year,type="hitter",comp_name=a$name,comp_id=a$player_id,comp_year=a$year,comp_class=a$class,d)
  return(data.frame(s[with(s, order(--d)), ][1:n,],rank=0:(n-1)))
  #return(p)
}

# n = 1 + #{non-self comps}

comps <- adply(players, 1, f, a=all, v=vars, n=21)

dbWriteTable(con,c("ncaa","_weighted_hitter_similarity"),as.data.frame(comps),row.names=TRUE)

q("no")
