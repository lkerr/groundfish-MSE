# some code to test "get_predict_etargeting.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


datapath <- 'data/data_processed/econ'
load(file.path(datapath,"full_targeting.RData"))
load(file.path(datapath,"full_production.RData"))



#END SETUPS













#BEGIN PIECE OF ECON MODULE 
#library(data.table)

#dataframe to hold total catch, acls, and open/closed status by spstock2
#set to Open, 1lb of catch on May 1, and all acls are 100,000 lbs
fishery_holder<-targeting_dataset
fishery_holder<-unique(fishery_holder[c("spstock2")])
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch<-1
fishery_holder$acl<-100000




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
wtcols<-ncol(working_targeting)

working_targeting<-merge(working_targeting,production_outputs, by=joincols, all.x=TRUE)

#fill exp_rev_sim, exp_rev_total_sim, harvest_sim=0 
working_targeting$exp_rev_sim[is.na(working_targeting$exp_rev_sim)]<-0
working_targeting$exp_rev_total_sim[is.na(working_targeting$exp_rev_total_sim)]<-0
working_targeting$harvest_sim[is.na(working_targeting$harvest_sim)]<-0

# Need some code here to verify that the merge is full.

# check<- wtcols+ncol(production_outputs)-length(joincols)
# if(ncol(working_targeting) !=check){
#   warning("Lost some Columns!")
# }


#overwrite the values of the exp_rev_total, exp_rev, and harvest in the targeting dataset.
working_targeting$exp_rev<-working_targeting$exp_rev_sim
working_targeting$exp_rev_total<-working_targeting$exp_rev_total_sim
working_targeting$h_hat<-working_targeting$harvest_sim

# Predict targeting
trips<-get_predict_etargeting(working_targeting)

#this is where infeasible trips should be eliminated.
trips<-zero_out_closed(trips,fishery_holder)

#Keep the "best trip"  -- sort on hullnum2, date and prhat. then keep the hullnum2, date with the largest prhat.
trips <- data.table(trips, key=c("hullnum2", "date","prhat"))
trips<-trips[, tail(.SD, 1), by=c("hullnum2","date")]


# Expand from harvest of the target to harvest of all.

#   add up today's harvest across the vessels   
daily_catch<-trips[, list(cumul_catch=sum(h_hat)), by = spstock2]

subs<-fishery_holder[c("spstock2","cumul_catch")]

#   construct new cumulative catch, by the entire fishery
subs<-rbind(daily_catch,subs)


cumul_catch<-aggregate(subs$cumul_catch,by=list(spstock=subs$spstock2), FUN=sum)
colnames(cumul_catch)=c("spstock2","cumul_catch")


# update open holder dataframe.  Set open=0 if catch>=ACL
#   Save the vessel level outcomes somewhere

#spits out spstock2, acl, open, cumul_catch
fishery_holder<-get_check_fishery_open(cumul_catch,fishery_holder)

}
proc.time()-start_time

#detach(package:data.table)



