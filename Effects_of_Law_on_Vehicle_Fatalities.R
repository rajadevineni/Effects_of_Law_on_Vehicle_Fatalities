# Created by Rajasekhar Devineni.
# set your own environment directory.
setwd("~/Desktop/Projects/Econometrics")
library(ggplot2)
library(data.table)
library(DBI)
library(tidyverse)
library(broom)
library(tidyr)
library(sandwich)
library(lmtest)
library(plm)
library(foreign)
library(GGally)
library("cowplot")


#This function is used to remove heteroskidasticity and 
#give White coefficients with robust standard errors.
############################ TIDY White function ####################################
tidy.g <- function(model,vc=vcov(model),conf.int=FALSE,conf.level=0.95){
  dt <- tidy(model,conf.int=conf.int,conf.level=conf.level)
  dt$std.error <- sqrt(diag(vc))
  dt$statistic <- dt$estimate/dt$std.error
  dt$p.value <- 2*pnorm(-abs(dt$statistic))
  if(conf.int){
    dt$conf.low <- dt$estimate+qnorm((1-conf.level)/2)*dt$std.error
    dt$conf.high <- dt$estimate-qnorm((1-conf.level)/2)*dt$std.error
  }
  return(dt)
}
tidy.w <- function(model,...)tidy.g(model,vc=sandwich::vcovHC(model),...)

###################################################################################




# Extractting data from .dta file
total_data <- read.dta("car_fatalities.dta")

#looking at the data 
view(total_data)

# converting the data table into dataframe and assigninig State and Year as idexes.
total_data_frame <- pdata.frame(total_data,index=c('state','year'))

#cor(total_data_frame)
#checking weather all the states have 7 years of data or not. 48 states have data from 1982-1988
state <- unique(total_data$state)
NROW(total_data)/7

# creating a dataframe with mean of the State's unemployement rate (%) from 1982-1988
UNR_state <- aggregate(total_data$unrate, by=list(total_data$state), mean)
UNR_state_frame <- data.frame(State=c(UNR_state[1]), UNR = c(UNR_state[2]))
names(UNR_state_frame) <- c("State", "UNR")

# Top 6 states with highest average State Unemployement rate.
UNR_state_frame <- UNR_state_frame[order(UNR_state_frame$UNR, decreasing = T),]
head(UNR_state_frame)

# Top 6 states with highest Avg. Mortality rate.
MRALL_STATE <- aggregate(total_data$mrall, by=list(total_data$state), FUN = mean)
names(MRALL_STATE) <- c("State", "Mortality_rate")
MRLL_6 <- head(MRALL_STATE[order(MRALL_STATE$Mortality_rate, decreasing = T),])
head(MRLL_6)

# Top 6 states with highest Avg. Mortality. This may be dues to high population in the respective states.
ALLMORT_STATE <- aggregate(total_data$allmort, by=list(total_data$state), FUN = mean)
names(ALLMORT_STATE) <- c("State", "Mortality")
ALLMORT_6 <- head(ALLMORT_STATE[order(ALLMORT_STATE$Mortality, decreasing = T),])                                  
ALLMORT_6

cor(total_data_frame$pop, total_data_frame$allmort)

# Top 6 states with highest Avg. Per Capita Pure Alcohol Consumption (Annual, Gallons)
alchl_con <- aggregate(total_data_frame$spircons, by=list(total_data$state), FUN = mean)
names(alchl_con) <- c("State", "Spircons")
alchl_con_6 <- head(alchl_con[order(alchl_con$Spircons, decreasing = T),])
alchl_con_6

# Mississippi State is the only state which is in top 6 Vehicle fatality rate and highest Unemployment rate
intersect(head(UNR_state_frame$State), MRLL_6$State)

# 21037 Vehicle fatalities involve 15-17 year olds during 1982-1988
all_a1517 <- sum(total_data_frame$a1517)
# 35838 Vehicle fatalities involve 18-20 year olds during 1982-1988
all_a1820 <- sum(total_data_frame$a1820)
# 42629 Vehicle fatalities involve 21-24 year olds during 1982-1988
all_a2124 <- sum(total_data_frame$a2124)

# 98560 Vehicle fatalities involve alcohol during 1982-1988
total_aidall <- sum(total_data_frame$aidall)

label_percent()(all_a1517/total_aidall)





# considering all the data irrspective of states, the below OLS models provide high R-squared values
# which implies that the variance of the whole dataset is being explained by the below models 
# model_ols_2 is the best model having the least AIC and BIC values along with higher R-squared value.

model_ols <- lm(allmort ~ dry +beertax + jaild + aidall + mlda + unrate + perinc + allnite + comserd,
                data = total_data_frame)
summary(model_ols)

#statistically insignificant variables are dropped from the above model

model_ols_1 <- lm(allmort ~  dry + unrate + allnite + beertax + comserd ,
                  data = total_data_frame)
summary(model_ols_1)

# Above model is being added with 2 mode variables pop1517 and pop1820, surprisingly the AIC and BIC values 
# reduced despite adding additional variables into the model.
model_ols_2 <- lm(allmort ~  dry + unrate + allnite + beertax + comserd + pop1517 + pop1820 ,
                  data = total_data_frame)
summary(model_ols_2)
#model_ols_2_resd =  resid(model_ols_2)

#We now plot the residual against the observed values of the variable waiting.

par(mfrow = c(2, 2))  # Split the plotting panel into a 2 x 2 grid
plot(model_ols_2)

#We are removing the heteroskedasticity from the above model to get robust standard errors.
tidy.w(model_ols_2)

# There is significant difference in std. error values for unrate, allnite, comserd variables after 
# removing heteroskedastisity.
AIC(model_ols) 
BIC(model_ols)
AIC(model_ols_1)
BIC(model_ols_1)
AIC(model_ols_2)
BIC(model_ols_2)

# We found that the variables spircons, dry, jaild and mlda are statistically insignificant 
model_fixed <- plm(allmort ~ spircons + dry + jaild + aidall + mlda + unrate + perinc + allnite + comserd,
                   model='within',data = total_data_frame, effect = "twoways" )
summary(model_fixed)
tidy(model_fixed)

# after removing the heteroskedasticity 
tidy.w(model_fixed)

model_fixed_1 <- plm(allmort ~ beertax + aidall + unrate + perinc + allnite + pop1517 + pop1820,
                     model='within',data = total_data_frame, effect = "twoways" )
summary(model_fixed_1)
plmtest(model_fixed_1)

model_random <- plm(allmort ~ beertax + aidall + unrate + perinc + allnite + pop1517 + pop1820 + comserd,
                    model='random',data = total_data_frame)
summary(model_random)

model_random_1 <- plm(allmort ~ beertax + aidall + unrate + perinc + allnite + pop1517+ pop1820,
                      model='random',data = total_data_frame)
summary(model_random_1)
#AIC(model_random_1)
#dim(tidy(model_random))
tidy(model_random_1)

phtest(model_fixed_1,model_random_1)
anova(model_ols_1,model_ols_2)

# This fixed effects model has lower R-squared values than the previous model but 
# has statistically significant variables in it 

# Now lets look at the graphs between the statistically significant independant variables and 

# new dataframe removing the state and year column.
corr_all <- total_data_frame [c(-1,-2)]

# new dataframe with the variables from final model, model_fixed_1 
model_corr <- total_data_frame [c("allmort", "beertax", "aidall", "unrate", "perinc", "allnite", "pop1517", "pop1820")]

#dev.off()
# Generating correlation matrix with all the variables
ggcorr(corr_all, method = c("everything", "pearson")) 
ggpairs(corr_all, title="Correlogram of Variables from Pooled OLS-Model") 

# Generating correlation pairs with variables from the final model. 
ggpairs(model_corr, title="Correlogram of Variables from Final Model") 

# Beer Tax VS # Vehice Fatalities
bt_vf <- ggplot(model_corr, aes(x=beertax, y=allmort)) +
  geom_point() + xlab("Beer Tax: Tax on Case of Beer ($)") + ylab("# Vehice Fatalities") + ggtitle("Beer Tax VS # Vehice Fatalities")
  geom_rug(col="steelblue",alpha=0.1, size=1.5)

# Population 18-20 VS # Vehice Fatalities
age_vf <- ggplot(model_corr, aes(x=pop1820, y=allmort)) +
  geom_point() + 
  geom_smooth(method=lm , color="red", fill="#69b3a2", se=TRUE) +
  xlab("Population, 18-20 year olds") + ylab("# Vehice Fatalities") +
  ggtitle("Population 18-20 VS # Vehice Fatalities") 


alcl_vf <- ggplot(model_corr, aes(x=aidall, y=allmort)) +
  geom_point() + 
  geom_smooth(method=lm , color="red", fill="#69b3a2", se=TRUE) +
  xlab("# of alcohol-involved VF") + ylab("# Vehice Fatalities") +
  ggtitle("Alcohol-involved VF vs Vehice Fatalities") 

unr_vf <- ggplot(model_corr, aes(x=unrate, y=allmort)) +
  geom_point() + 
  geom_smooth(method=lm , color="red", fill="#69b3a2", se=TRUE) +
  xlab("# of alcohol-involved VF") + ylab("# Vehice Fatalities") +
  ggtitle("Unemployment Rate vs Vehice Fatalities") 

# Generating correlation pairs with variables from the Pooled final model. 
model_pool_data <- total_data_frame [c("allmort", "beertax", "dry", "unrate", "comserd", "allnite","pop1517", "pop1820")]
ggpairs(model_pool_data, title="Correlogram of Variables from Pooled OLS-Model") 

# plotting all corre grpahs together
theme_set(theme_cowplot())
plot_grid(bt_vf, age_vf, alcl_vf, unr_vf, ncol = 2, nrow = 2)
