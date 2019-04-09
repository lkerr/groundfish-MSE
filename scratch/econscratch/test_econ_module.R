# some code to test "get_predict_etargeting.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


datapath <- 'data/data_processed/econ'
load(file.path(datapath,"full_targeting.RData"))
load(file.path(datapath,"full_production.RData"))


#END SETUPS




#BEGIN PIECE OF ECON MODULE 

#This should probably go into a container
#dataframe to hold total catch, acls, and open/closed status by spstock2
#set to Open, 1lb of catch on May 1, and all acls are 100,000 lbs
fishery_holder<-targeting_dataset
fishery_holder<-unique(fishery_holder[c("spstock2")])
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch<-1
fishery_holder$acl<-1e16


start_time <- proc.time()
for (day in 1:30){
  
# for (day in 1:365){
#   subset both the targeting and production datasets based on date
  
working_production<-production_dataset[which(production_dataset$doffy==day),]
working_targeting<-targeting_dataset[which(targeting_dataset$doffy==day),]

#   overwrite cumulative harvest and log cumulative catch of each stock.
working_production<-merge(working_production,fishery_holder, by="spstock2")

working_production$h_cumul<-working_production$cumul_catch
working_production$logh_cumul<-log(working_production$cumul_catch)


#   predict_eproduction: predict harvest of each stock by each vessel condition on targeting that stock.  Also predict revenue from that stock, and all revenue.  keep just 6 columns: hullnum, date, spstock as key variables.  harvest, revenue, and expected revenue as columns that I care about. 

production_outputs<-get_predict_eproduction(working_production)

#   
#   use those three key variables to merge-update harvest, revenue, and expected revenue in the targeting dataset
joincols<-c("hullnum2","date","spstock2")

working_targeting<-merge(working_targeting,production_outputs, by=joincols, all.x=TRUE)

#fill exp_rev_sim, exp_rev_total_sim, harvest_sim=0 for the nofish options
working_targeting$exp_rev_sim[is.na(working_targeting$exp_rev_sim)]<-0
working_targeting$exp_rev_total_sim[is.na(working_targeting$exp_rev_total_sim)]<-0
working_targeting$harvest_sim[is.na(working_targeting$harvest_sim)]<-0

#overwrite the values of the exp_rev_total, exp_rev, and harvest in the targeting dataset.

working_targeting$exp_rev<-working_targeting$exp_rev_sim
working_targeting$exp_rev_total<-working_targeting$exp_rev_total_sim
working_targeting$h_hat<-working_targeting$harvest_sim

# Predict targeting
trips<-get_predict_etargeting(working_targeting)

#this is where infeasible trips should be eliminated.
trips<-zero_out_closed(trips,fishery_holder)

#Keep the "best trip"  -- sort on hullnum2, date and prhat. then keep the hullnum2, date with the largest prhat.
trips <- trips %>% 
  group_by(hullnum2,date) %>%
  filter(prhat == max(prhat)) 


# Expand from harvest of the target to harvest of all.

#   add up today's harvest across the vessels   
daily_catch<-aggregate(trips$h_hat,by=list(spstock2=trips$spstock2), FUN=sum)
colnames(daily_catch)=c("spstock2","cumul_catch")


#   rbind this to the previous cumulative catch
daily_catch<-rbind(daily_catch,fishery_holder[c("spstock2","cumul_catch")])
daily_catch<-aggregate(daily_catch$cumul_catch,by=list(spstock=daily_catch$spstock2), FUN=sum)
colnames(daily_catch)=c("spstock2","cumul_catch")


# update the fishery holder dataframe
# spits out spstock2, acl, open, cumul_catch
fishery_holder<-get_fishery_next_period(daily_catch,fishery_holder)

#cast pounds to NAA

}
proc.time()-start_time


