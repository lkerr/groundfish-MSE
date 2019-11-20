# some code to run the economic module.
# This code will eventually take in the catch limits, by stock, and either biomass  


############################################################
#Preamble stuff that is contained in other places.
#load in functions
#set class to not HPCC
#load libraries
#declare some paths to read and save things that I'm scratchpadding
############################################################

# you ran runSim.R and save the bio parameters here
# econsavepath <- 'scratch/econscratch'
# save(bio_params_for_econ,file=file.path(econsavepath,"temp_biop.RData"))

#rm(list=ls())

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

#scratchdir<-"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/scratch/econscratch"
#Rcpp::sourceCpp(file.path(scratchdir,"matsums.cpp"))

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

fishery_holder$sectorACL[3]<-10

revenue_holder<-as.list(NULL)



  #source('processes/loadEcon.R')


readin<-0

merge.prod<-0
construct.months<-0
predict.production<-0
merge.inputs<-0
merge.outputs<-0
merge.multipliers<-0
cleanup1<-0
cleanup2<-0
joint.product<-0
e.targeting<-0
random <-0
zeroout<-0
uniq<-0
replicateout<-0
keeper<-0
overhead<-0

myyear<-2015
mydraw<-myyear-2009

start<-Sys.time()

econdatafile<-paste0("full_targeting_",myyear,".Rds")
targeting_dataset<-readRDS(file.path(econdatapath,econdatafile))




set.seed(2)
day<-1
#Initialize the trips data.table. I need it to store the previous choice.
keepcols<-c("id","spstock2","choice_prev_fish")
trips<-copy(targeting_dataset[[day]])
trips<-trips[, ..keepcols]
#trips<-trips[spstock2!="nofish"]
colnames(trips)[3]<-"targeted"




overhead<-overhead+Sys.time()-start

top_loop_start<-Sys.time()

for (day in 1:365){

  # Subset for the day.  Add in production coeffients and construct some extra data.
start<-Sys.time()
working_targeting<-copy(targeting_dataset[[day]])
readin<-readin+Sys.time()-start

start<-Sys.time()
working_targeting<-get_predict_eproduction(working_targeting)

#working_targeting$harvest_sim[working_targeting$spstock2=="nofish"]<-0
working_targeting[.("nofish"), on=c("spstock2"), harvest_sim:=0]

predict.production<-predict.production+Sys.time()-start


    # Keep or update choice_prev_fish
    # 
     working_targeting[, choice_prev_fish:=0]
     working_targeting<-working_targeting[trips, choice_prev_fish:=targeted , on=c("id","spstock2")]
    # 
    
    
    #zero_out_targets will set the catch and landings multipliers to zero depending on the value of underACL, stockarea_open, and mproc$EconType
start<-Sys.time()

    working_targeting<-joint_adjust_allocated_mults(working_targeting,fishery_holder, econtype)
    working_targeting<-joint_adjust_others(working_targeting,fishery_holder, econtype)
    working_targeting<-get_joint_production(working_targeting,spstock2s) 
    working_targeting[, exp_rev_total:=exp_rev_total/1000]
    working_targeting[.("nofish"), on=c("spstock2"), exp_rev_total:=0]
    
    #working_targeting$exp_rev_total[working_targeting$spstock2=="nofish"]<-0

joint.product<-joint.product+Sys.time()-start


start<-Sys.time()

    # Predict targeting
    trips<-get_predict_etargeting(working_targeting)
    e.targeting<-e.targeting+Sys.time()-start
    
    # Predict targeting
    # this is where infeasible trips should be eliminated.
    start<-Sys.time()
    
    trips<-zero_out_closed_areas_asc_cutout(trips,fishery_holder)
    zeroout<-zeroout+Sys.time()-start
    
    start<-Sys.time()
    # draw trips probabilistically.  A trip is selected randomly from the choice set. 
    # The probability of selection is equal to prhat
    trips<-get_random_draw_tripsDT(trips)
    #drop out trip that did not fish (they have no landings or catch). 
    #trips<-trips[spstock2!="nofish"]
    random<-random+Sys.time()-start
    
    start<-Sys.time()
    catches<-get_reshape_catches(trips)
    landings<-get_reshape_landings(trips)
    
    #I don't think I need to do this.
    #target_rev<-get_reshape_targets_revenues(trips)
    #I don't think I need to do this.
    
    cleanup1<-cleanup1+Sys.time()-start
    
  # left join landings into fishery_holder.  Replace fishery holder's cumul_catch_pounds=cumul_catch_pounds+daily_catch  remove daily_catch?  
 
    start<-Sys.time()
    
     
  fishery_holder<-fishery_holder[catches, on="spstock2"]
  fishery_holder[, cumul_catch_pounds:= cumul_catch_pounds+daily_pounds_caught]
  fishery_holder[, daily_pounds_caught :=NULL]

  fishery_holder<-get_fishery_next_period_areaclose(fishery_holder)
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  # Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  
  savelist<-c("id","hullnum","spstock2","doffy","exp_rev_total","actual_rev_total")
  mm<-c(grep("^c_",colnames(trips), value=TRUE),grep("^l_",colnames(trips), value=TRUE),grep("^r_",colnames(trips), value=TRUE))
  savelist=c(savelist,mm)
  revenue_holder[[day]]<-trips[, ..savelist]
  cleanup2<-cleanup2+Sys.time()-start
  
}
  
  top_loop_end<-Sys.time()
  big_loop<-top_loop_end-top_loop_start
  
  
  # merge.prod
  # construct.months
  # merge.inputs
  # merge.outputs
  # merge.multipliers
  
  readin
  predict.production
  cleanup1
  cleanup2
  joint.product
  e.targeting
  big_loop
  zeroout
  random
  
  fishery_holder[, removals_mt:=cumul_catch_pounds/(pounds_per_kg*kg_per_mt)+nonsector_catch_mt]
  
  
#  fishery_holder$removals_mt<-fishery_holder$cumul_catch_pounds/(pounds_per_kg*kg_per_mt)+fishery_holder$nonsector_catch_mt
  
  
  
# 
