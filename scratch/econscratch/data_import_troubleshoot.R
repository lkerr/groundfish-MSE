# Troubleshooting code for importing dataset, multipliers, prices, and other stuff.

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


econsavepath <- 'scratch/econscratch'
load(file.path(econsavepath,"temp_biop.RData"))

m<-3


econtype<-mproc[m,]
myvars<-c("LandZero","CatchZero","EconType")
econtype<-econtype[myvars]

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

revenue_holder<-as.list(NULL)


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

useful_vars=c("gearcat","post","h_hat","choice", "xb_hat", "log_h_hat")
#useful_vars=c("gearcat","post","h_hat","xb_post","choice")

yearly_savename<-"full_targeting"
#yearly_savename<-"counterfactual"
#yearly_savename<-"validation"
wy<-2015





if (yearly_savename=="counterfactual"){
production_vars<-c(production_vars_pre, "constant")
} else if (yearly_savename=="full_targeting" | yearly_savename=="validation"){
  production_vars<-c(production_vars_post, "constant")
}

yrsavefile<-paste0(yearly_savename,wy,".Rds")
targeting<-readRDS(file=file.path(savepath, yrsavefile))
t2<-rbindlist(targeting)
is.data.table(t2)

# Adjust the fishing year dummies (to 2009)
# You could probably pass this in through the control file (what do you want to set the fy to?)
 yearzero<-grep("^fy",colnames(t2) , value=TRUE)

 if (yearly_savename=="counterfactual"){
   t2[, c(yearzero) :=0]
   t2[, fy2009 :=1]
   } else if (yearly_savename=="full_targeting"){
     t2[, c(yearzero) :=0]
     t2[, fy2015 :=1]
   } else if (yearly_savename=="validation"){
   }
 

alphavars<-grep("^alpha",colnames(t2) , value=TRUE)
betavars<-grep("^beta",colnames(t2) , value=TRUE)

setcolorder(t2, c(alphavars,betavars))
setorderv(t2,c("gearcat","spstock2"))

# 
 t2[, lapply(.SD, mean, na.rm=TRUE), by=c("spstock2","gearcat"), .SDcols=(alphavars) ] 

# The merge seems to have worked properly
#View(head(t2,20))

working_targeting<-t2
working_targeting<-get_predict_eproduction(working_targeting)
working_targeting[spstock2=="nofish", harvest_sim:=0L]


working_targeting[, delta:=abs(harvest_sim-h_hat)]
summary(working_targeting$delta)
#setcolorder(working_targeting, c("spstock2","gearcat","delta", "harvest_sim","h_hat",production_vars))
#setorder(working_targeting, -delta)
#View(head(working_targeting,50))
#setorderv(working_targeting,c("gearcat","spstock2"))

working_targeting[, lapply(.SD, mean, na.rm=TRUE), by=c("spstock2","gearcat"), .SDcols=("delta") ] 
#vessel<-working_targeting[, lapply(.SD, mean, na.rm=TRUE), by=c("spstock2","hullnum"), .SDcols=("delta") ] 
#setorder(vessel,-delta)

working_targeting[, exp_rev_bak :=exp_rev_total]

# spot check things
# output prices
# quota prices
# landings multipliers


q_mult<-grep("^q_",colnames(working_targeting) , value=TRUE)
r_mult<-grep("^r_",colnames(working_targeting) , value=TRUE)

c_mult<-grep("^c_",colnames(working_targeting) , value=TRUE)

#setcolorder(targeting,c("spstock2","doffy",q_mult))
setcolorder(working_targeting,c("hullnum","spstock2","doffy",q_mult))
setorderv(working_targeting,c("hullnum","spstock2","doffy",q_mult))


setcolorder(working_targeting,c("hullnum","spstock2","doffy",c_mult))
setorderv(working_targeting,c("hullnum","spstock2","doffy",c_mult))

View(head(working_targeting,10))

setcolorder(working_targeting,c("hullnum","spstock2","doffy",q_mult))
View(working_targeting[working_targeting$doffy==40],)




working_targeting<-joint_adjust_allocated_mults(working_targeting,fishery_holder, econtype)
working_targeting<-joint_adjust_others(working_targeting,fishery_holder, econtype)
working_targeting<-get_joint_production(working_targeting,spstock2s) 
working_targeting[, exp_rev_total:=exp_rev_total/1000]
working_targeting[spstock2=="nofish", exp_rev_total:=0L]
working_targeting[, deltar:=exp_rev_total-exp_rev_bak]
working_targeting[, absdeltar:=abs(deltar)]

summary(working_targeting$deltar)
summary(working_targeting$absdeltar)

setorder(working_targeting, -absdeltar)
setcolorder(working_targeting, c("spstock2","gearcat","deltar", "absdeltar","exp_rev_total","exp_rev_bak","quota_cost",production_vars))


troubleshoot<-working_targeting[, lapply(.SD, max, na.rm=TRUE), by=c("spstock2","gearcat","MONTH"), .SDcols=("deltar") ] 
setorder(troubleshoot, -deltar)
# Gillnets seems to be fine.  Sea scallops are the worst -- so ?

working_targeting[, lapply(.SD, mean, na.rm=TRUE), by=c("spstock2","gearcat"), .SDcols=("deltar") ] 

working_targeting[, lapply(.SD, max, na.rm=TRUE), by=c("spstock2","gearcat"), .SDcols=("deltar") ] 
working_targeting[, lapply(.SD, min, na.rm=TRUE), by=c("spstock2","gearcat"), .SDcols=("deltar") ] 

# 


# This takes quite a while 
#source('preprocessing/economic/targeting_data_import.R')


# Lets take a look at wm, wo, wi
View(wm[wm$MONTH==2],)

wm[, gffishingyear:=NULL]

wo<-outputprices[[idx]]
wo[, gffishingyear:=NULL]

wi<-inputprices[[idx]]
wi[, gffishingyear:=NULL]




