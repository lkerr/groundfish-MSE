# some code to run the economic module.
# This code will eventually take in the catch limits, by stock, and either biomass  


############################################################
#Preamble stuff that is contained in other places.
#load in functions
#set class to not HPCC
#load libraries
#declare some paths to read and save things that I'm scratchpadding
############################################################


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

fishery_holder<-unique(targeting_dataset[c("spstock2")])
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-1
fishery_holder$acl<-1e16
fishery_holder$bio_model<-0
fishery_holder$bio_model[fishery_holder$spstock2 %in% c("codGB","pollock","haddockGB","yellowtailflounderGB")]<-1

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



#split the production and targeting datasets into a list of datasets
production_dataset<-split(production_dataset, production_dataset$doffy)
targeting_dataset<-split(targeting_dataset, targeting_dataset$doffy)


start_time<-proc.time()

#for (day in 2:2){
  
 for (day in 1:365){
#   subset both the targeting and production datasets based on date

  working_production<-production_dataset[[day]]
  working_targeting<-targeting_dataset[[day]]
  
    
#   overwrite cumulative harvest and log cumulative catch of each stock.
working_production<-left_join(working_production,fishery_holder, by="spstock2")

# working_production$h_cumul<-working_production$cumul_catch_pounds
# working_production$logh_cumul<-log(working_production$cumul_catch_pounds)


#   predict_eproduction: predict harvest of each stock by each vessel condition on targeting that stock.  Also predict revenue from that stock, and all revenue.  keep just 6 columns: hullnum, date, spstock as key variables.  harvest, revenue, and expected revenue as columns that I care about. 

production_outputs<-get_predict_eproduction(working_production)


#   
#   use those three key variables to merge-update harvest, revenue, and expected revenue in the targeting dataset
joincols<-c("id","spstock2")
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


#Keep the "best trip"  -- sort on hullnum2, date and prhat. then keep the hullnum2, date with the largest prhat.
#THIS BIT IS MEDIUM 

trips <- trips %>% 
  group_by(id) %>%
  filter(prhat == max(prhat)) 

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

rm(list=c("production_dataset","targeting_dataset"))

   