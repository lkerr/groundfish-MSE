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

revenue_holder<-as.list(NULL)
  #source('processes/loadEcon.R')
  
  #Initialize the trips data.table. I need it to store the previous choice.
  keepcols<-c("hullnum","spstock2","choice_prev_fish")
  trips<-copy(targeting_dataset[[1]])
  trips<-trips[, ..keepcols]
  trips<-trips[spstock2!="nofish"]
  colnames(trips)[3]<-"targeted"

  
  # day<-1
  # test30<-targeting_dataset[[day]]
  set.seed(2)
  
  top_loop_start<-Sys.time()

  for (day in 1:365){
    #   subset both the targeting and production datasets based on date and jams them to data.tables
    # Subset for the day.  Predict targeting
    working_targeting<-copy(targeting_dataset[[day]])
 
    working_targeting[, choice_prev_fish:=0]
    working_targeting<-working_targeting[trips, choice_prev_fish:=targeted , on=c("hullnum","spstock2")]
    
    get_predict_eproduction(working_targeting)
    
    
    #zero_out_targets will set the catch and landings multipliers to zero depending on the value of underACL, stockarea_open, and mproc$EconType
    
    working_targeting<-joint_adjust_allocated_mults(working_targeting,fishery_holder, econtype)
    working_targeting<-joint_adjust_others(working_targeting,fishery_holder, econtype)
    working_targeting<-get_joint_production(working_targeting,spstock2s) 
    working_targeting[, exp_rev_total:=exp_rev_total/1000]
    
    
    # Predict targeting
    trips<-get_predict_etargeting(working_targeting)
    
    # Predict targeting
    # this is where infeasible trips should be eliminated.
    
    trips<-zero_out_closed_areas_asc_cutout(trips,fishery_holder)
    
    # draw trips probabilistically.  A trip is selected randomly from the choice set. 
    # The probability of selection is equal to prhat
    trips<-get_random_draw_tripsDT(trips)
    #drop out trip that did not fish (they have no landings or catch). 
    trips<-trips[spstock2!="nofish"]
    
    catches<-get_reshape_catches(trips)
    landings<-get_reshape_landings(trips)
    
    #I don't think I need to do this.
    target_rev<-get_reshape_targets_revenues(trips)
    #I don't think I need to do this.
    
  }
  
  top_loop_end<-Sys.time()
  big_loop<-top_loop_end-top_loop_start
  
  fishery_holder$removals_mt<-fishery_holder$cumul_catch_pounds/(pounds_per_kg*kg_per_mt)+fishery_holder$nonsector_catch_mt
  
  
  
# 
#   trips2<-trips[spstock2!="nofish"]
# 
#   working_targeting<-copy(targeting_dataset[[2]])
#   working_targeting[trips2, choice_prev_fish2:=targeted , on=c("hullnum","spstock2")]
#   setcolorder(working_targeting, c("hullnum", "spstock2", "choice_prev_fish","choice_prev_fish2"))
#   
              