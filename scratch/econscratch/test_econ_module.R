# some code to run the economic module.
# This code will eventually take in the catch limits, by stock, and either biomass  


############################################################
#Preamble stuff that is contained in other places.
#load in functions
#set class to not HPCC
#load libraries
#declare some paths to read and save things that I'm scratchpadding
############################################################

# you ran runSim.R and save the bio paramters here
econsavepath <- 'scratch/econscratch'
save(bio_params_for_econ,file=file.path(econsavepath,"temp_biop.Rdata"))

rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))
runClass<-'local'
source('processes/loadLibs.R')

econsavepath <- 'scratch/econscratch'
econdatapath <- 'data/data_processed/econ'
############################################################
############################################################
#Pull in datasets and clean them up a little (this is temporary cleaning, so it belongs here)
############################################################
############################################################

load(file.path(econdatapath,"full_targeting.RData"))
load(file.path(econdatapath,"full_production.RData"))
load(file.path(econsavepath,"temp_biop.Rdata"))

production_dataset<-production_dataset[which(production_dataset$gffishingyear==2009),]
targeting_dataset<-targeting_dataset[which(targeting_dataset$gffishingyear==2009),]




############################################################
############################################################
#These should probably go into the container setup
# fishery stats holder is a dataframe that holds
#stock name, open=true/false, cumulative catch to that day, and the acl
#revenue_holder holds daily revenue for each vessel (could contract this to the trip)
############################################################
############################################################

fishery_holder<-bio_params_for_econ[c("spstock2","sectorACL_kg","nonsector_catch_kg","bio_model","SSB")]
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-1

#fishery_holder$bio_model<-0
#fishery_holder$bio_model[fishery_holder$spstock2 %in% c("codGB","pollock","haddockGB","yellowtailflounderGB")]<-1

revenue_holder<-NULL



############################################################
############################################################
# BEGIN PIECE OF ECON MODULE 
# Ideally, everthing from here to the end should be a function.  It's inputs are:
# fishery_holder (which should contain info on the ACL, biomass or stock indices, and which stocks need biological outputs (Catch at age or survivors at age))
# Production and targeting data

# As a function, it can only have one output. A list of stuff?
# Updated fishery_holder?
# Catch or survivors at age -- if so, we'll have to do 
# Revenue or catch by vessel? Topline catch/revenue?
############################################################
############################################################




# It may be faster to change the way this model runs.  Currently, it's day-by-day and the ACLs are checked at
# the end of each day (to shut the fishery down).
# It may be better to 
#  predict for the entire year at the same time, generate a "cumulative harvest" under "all open"
#  Find the date that the first quota binds, then predict from that point forward under "1 closed"
#  Repeat until you get to the end of the year or all quotas bind.
# It also might be better to "split" this feature off from the current working function.

#split the production and targeting datasets into a list of datasets
production_dataset<-split(production_dataset, production_dataset$doffy)
targeting_dataset<-split(targeting_dataset, targeting_dataset$doffy)


start_time<-proc.time()

for (day in 1:365){

#for (day in 1:365){
  #   subset both the targeting and production datasets based on date
  
  working_production<-production_dataset[[day]]
  working_targeting<-targeting_dataset[[day]]
  
  
  #   overwrite cumulative harvest and log cumulative catch of each stock.
  working_production<-left_join(working_production,fishery_holder, by="spstock2")
  
  # working_production$h_cumul<-working_production$cumul_catch_pounds
  # working_production$logh_cumul<-log(working_production$cumul_catch_pounds)
  
  
  #   predict_eproduction: predict harvest of each stock by each vessel condition on targeting that stock.  Also predict revenue from that stock, and all revenue.  keep just 5 columns: hullnum2, date, spstock as key variables.  harvest, revenue, and expected revenue as columns that I care about. 
  
  production_outputs<-get_predict_eproduction(working_production)
  
  
  
  #This bit needs to be replaced with a function that handles the "jointness"
  #expected revenue from this species
  production_outputs$exp_rev_sim<- production_outputs$harvest_sim*production_outputs$price_lb_lag1

  production_outputs$exp_rev_sim<-production_outputs$exp_rev_sim
  #use the revenue multiplier to construct total revenue for this trip.
  #This bit needs to be replaced with a function that handles the "jointness"
  
  
     
  #   use those three key variables to merge-update harvest, revenue, and expected revenue in the targeting dataset
  joincols<-c("hullnum2","date", "spstock2")
  working_targeting<-left_join(working_targeting,production_outputs, by=joincols)
  
  
  #############THIS BIT IS VERY FAST#######
  #fill exp_rev_sim, exp_rev_total_sim, harvest_sim=0 for the nofish options
  working_targeting$exp_rev_sim[is.na(working_targeting$exp_rev_sim)]<-0
  working_targeting$exp_rev_total_sim[is.na(working_targeting$exp_rev_total_sim)]<-0
  working_targeting$harvest_sim[is.na(working_targeting$harvest_sim)]<-0
  
  #overwrite the values of the exp_rev_total, exp_rev, and harvest in the targeting dataset.
  
  # working_targeting$exp_rev<-working_targeting$exp_rev_sim
  # working_targeting$exp_rev_total<-working_targeting$exp_rev_total_sim
  # working_targeting$h_hat<-working_targeting$harvest_sim
  #############END VERY FAST#######
  
  
  trips<-get_predict_etargeting(working_targeting)
  
  
  # Predict targeting
  #this is where infeasible trips should be eliminated.
  #THIS BIT IS VERY FAST 
  
  trips<-zero_out_closed(trips,fishery_holder)
  
  
  #Keep the "best trip"  -- sort on id and prhat. then keep the id with the largest prhat.
  # #THIS BIT IS MEDIUM 
  # 
  # trips <- trips %>% 
  #   group_by(id) %>%
  #   filter(prhat == max(prhat)) 
  
  #draw trips probabilistically
  trips<-trips[order(trips$id,trips$prhat),]
  
  #This takes a while
  trips<-trips%>% 
    group_by(id) %>% 
    mutate(csum = cumsum(prhat))
  
  trips$draw<-runif(nrow(trips), min = 0, max = 1)
  
  #This takes a while
  trips<-trips%>%
    group_by(id) %>%
    mutate(draw = first(draw))
  
  trips<-trips[trips$draw<trips$csum,]
  
  #This takes a while
  trips <-
    trips %>% 
    group_by(id) %>% 
    filter(row_number()==1)
  
  
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  # Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  
  
  #   add up today's revenue across the vessels (not necessary right now, but we end up with 'long' dataset of revenue)  
  # revenue<- trips %>% 
  #   group_by(hullnum2) %>% 
  #   summarise(totalrev=sum(exp_rev_total))
  
  # revenue<-trips[c("hullnum2","spstock2","exp_rev_total")]
  # revenue_holder<-rbind(revenue_holder,revenue)
  
  revenue_holder<-rbind(revenue_holder,trips[c("hullnum2","spstock2","date","exp_rev_total")])
  
  
  #   Pull out daily catch, rename the catch colum, and rbind to the holder. aggregate to update cumulative catch 
  daily_catch<- trips[c("spstock2","h_hat")]
  colnames(daily_catch)[2]<-"cumul_catch_pounds"
  daily_catch<-rbind(daily_catch,fishery_holder[c("spstock2","cumul_catch_pounds")])
  
  daily_catch<- daily_catch %>% 
    group_by(spstock2) %>% 
    summarise(cumul_catch_pounds=sum(cumul_catch_pounds))
  
  # update the fishery holder dataframe
  fishery_holder<-get_fishery_next_period(daily_catch,fishery_holder)
  
  #cast pounds to NAA  you only need to do this for spstock2's that have bio_model==1 in the fishery_holder dataset
  # Watch the units (lbs vs kg/mt)!!!  No 
  
}

proc.time()-start_time
fishery_holder$removals_kg<-fishery_holder$cumul_catch_pounds/pounds_per_kg+fishery_holder$nonsector_catch_kg
rm(list=c("production_dataset","targeting_dataset"))

