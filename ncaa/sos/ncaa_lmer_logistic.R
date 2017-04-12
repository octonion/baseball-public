sink("diagnostics/ncaa_lmer_logistic.txt")

library("lme4")
library("RPostgreSQL")

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="baseball")

query <- dbSendQuery(con, "
select
r.game_id,
r.year,
r.park_id as park,
r.field as field,
r.school_id as school,
r.school_div_id as h_div,
r.opponent_id as opponent,
r.opponent_div_id as p_div,
(case when r.school_score > r.opponent_score then 1
      when r.school_score < r.opponent_score then 0
      else 0.5 end) as outcome
from ncaa.results r
where
    r.year between 2002 and 2017
and r.school_div_id is not null
and r.opponent_div_id is not null
and r.school_score>=0
and r.opponent_score>=0
and not(r.school_score,r.opponent_score)=(0,0)
;")

games <- fetch(query,n=-1)
dim(games)

attach(games)

pll <- list()

# Fixed parameters

year <- as.factor(year)
field <- as.factor(field)
p_div <- as.factor(p_div)
h_div <- as.factor(h_div)

fp <- data.frame(field,p_div,h_div)
fpn <- names(fp)

# Random parameters

offense <- as.factor(paste(year,"/",school,sep=""))
defense <- as.factor(paste(year,"/",opponent,sep=""))

rp <- data.frame(offense,defense)
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
dbWriteTable(con,c("ncaa","_parameter_levels_logistic"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)

g$outcome <- outcome

dim(g)

model0 <- outcome ~ year+field+p_div+h_div+(1|offense)+(1|defense)
fit0 <- glmer(model0, data=g, family=binomial(link=logit), REML=FALSE, verbose=TRUE)

model <- outcome ~ year+field+p_div+h_div+(1|offense)+(1|defense)+(1|game_id)
fit <- glmer(model, data=g, family=binomial(link=logit), REML=FALSE, verbose=TRUE)

fit
summary(fit)
anova(fit0)
anova(fit)
anova(fit0,fit)

# List of data frames

# Fixed factors

f <- fixef(fit)
fn <- names(f)

# Random factors

r <- ranef(fit)
rn <- names(r) 

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

dbWriteTable(con,c("ncaa","_basic_factors_logistic"),as.data.frame(combined),row.names=TRUE)

quit("no")
