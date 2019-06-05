##### 
# Fit a multivariate regression to the catch and ACL data for GB cod and haddock
# Jonathan Cummings and Gavin Fay

library(tidyverse)
library(VGAM)
library(AICcmodavg)
library(broom)
# library(TMB)
# library(INLA)
# library(SpatialFA)

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
sslm_codGBInt<-lm(Catch_cod~1,regdata)
sslm_codGB<-lm(Catch_cod~ACL_cod,regdata)
sslm_codGBBoth<-lm(Catch_cod~ACL_cod+ACL_haddock,regdata)
# Catch of Haddock
sslm_haddockGBInt<-lm(Catch_haddock~1,regdata)
sslm_haddockGB<-lm(Catch_haddock~ACL_haddock,regdata)
sslm_haddockGBBoth<-lm(Catch_haddock~ACL_haddock+ACL_cod,regdata)

# Calculate AIC scores
c(AIC(sslm_codGBInt),AIC(sslm_codGB),AIC(sslm_codGBBoth),AIC(sslm_haddockGBInt),AIC(sslm_haddockGB),AIC(sslm_haddockGBBoth))
c(AICc(sslm_codGBInt),AICc(sslm_codGB),AICc(sslm_codGBBoth),AICc(sslm_haddockGBInt),AICc(sslm_haddockGB),AICc(sslm_haddockGBBoth))

# Report regression results
tidy(sslm_codGB)
augment(sslm_codGB)
glance(sslm_codGB)

tidy(sslm_haddockGBInt)
augment(sslm_haddockGBInt)
glance(sslm_haddockGBInt)

#####  - Fit multivariate implementation error models - #####
# Intercept only model
msvgam_int<-vglm(cbind(Catch_cod,Catch_haddock)~1,family=binormal,regdata)
# Cod ACL model
msvgam_codGB<-vglm(cbind(Catch_cod,Catch_haddock)~ACL_cod,family=binormal,regdata)
# Haddock ACL model
msvgam_haddockGB<-vglm(cbind(Catch_cod,Catch_haddock)~ACL_haddock,family=binormal,regdata)
# Cod and Haddock model
msvgam_both<-vglm(cbind(Catch_cod,Catch_haddock)~ACL_cod+ACL_haddock,family=binormal,regdata)
# Cod, Cod^2 and Haddock, Haddock^2 model
msvgam_both2<-vglm(cbind(Catch_cod,Catch_haddock)~ACL_cod+ACL2_cod+ACL_haddock+ACL2_haddock,
                 family=binormal,regdata)

# Calculate AIC scores
c(AIC(msvgam_int),AIC(msvgam_codGB),AIC(msvgam_haddockGB),AIC(msvgam_both),AIC(msvgam_both2))
c(AICc(msvgam_int),AICc(msvgam_codGB),AICc(msvgam_haddockGB),AICc(msvgam_both),AICc(msvgam_both2))

# Report regresion results
VGAM::Coef(msvgam_codGB, matrix = TRUE)
summary(msvgam_codGB)

VGAM::Coef(msvgam_both, matrix = TRUE)
summary(msvgam_both)

##### - set up prediction for Cod ACL model- #####
# create new data for simulated ACL of cod and haddock
in_cod<-data.frame(ACL_cod=seq(0,10000,length.out=20))
in_haddock<-data.frame(ACL_haddock=seq(0,100000,length.out=20))

# -Single stock prediction- #
# predict cod catch given cod ACL
psslm_codGB<-predict(sslm_codGB,in_cod,se.fit=TRUE)
psslm_codGB2<-psslm_codGB %>%
  as_tibble() %>% 
  select(fit) %>% 
  mutate(Catch_Cod=fit) %>%
  select(Catch_Cod) %>% 
  cbind(in_cod)

# plot prediction
ggplot(psslm_codGB2, aes(x=ACL_cod,y=Catch_Cod)) +
  geom_line() + xlab("Cod ACL") + ylab("Catch")

# predict haddock catch given haddock ACL
psslm_haddockGB<-predict(sslm_haddockGBInt,in_haddock,se.fit=TRUE)
psslm_haddockGB2<-psslm_haddockGB %>%
  as_tibble() %>% 
  select(fit) %>% 
  mutate(Catch_had=fit) %>%
  select(Catch_had) %>% 
  cbind(in_haddock)

# plot prediction
ggplot(psslm_haddockGB2, aes(x=ACL_haddock,y=Catch_had)) +
  geom_line() + xlab("Haddock ACL") + ylab("Catch")

# -Multiple stock prediction- #
predictvglm(msvgam_codGB,list(ACL_cod=in_cod$ACL_cod),se.fit=TRUE)
predictvglm(msvgam_both,list(ACL_cod=in_cod$ACL_cod,
                            ACL_haddock=in_haddock$ACL_haddock),se.fit=TRUE)

pred_plot<-predictvglm(msvgam_codGB,list(ACL_cod=in_cod$ACL_cod))
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
pred_plot_both<-predictvglm(msvgam_both,list(ACL_cod=pred_vals$Var1,ACL_haddock=pred_vals$Var2))
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


##### - Model Fit Outputs - #####
# Save model fits to RData files for use in the operating model
# Naming conventions
# sslm = single stock linear model
# msvgam = multiple stock vector generalized additive model

# Single stock models
# codGB
save(sslm_codGB, file = "sslm_codGB.RData")

# haddockGB
sslm_haddockGB<-sslm_haddockGBInt  # Set intercept model (best fit model per AIC) as haddock sslm model for data files
save(sslm_haddockGB, file = "sslm_haddockGB.RData")

save(sslm_codGB,sslm_haddockGB, file = "sslm.RData")

# Multiple stock models
# codGB
colnames(msvgam_codGB@predictors)[1:2]<- c('codGB', 'haddockGB')
save(msvgam_codGB, file = "msvgam_codGB.RData")
# haddockGB
msvgam_haddockGB<-msvgam_codGB
save(msvgam_haddockGB, file = "msvgam_haddockGB.RData")