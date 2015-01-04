sink("framing_gputools.txt")

library(gputools)

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

model <- cs_p ~ year+field+count+c_id+uhp_id
outcome <- gpuGlm(model,data=pitches,weights=n,family=binomial(link="logit"))

outcome
summary(outcome)
AIC(outcome)

q("no")
