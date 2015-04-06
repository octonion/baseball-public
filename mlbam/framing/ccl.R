# Basic example of using R parallel

# Catcher framing using elliptical contours

# Computes quadrants and L/R separately
# 8 total jobs

library("lme4")
library("parallel")
library("RPostgreSQL")

# Ideally use 8 CPU cores

cores <- min(8,detectCores())

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="baseball")

query <- dbSendQuery(con, "
select
fx.game_pk as game_pk,
fx.sv_pitch_id as sv_pitch_id,
fx.year as year,
fx.pitcher_id as pitcher_id,
pg.uhp_id as umpire_id,
(case when fx.top_inning_sw then 'away'
      else 'home' end) as field,
fx.bat_side as bh,
(case when (fx.plate_x >= 0 
      	    and fx.plate_z-(fx.sz_top+fx.sz_bottom)/2 >= 0)
      then 'upper_right'
      when (fx.plate_x >= 0 
      	    and fx.plate_z-(fx.sz_top+fx.sz_bottom)/2 <= 0)
      then 'upper_left'
      when (fx.plate_x <= 0 
      	    and fx.plate_z-(fx.sz_top+fx.sz_bottom)/2 >= 0)
      then 'lower_right'
      when (fx.plate_x <= 0 
      	    and fx.plate_z-(fx.sz_top+fx.sz_bottom)/2 <= 0)
      then 'lower_left' end) as quadrant,
fx.pre_balls::text||'-'||fx.pre_strikes::text as count,
abs(fx.plate_x) as x,
abs(fx.plate_z-(fx.sz_top+fx.sz_bottom)/2) as z,
(case when fx.event_type in ('called_strike') then 1
      when fx.event_type in ('ball') then 0
      else NULL end) as outcome
from mlbam.pitchfx fx
join mlbam.pre_game pg
  on (pg.game_pk)=(fx.game_pk)
where
    extract(year from pg.gdate) between 2010 and 2014

-- Regular season games

and pg.game_type='R'

-- MLB games only

and pg.sport_code='mlb'

-- make sure balls/strikes are defined and in range

and fx.pre_balls is not null
and fx.pre_strikes is not null
and fx.pre_balls <= 3
and fx.pre_strikes <= 2

and fx.bat_side is not null
and fx.sz_top is not null
and fx.sz_bottom is not null
and fx.plate_x is not null
and fx.plate_z is not null

;")

pitches <- fetch(query,n=-1)

pitches$count <- as.factor(pitches$count)
pitches$field <- as.factor(pitches$field)

pitches$year <- as.factor(pitches$year)
pitches$pitcher_id <- as.factor(pitches$pitcher_id)
pitches$umpire_id <- as.factor(pitches$umpire_id)

dim(pitches)

factors <- unique(data.frame(pitches$bh,pitches$quadrant))
factors

split <- split(pitches,data.frame(pitches$bh,pitches$quadrant))

# Basic model

model <- outcome ~ year + poly(x,2) + poly(z,2) + I(x*z) + field + count + (1|umpire_id) + (1|pitcher_id)

l_fit <- function(pitch) {

      train <- subset(pitch,outcome==0 | outcome==1)

      fit <- lmer(model,train,family=binomial(link="logit"))

      out <- data.frame(p_strike=predict(fit,newdata=pitch,type="response"))

      out$game_pk <- pitch$game_pk
      out$sv_pitch_id <- pitch$sv_pitch_id

      out
}

results <- mclapply(split,l_fit,mc.cores=cores)

combined <- as.data.frame(do.call("rbind",results))

dbWriteTable(con,c("mlbam","_called"),combined,row.names=TRUE)

q("no")
