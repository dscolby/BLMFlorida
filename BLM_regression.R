# Author: Darren Colby
# Date: 11/5/2020
# Purpose: To normalize the raw scores for racial homogeneity in Florida census tracts

# Specifies where to find the file
setwd("C:/Users/dscol/OneDrive - Dartmouth College/Completed Assignments/GEOG 9.01/Final Project")

library(readr)
library(stargazer)

protests <- read.csv("regression_inputs.csv")

summary(protests)

# Rename the columns so there is no confusion
colnames(protests)[4] <- "schools"
colnames(protests)[11] <- "protests"

# Looking (imprecisely) at the distributions
hist(protests$schools)
hist(protests$partyRatio,
     density = TRUE)

# Make the party rations look more like a normal distribution
protests$sqrtPartyRatio <- sqrt(protests$partyRatio)

hist(protests$sqrtPartyRatio,  # This looks a little better
     density = TRUE,
     breaks = 100)

hist(protests$HHmedIncom,  # Really thin tail on the right, but not too terrible
     density = TRUE,
     breaks = 100)

hist(protests$normScore,  # That looks crazy
     density = TRUE,
     breaks = 100)

protests$racialScoreSq <- (protests$normScore)^2

hist(protests$racialScoreSq,  # As good as we are going to get with a simple transformation
     density = TRUE,
     breaks = 100)

# Create dummy variables for schools and protests
protests$protestDummy <- as.factor(ifelse(protests$protests != 0, "1", "0"))
protests$schoolsDummy <- as.factor(ifelse(protests$schools != 0, "1", "0"))

# Logit models
l1 <- glm(protestDummy ~ schools, family = binomial(link = "logit"), data = protests)
l2 <- glm(protestDummy ~ schoolsDummy, family = binomial(link = "logit"), data = protests)
l3 <- glm(protestDummy ~ schools + sqrtPartyRatio, family = binomial(link = "logit"), data = protests)
l4 <- glm(protestDummy ~ schools + sqrtPartyRatio + HHmedIncom, family = binomial(link = "logit"), 
          data = protests)
l5 <- glm(protestDummy ~ schools + sqrtPartyRatio + HHmedIncom + racialScoreSq, 
          family = binomial(link = "logit"), 
          data = protests)
l6 <- glm(protestDummy ~ schoolsDummy + sqrtPartyRatio + HHmedIncom + racialScoreSq, 
          family = binomial(link = "logit"), 
          data = protests)
l7 <- glm(protestDummy ~ schoolsDummy + sqrtPartyRatio + HHmedIncom + (HHmedIncom * schoolsDummy)
          + racialScoreSq, 
          family = binomial(link = "logit"), 
          data = protests)

# Poisson models
p1 <- glm(protests ~ schools, family = poisson(link = "log"), data = protests)
p2 <- glm(protests ~ schoolsDummy, family = poisson(link = "log"), data = protests)
p3 <- glm(protests ~ schools + partyRatio, family = poisson(link = "log"), data = protests)
p4 <- glm(protests ~ schools + partyRatio + HHmedIncom, family = poisson(link = "log"), 
          data = protests)
p5 <- glm(protests ~ schools + partyRatio + HHmedIncom + normScore, family = poisson(link = "log"), 
          data = protests)
p6 <- glm(protests ~ schoolsDummy + partyRatio + HHmedIncom + normScore, family = poisson(link = "log"), 
          data = protests)
p7 <- glm(protests ~ schoolsDummy + partyRatio + HHmedIncom +  (HHmedIncom * schoolsDummy) + normScore, 
          family = poisson(link = "log"), 
          data = protests)

# Make regression tables
stargazer(l1, l2, l3, l4, l5, l6, l7,
          title = "Probability of a BLM Protest Occuring",
          style = "ajps",
          dep.var.labels = "Protest Occurence",
          covariate.labels = c("Schools", "Schools Dummy", "GOP to Dem Ratio",
                               "Median Household Income", 
                               "Racial Homogeneity", 
                               "Schools Dummy:Median Household Income"),
          type = "html")
stargazer(p1, p2, p3, p4, p5, p6, p7,
          title = "Predicted Number of BLM Protests",
          style = "ajps",
          dep.var.labels = "Protest Count",
          covariate.labels = c("Schools", "Schools Dummy", "GOP to Dem Ratio",
                               "Median Household Income", 
                               "Racial Homogeneity", 
                               "Schools Dummy:Median Household Income"),
          type = "html")

# Add columns for residuals and predicted values
protests$logit_pred <- l6$fitted.values
protests$poisson_pred <- p6$fitted.values
protests$logit <- l6$residuals
protests$poisson <- p6$residuals

write.csv(protests, file = 'regression_output.csv')
