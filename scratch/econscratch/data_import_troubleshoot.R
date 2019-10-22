# Troubleshooting code

rm(list=ls())
if(!require(readstata13)) {  
  install.packages("readstata13")
  require(readstata13)}
if(!require(tidyr)) {  
  install.packages("tidyr")
  require(tidyr)}
if(!require(dplyr)) {  
  install.packages("dplyr")
  require(dplyr)}
if(!require(data.table)) {  
  install.packages("data.table")
  require(data.table)}
source('processes/runSetup.R')

rawpath <- './data/data_raw/econ'
savepath <- './data/data_processed/econ'
#rawpath <- 'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE/data/data_raw/econ'
#savepath <- 'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE/data/data_processed/econ'




###########################Make sure you have the correct set of RHS variables.
spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
#spstock_equation=c("exp_rev_total",  "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")

choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")
#choice_equation=c("len" )


targeting_vars=c(spstock_equation, choice_equation)
#these are the postRHS variables
production_vars_pre=c("log_crew","log_trip_days","log_trawl_survey_weight","primary", "secondary")
#these are the post RHS variables
production_vars_post=c("log_crew","log_trip_days","log_trawl_survey_weight","log_sector_acl","primary", "secondary")
production_vars<-c(production_vars_post, "constant")

useful_vars=c("gearcat","post","h_hat","choice", "log_h_hat")
#useful_vars=c("gearcat","post","h_hat","xb_post","choice")

#yearly_savename<-"full_targeting"
#yearly_savename<-"counterfactual"
yearly_savename<-"validation"
wy<-2013

yrsavefile<-paste0(yearly_savename,wy,".Rds")
targeting<-readRDS(file=file.path(savepath, yrsavefile))
t2<-rbindlist(targeting)
is.data.table(t2)

# Adjust the fishing year dummies (to 2009)
# You could probably pass this in through the control file (what do you want to set the fy to?)
# yearzero<-grep("^fy",colnames(t2) , value=TRUE)
# t2[, c(yearzero) :=0] 
# t2[, fy2009 :=1] 


alphavars<-grep("^alpha",colnames(t2) , value=TRUE)
betavars<-grep("^beta",colnames(t2) , value=TRUE)

setcolorder(t2, c(alphavars,betavars))
setorderv(t2,c("gearcat","spstock2"))

# 
 t2[, lapply(.SD, mean, na.rm=TRUE), by=c("spstock2","gearcat"), .SDcols=(alphavars) ] 

# The merge seems to have worked properly
View(head(t2,20))

working_targeting<-t2
working_targeting<-get_predict_eproduction(working_targeting)
working_targeting$harvest_sim[working_targeting$spstock2=="nofish"]<-0


working_targeting[, delta:=abs(harvest_sim-h_hat)]
summary(working_targeting$delta)
setcolorder(working_targeting, c("spstock2","gearcat","delta", "harvest_sim","h_hat",production_vars))
setorder(working_targeting, -delta)
View(head(working_targeting,50))
setorderv(working_targeting,c("gearcat","spstock2"))

working_targeting[, lapply(.SD, mean, na.rm=TRUE), by=c("spstock2","gearcat"), .SDcols=("delta") ] 
vessel<-working_targeting[, lapply(.SD, mean, na.rm=TRUE), by=c("spstock2","hullnum"), .SDcols=("delta") ] 
setorder(vessel,-delta)


# 


# This takes quite a while 
#source('preprocessing/economic/targeting_data_import.R')

