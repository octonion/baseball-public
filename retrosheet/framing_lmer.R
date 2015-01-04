sink("framing_lmer.txt")

library(lme4)

#source("read_postgresql.R")
source("read_csv.R")

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
