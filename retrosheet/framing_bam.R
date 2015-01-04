sink("framing_bam.txt")

library(mgcv)

#source("read_postgresql.R")
source("read_csv.R")

dim(pitches)

pitches$year <- as.factor(pitches$year)
pitches$field <- as.factor(pitches$field)
pitches$count <- as.factor(pitches$count)
pitches$uhp_id <- as.factor(pitches$uhp_id )
pitches$c_id <- as.factor(pitches$c_id)
#pitches$p_id <- as.factor(pitches$p_id)
#pitches$b_id <- as.factor(pitches$b_id)

# Base model does not include umpires

model0 <- cs_p ~ year + field + count + s(c_id,bs="re")
outcome0 <- bam(model0,data=pitches,weights=n,family=binomial(link="logit"))

# Include umpires

model1 <- cs_p ~ year + field + count + s(c_id,bs="re") + s(uhp_id,bs="re")

outcome1 <- bam(model1,data=pitches,weights=n,family=binomial(link="logit"))

# Do umpires impacts ball/called strike decisions?

anova(outcome0,outcome1)

outcome1
summary(outcome1)
AIC(outcome1)

coef(outcome1)

q("no")
