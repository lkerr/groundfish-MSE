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
source('processes/genBaselineACLs_Econonly.R')




top_loop_start<-Sys.time()



####################These are temporary changes for testing ####################
mproc_bak<-mproc
mproc<-mproc_bak[2:13,] #selects validation, counterfactual and counterfactual_single 
mproc<-mproc_bak[2:5,] #selects validation  
#mproc<-mproc_bak[17:20,] #selects "validation single"  

nrep<-1
# yrs contains the calendar years, the calendar year corresponding to y is yrs[y].  we want to go 'indexwise' through the year loop.
# I want to start the economic model at fmyear=2010 and temporarily end it in 2011
start_sim<-2010
end_sim<-2015

fyear<-which(yrs == start_sim)
nyear<-which(yrs == end_sim)


####################End Temporary changes for testing ####################


#set the rng state based on system time.  Store the random state.  

#set the rng state based on system time.  Store the random state.  
# if we use a plain old date (seconds since Jan 1, 1970), the number is actually too large, but we can just rebase to seconds since Jan 1, 2018.

start<-Sys.time()-as.POSIXct("2018-01-01 00:00:00",tz="","%Y-%m-%d %H:%M:%S")
start<-as.double(start)*100
set.seed(start)

oldseed_ALL <- .Random.seed
showProgBar<-TRUE    

####################End Parameter and storage Setup ####################
#This depends on mproc, fyear, and nyear. So it should be run *after* it is reset. I could be put in the runSetup.R script. But since I'm  adjusting fyear and nyear temporarily, I need it here (for now).

source('processes/setupYearIndexing_Econ.R')

# for(r in 1:nrep){
# 
# for(m in 1:nrow(mproc)){
#   model = mproc$EconData[m]
#   
#   
#   tchars<-nchar(model)
#   modelno<-substr(model,tchars,tchars)
#   
#   manage_counter<-0
  
r<-1
m<-4


  source('processes/setupEconType.R')

y<-fyear

source('processes/withinYearAdmin.R')



source('processes/loadEcon2.R')

# subset just the current year of regulations
econ_baseline_yearly<-econ_baseline[gffishingyear==yrs[y]]
bio_params_for_econ <- get_bio_for_econ_only(stock,econ_baseline_yearly)


#Instead of doing this line, you'll want to copy/paste pieces from it and run them by hand.
# source('processes/runEcon_moduleonly.R')

############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 

### Probably need to add the trawl survey (trawlsurvey) index here and then push over trawl survey values into the targeting dataset.  But you might do that in outside this function.
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

#set up a list to hold the expected revenue by date, hullnum, and target spstock2
annual_revenue_holder<-list()

#set up a list to hold the date, spstock2, and aggregate metrics, like open/closed status and cumulative catch
annual_fishery_status_holder<-list()


#Initialize the trips data.table. 
  if(y == fmyearIdx){
  keepcols<-c("hullnum","spstock2","choice_prev_fish")
  trips<-copy(targeting_dataset[[1]])
  trips<-trips[, ..keepcols]
  trips<-trips[spstock2!="nofish"]
  colnames(trips)[3]<-"targeted"
  trips<-trips[targeted==1]
  
  }



day<-10

set.seed(2)
#day<-100

working_targeting<-copy(targeting_dataset[[day]])
working_targeting$OG_choice_prev_fish<-working_targeting$choice_prev_fish

working_targeting<-get_predict_eproduction(working_targeting)
  
  
working_targeting[spstock2=="nofish", harvest_sim:=0L]
working_targeting[, delta:=harvest_sim-h_hat]



  summary(working_targeting$delta)
  setcolorder(working_targeting, c("delta", "harvest_sim","h_hat"))
  setorder(working_targeting, -delta)
  
  #alphass<-grep("^alpha",colnames(working_targeting) , value=TRUE)


    # Keep or update choice_prev_fish
     # working_targeting[trips, `:=` (tx2=targeted, tx=targeted) , on=c("hullnum","spstock2")]
     # 
     # working_targeting[is.na(tx2), tx2 := 0]     
     # working_targeting[is.na(tx), tx := choice_prev_fish]     
     # working_targeting[, ttx := sum(tx),by=id]
     # working_targeting[ttx>=2, tx := tx2]
     # working_targeting[, choice_prev_fish :=tx]
     # 
     # dropcol<-c('ttx', 'tx2', 'tx')
     # working_targeting[, (dropcol) := NULL]
  
  
  #zero_out_targets will set the catch and landings multipliers to zero depending on the value of underACL, stockarea_open, and mproc$EconType
  start<-Sys.time()
  working_targeting$exp_rev_bak<-working_targeting$exp_rev_total

  
  
    working_targeting<-joint_adjust_allocated_mults(working_targeting,fishery_holder, econtype)
    working_targeting<-joint_adjust_others(working_targeting,fishery_holder, econtype)
  #TESTED TO HERE.
  # In testing, we have to zero out the dl_ variables
    
    
  dl_vars<-grep("^dl_",colnames(working_targeting) , value=TRUE)
  working_targeting[,(dl_vars):=NA]
    
  working_targeting<-get_joint_production(working_targeting,spstock2s) 
  working_targeting[, exp_rev_total:=exp_rev_total/1000]
  working_targeting[spstock2=="nofish", exp_rev_total:=0L]
  working_targeting[, deltar:=abs(exp_rev_total-exp_rev_bak)]
  summary(working_targeting$deltar)
  setcolorder(working_targeting, c("deltar", "exp_rev_total", "exp_rev_bak"))
  setorder(working_targeting,-deltar)
  joint.product<-joint.product+Sys.time()-start
  
  
    
  
  
  # Predict targeting
  trips<-get_predict_etargeting(working_targeting)
  
  trips[, deltapr:=abs(prhat-pr_hat_2)]
  trips[, relpr:=deltapr/pr_hat_2]
  
  trips[, deltaxb:=abs(xb-xb_hat_2)]
  setcolorder(trips, c("deltapr", "relpr","deltaxb", "xb", "xb_hat_2", "prhat","pr_hat_2"))
  setorder(trips,-relpr)
  
  
  e.targeting<-e.targeting+Sys.time()-start
  
  # Predict targeting
  # this is where infeasible trips should be eliminated.
  start<-Sys.time()
  
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
  
  cleanup1<-cleanup1+Sys.time()-start
  
  # left join landings into fishery_holder.  Replace fishery holder's cumul_catch_pounds=cumul_catch_pounds+daily_catch  remove daily_catch?  
  
  start<-Sys.time()
  
  
  fishery_holder<-fishery_holder[catches, on="spstock2"]
  fishery_holder[, cumul_catch_pounds:= cumul_catch_pounds+daily_pounds_caught]
  fishery_holder[, daily_pounds_caught :=NULL]
  
  fishery_holder<-get_fishery_next_period_areaclose(fishery_holder)
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  # Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  
  start<-Sys.time()
  savelist<-c("hullnum","spstock2","doffy","exp_rev_total","actual_rev_total")
  mm<-c(grep("^c_",colnames(trips), value=TRUE),grep("^l_",colnames(trips), value=TRUE),grep("^r_",colnames(trips), value=TRUE))
  savelist=c(savelist,mm)
  revenue_holder[[day]]<-trips[, ..savelist]
  cleanup2<-cleanup2+Sys.time()-start
  

