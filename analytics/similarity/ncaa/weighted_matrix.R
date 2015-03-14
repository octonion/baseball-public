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

(h.b_bb::float)/((h.b_ab+h.b_bb)::float)/(sqrt(sf.schedule_defensive)) as bb_rate,

(h.b_so::float)/((h.b_ab+h.b_bb)::float)*(sqrt(sf.schedule_defensive)) as so_rate,

((h.b_hits-h.b_hr)::float)/((h.b_ab-h.b_so-h.b_hr)::float)/(sqrt(sf.year_factor*sf.schedule_park_defensive)) as aip,
 
(h.b_hits+h.b_doubles+2*coalesce(h.b_triples,0)+3*h.b_hr)::float/(h.b_ab::float)/(sqrt(sf.year_factor*sf.schedule_park_defensive)) as iso

from ncaa.player_statistics h
left outer join ncaa._schedule_factors sf
  on (sf.school_id,sf.year)=(h.team_id,h.year)
join ncaa.schools_divisions td
  on (td.school_id,td.year)=(sf.school_id,sf.year)
where
    h.year between 2002 and 2014
and td.division='I'
and (h.class_year ilike ('%jr%') or h.class_year is null)
and ((h.b_ab+h.b_bb) >= 200 or (h.b_ab+h.b_bb >=200 and h.year=2014))
and h.b_ab>0
and (h.b_ab+h.b_bb)>0
and (h.b_ab-h.b_so-h.b_hr)>0
and (h.b_ab-h.b_so)>0
;")

all <- fetch(query,n=-1)
players <- subset(all, year==2014)

statistics <- as.matrix(data.frame(all$bb_rate, all$so_rate, all$aip, all$iso))
pstats <- as.matrix(data.frame(players$bb_rate, players$so_rate, players$aip, players$iso))

vars <- var(statistics)
center <- colMeans(statistics)

vars
center

weight <- diag(c(2.0,1.0,0.8,1.0))
apply(pstats, 1, function(x) wmahalanobis(statistics, x, vars, weight))
