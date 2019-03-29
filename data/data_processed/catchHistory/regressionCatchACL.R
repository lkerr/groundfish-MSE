##### 
# Fit a multivariate regression to the catch and ACL data for GB cod and haddock
# Jonathan Cummings and Gavin Fay

library(tidyverse)
library(VGAM)
library(AICcmodavg)
library(broom)

##### - Functions - #####
# Spread keeping multiple value columns
myspread <- function(df, key, value) {
  # quote key
  keyq <- rlang::enquo(key)
  # break value vector into quotes
  valueq <- rlang::enquo(value)
  s <- rlang::quos(!!valueq)
  df %>% gather(variable, value, !!!s) %>%
    unite(temp, !!keyq, variable) %>%
    spread(temp, value)
}

##### - Data Import and Processing - #####
# Reorganize catchHist data for plotting
catchHist<-read_csv("catchHist.csv")

mydata <- catchHist %>% 
  select(Stock, Total, Year, data_type) %>% #select columns of interest
  rename_all(tolower) %>% #make all names lowercase
  mutate(stock = tolower(stock)) %>% #make stock names lowercase
  filter(grepl(paste(c("cod","haddock"), collapse="|"),stock)) #get just cod and haddock data

# Plot time series of catch, ACL, C:ACL, Discards, and Landing
ggplot(mydata, aes(x=year, y=total, group=data_type, color=data_type)) +
  geom_line() +
  facet_wrap(~stock,scales = "free")

##### - Set up data to model cod-haddock Interactions - #####
# select just GB cod and haddock
mydata<-mydata %>% 
  filter(stock=="gb cod"|stock=="gb haddock")
mydata$stock[mydata$stock=="gb cod"]<-"cod"
mydata$stock[mydata$stock=="gb haddock"]<-"haddock"

# Plot time series of catch, ACL, C:ACL, Discards, and Landing
plotdata<-mydata %>% 
  filter(data_type=="Catch"|data_type=="ACL")

ggplot(plotdata, aes(x=year, y=total, group=data_type, color=data_type)) +
  geom_line() +
  facet_wrap(~stock,scales = "free")

# Plot time series of catch to ACL for GB
plotdata2<-mydata %>% 
  filter(data_type=="CtoACL")

ggplot(plotdata2, aes(x=year, y=total, group=stock, color=stock)) +
  geom_line() + geom_hline(yintercept=100)+ ylab("Catch as Percentage of ACL")

# organize for regression
regdata <- mydata %>%
  spread(data_type,total) %>% 
  mutate(ACL2=ACL^2) %>% 
  gather(data_type,total,-c(year,stock)) %>% 
  spread(stock,total) %>% 
  myspread(data_type, c("cod","haddock"))

#####  - Fit single variable implementation error models - #####
# Catch of Cod
reg_codInt<-lm(Catch_cod~1,regdata)
reg_cod<-lm(Catch_cod~ACL_cod,regdata)
reg_codBoth<-lm(Catch_cod~ACL_cod+ACL_haddock,regdata)
# Catch of Haddock
reg_hadInt<-lm(Catch_haddock~1,regdata)
reg_had<-lm(Catch_haddock~ACL_haddock,regdata)
reg_hadBoth<-lm(Catch_haddock~ACL_haddock+ACL_cod,regdata)

# Calculate AIC scores
c(AIC(reg_codInt),AIC(reg_cod),AIC(reg_codBoth),AIC(reg_hadInt),AIC(reg_had),AIC(reg_hadBoth))
c(AICc(reg_codInt),AICc(reg_cod),AICc(reg_codBoth),AICc(reg_hadInt),AICc(reg_had),AICc(reg_hadBoth))

# Report regression results
tidy(reg_cod)
augment(reg_cod)
glance(reg_cod)

tidy(reg_hadInt)
augment(reg_hadInt)
glance(reg_hadInt)

#####  - Fit multivariate implementation error models - #####
# Intercept only model
mvreg_int<-vglm(cbind(Catch_cod,Catch_haddock)~1,family=binormal,regdata)
# Cod ACL model
mvreg_cod<-vglm(cbind(Catch_cod,Catch_haddock)~ACL_cod,family=binormal,regdata)
# Haddock ACL model
mvreg_had<-vglm(cbind(Catch_cod,Catch_haddock)~ACL_haddock,family=binormal,regdata)
# Cod and Haddock model
mvreg_both<-vglm(cbind(Catch_cod,Catch_haddock)~ACL_cod+ACL_haddock,family=binormal,regdata)
# Cod, Cod^2 and Haddock, Haddock^2 model
mvreg_both2<-vglm(cbind(Catch_cod,Catch_haddock)~ACL_cod+ACL2_cod+ACL_haddock+ACL2_haddock,
                 family=binormal,regdata)

# Calculate AIC scores
c(AIC(mvreg_int),AIC(mvreg_cod),AIC(mvreg_had),AIC(mvreg_both),AIC(mvreg_both2))
c(AICc(mvreg_int),AICc(mvreg_cod),AICc(mvreg_had),AICc(mvreg_both),AICc(mvreg_both2))

# Report regresion results
VGAM::Coef(mvreg_cod, matrix = TRUE)
summary(mvreg_cod)

VGAM::Coef(mvreg_both, matrix = TRUE)
summary(mvreg_both)

##### - set up prediction for Cod ACL model- #####
in_cod<-data.frame(ACL_cod=seq(0,10000,length.out=20))
in_haddock<-data.frame(ACL_haddock=seq(0,100000,length.out=20))
predict(reg_cod,in_cod,se.fit=TRUE)
predict(reg_hadInt,in_haddock,se.fit=TRUE)

predictvglm(mvreg_cod,list(ACL_cod=in_cod$ACL_cod),se.fit=TRUE)
predictvglm(mvreg_both,list(ACL_cod=in_cod$ACL_cod,
                            ACL_haddock=in_haddock$ACL_haddock),se.fit=TRUE)

pred_plot<-predictvglm(mvreg_cod,list(ACL_cod=in_cod$ACL_cod))
pred_plot2<-pred_plot %>%
  as_tibble() %>% 
  select(mean1,mean2) %>% 
  mutate(Catch_Cod=mean1) %>% 
  mutate(Catch_Haddock=mean2) %>%
  select(Catch_Cod,Catch_Haddock) %>% 
  cbind(in_cod) %>% 
  gather(catch,value, -ACL_cod)

# plot prediction
ggplot(pred_plot2, aes(x=ACL_cod,y=value,group=catch,col=catch)) +
  geom_line() + xlab("Cod ACL") + ylab("Catch")

##### - Set up prediction for Cod and Haddock ACL model - #####
# Create ACL combos
pred_vals<-expand.grid(in_cod$ACL_cod,in_haddock$ACL_haddock)
# Predict
pred_plot_both<-predictvglm(mvreg_both,list(ACL_cod=pred_vals$Var1,ACL_haddock=pred_vals$Var2))
# reorganize data
pred_plot_both2<-pred_plot_both %>%
  as_tibble() %>% 
  select(mean1,mean2) %>% 
  mutate(Catch_Cod=mean1) %>% 
  mutate(Catch_Haddock=mean2) %>%
  select(Catch_Cod,Catch_Haddock) %>% 
  cbind(Cod_ACL=pred_vals$Var1,Haddock_ACL=pred_vals$Var2) %>% 
  gather(catch,value, -Cod_ACL, -Haddock_ACL)

# Plot
ggplot(pred_plot_both2, aes(x=Cod_ACL,y=Haddock_ACL,col=value)) + 
  facet_grid(~catch) +  geom_point(aes(size=4))+geom_contour(aes(z=value),col="black") + theme_bw()

