sink("diagnostics/njcaa_lmer.txt")

library(lme4)
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, host="localhost", port="5432", dbname="baseball")

query <- dbSendQuery(con, "
select
r.year,
r.park_id as park,
r.field as field,
r.team_id as team,
r.team_div as h_div,
r.opponent_id as opponent,
r.opponent_div as p_div,
ln(r.team_score::float+1.0) as log_rs
from njcaa.results r
where
    r.year between 2002 and 2012
and r.team_score>=0
and r.opponent_score>=0
and not(r.team_score,r.opponent_score)=(0,0)
;")

games <- fetch(query,n=-1)
dim(games)

attach(games)

# Constrast options

#options(contrasts=c(factor="contr.sum",ordered="contr.poly"))
#options(contrasts=c(unordered="contr.sum", ordered="contr.poly"))

#dow <- as.factor(dow)
#day <- as.factor(day)

pll <- list()

# Fixed parameters

year <- as.factor(year)
field <- as.factor(field)
h_div <- as.factor(h_div)
p_div <- as.factor(p_div)

fp <- data.frame(year,field,h_div,p_div)
fpn <- names(fp)

# Random parameters

park <- as.factor(park)
offense <- as.factor(paste(year,"/",team,sep=""))
defense <- as.factor(paste(year,"/",opponent,sep=""))

rp <- data.frame(park,offense,defense)
rpn <- names(rp)

for (n in fpn) {
  df <- fp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("fixed",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

for (n in rpn) {
  df <- rp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("random",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

# Model parameters

parameter_levels <- as.data.frame(do.call("rbind",pll))
dbWriteTable(con,c("njcaa","_parameter_levels"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)

g$log_rs <- log_rs

dim(g)

model <- log_rs ~ year+field+h_div+p_div+(1|park)+(1|offense)+(1|defense)

fit <- lmer(model, data=g, REML=FALSE, verbose=TRUE)
fit
summary(fit)
anova(fit)

# List of data frames

# Fixed factors

f <- fixef(fit)
fn <- names(f)
#fn <- names(sapply(f,names))

# Random factors

r <- ranef(fit)
rn <- names(r) 
#rn <- names(sapply(r,names)) 

results <- list()

for (n in fn) {

  df <- f[[n]]

  factor <- n
  level <- n
  type <- "fixed"
  estimate <- df

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

for (n in rn) {

  df <- r[[n]]

  factor <- rep(n,nrow(df))
  type <- rep("random",nrow(df))
  level <- row.names(df)
  estimate <- df[,1]

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

combined <- as.data.frame(do.call("rbind",results))

dbWriteTable(con,c("njcaa","_basic_factors"),as.data.frame(combined),row.names=TRUE)

quit("no")
