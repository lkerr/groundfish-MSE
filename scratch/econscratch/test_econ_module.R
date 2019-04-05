# some code to test "get_predict_etargeting.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


datapath <- 'data/data_processed/econ'
load(file.path(datapath,"full_targeting.RData"))
load(file.path(datapath,"full_production.RData"))



#code to test function. Remove when done.
#predicted_trips<-get_predict_etargeting(targeting_dataset)
#production_outputs<-get_predict_eproduction(production_dataset)

day<-2
# for (day in 1:365){
#   subset both the targeting and production datasets based on date
  
working_production<-production_dataset[which(production_dataset$doffy==day),]
working_targeting<-targeting_dataset[which(targeting_dataset$doffy==day),]



#   overwrite cumulative harvest of each stock.

   
#   
#   predict_eproduction: predict harvest of each stock by each vessel condition on targeting that stock.  Also predict revenue from that stock, and all revenue.  keep just 6 columns: hullnum, date, spstock as key variables.  harvest, revenue, and expected revenue as columns that I care about. 

production_outputs<-get_predict_eproduction(working_production)

#   
#   use those three key variables to merge-update harvest, revenue, and expected revenue in the targeting dataset
test<-merge(working_targeting,production_outputs, by=c("hullnum2","date","spstock2"))


# Do we remove from the choice set and predict?  Or set harvest=0 and predict
#   
#   predict targeting and retain only the best trip from the set of open stocks. 
#   Store that day somewhere.  Use the quantity multiplier matrix to figure out how much of each stock is actually caught by each vessel on each day.
#   
#   add up and save the cumulative harvest   
#   Check the catch limits, close the fishery if necessary.
#   Save the vessel level outcomes somewhere
# }






