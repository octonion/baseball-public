sink("pick_value.txt")

library(plyr)

picks <- read.csv("../bbref/csv/draft_picks.csv",header=TRUE,sep=",")

dim(picks)

picks$war[picks$war < 0.0] <- 0.0
picks$war[is.na(picks$war)] <- 0.0

picks <- subset(picks, year >= 1970 & year <= 2007 & overall_pick <= 100 & war >= 0.0)

picks <- ddply(picks, .(overall_pick),summarise, war=mean(war))

picks
               
picks$log_war <- log(picks$war)
picks$log_pick <- log(picks$overall_pick)

model <- log_war ~ log_pick

value <- lm(model,data=picks)

coef(value)
AIC(value)
deviance(value)
summary(value)
value

plot(value)

quit("no")
