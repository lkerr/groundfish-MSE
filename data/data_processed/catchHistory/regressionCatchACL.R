library(tidyverse)
library(VGAM)

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

# organize for regression
regdata <- mydata %>%
  spread(data_type,total) %>% 
  mutate(ACL2=ACL^2) %>% 
  gather(data_type,total,-c(year,stock)) %>% 
  spread(stock,total) %>% 
  myspread(data_type, c("cod","haddock"))

#####  - Fit implementation error models - #####
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
#c(AIC(mvreg_int),AIC(mvreg_cod),AIC(mvreg_had),AIC(mvreg_both),AIC(mvreg_both2))
c(AICc(mvreg_int),AICc(mvreg_cod),AICc(mvreg_had),AICc(mvreg_both),AICc(mvreg_both2))

Coef(fit_int, matrix = TRUE)
summary(fit_int)
AICc(fit_int)

fit_int<-vglm(cbind(Catch_cod,Catch_haddock)~1,family=binormal,regdata)
Coef(fit_int, matrix = TRUE)
summary(fit_int)
AICc(fit_int)

# in_cod<-seq(0,10000,length.out=20)
# in_haddock<-seq(0,100000,length.out=20)
predictvglm(vlm1,list(ACL_cod=in_cod,ACL_haddock=in_haddock),se.fit=TRUE)
