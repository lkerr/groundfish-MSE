
# empty the environment
rm(list=ls())
set.seed(2) 

source('processes/runSetup.R')
library(microbenchmark)
#library(Rcpp)
econsavepath <- 'scratch/econscratch'
############################################################
############################################################
# Pull in temporary dataset that contains economic data clean them up a little (this is temporary cleaning, so it belongs here)
############################################################
############################################################

load(file.path(econsavepath,"temp_biop.RData"))
#make sure there is a nofish in bio_params_for_econ

m<-1
econtype<-mproc[m,]
myvars<-c("LandZero","CatchZero","EconType")
econtype<-econtype[myvars]
############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

revenue_holder<-as.list(NULL)

subset<-0 
eproduction<-0
eproduction2<-0
prep_target_join<-0
prep_target_dc<-0
etargeting<-0
zero_out<-0
randomdraw<-0
holder_update_flatten <-0
next_period_flatten2 <-0
runtime<-0
holder_update_flatten2<-0
loop_start<-proc.time()
revenue_holder<-as.list(NULL)

# z<-function(){
set.seed(2)

# end setups


day<-30

working_targeting<-copy(targeting_dataset[[day]])
get_predict_eproduction(working_targeting)

wt<-copy(working_targeting) 
wt2<-copy(working_targeting) 

spstock_names<-copy(spstock2s)
spstock_names2<-copy(spstock2s)

#spstock_names<-spstock_names[1:4]

# 
 wt<-get_joint_production(wt,spstock_names)
 wt2<-get_joint_production2(wt2,spstock_names)
 m<-colnames(wt)
 setcolorder(wt2,m)
 #some of the columns in wt2 and wt are different (q_)
 checklist<-c(paste0("r_",spstock_names), paste0("l_",spstock_names),paste0("c_",spstock_names),"exp_rev_total","actual_rev_total")
 checklist<-c(paste0("l_",spstock_names),paste0("c_",spstock_names),"exp_rev_total","actual_rev_total")
 checklist<-c(paste0("l_",spstock_names),paste0("c_",spstock_names),paste0("r_",spstock_names), paste0("p_",spstock_names),"quota_cost","exp_rev_total","actual_rev_total")
 
 all.equal(wt[, ..checklist],wt2[, ..checklist])




microbenchmark(ans_sq<-get_joint_production(wt,spstock_names), ans_exp<-get_joint_production2(wt,spstock_names2), times=10)



