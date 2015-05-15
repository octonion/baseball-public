sink("framing_lmer.txt")

library(lme4)

pitches <- read.csv("batteries.csv",head=TRUE)

dim(pitches)

#pitches$year <- as.factor(pitches$year)
#pitches$field <- as.factor(pitches$field)
pitches$count <- as.factor(pitches$count)
#pitches$uhp_id <- as.factor(pitches$uhp_id )
pitches$catcher_id <- as.factor(pitches$catcher_id)
#pitches$b_id <- as.factor(pitches$b_id)
pitches$pitcher_id <- as.factor(pitches$pitcher_id)

head(pitches)

model <- cbind(called_strikes,balls) ~ (1|catcher_id) + (1|pitcher_id)
outcome <- glmer(model, data=pitches, family=binomial(link="logit"), verbose=T)

outcome
summary(outcome)
AIC(outcome)

fixef(outcome)
ranef(outcome)
(ranef(outcome)$catcher_id)[,1]
rownames(ranef(outcome)$catcher_id)

framing <- data.frame(catcher_id=rownames(ranef(outcome)$catcher_id),framing=ranef(outcome)$catcher_id[,1])
framing

q("no")
