# some code to test "get_predict_etargeting.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


datapath <- 'data/data_processed/econ'
savepath<-'scratch/econscratch'
load(file.path(datapath,"full_targeting.RData"))
#End code to test function. Remove when done.





#data wrangling on test datasets  -- once you have a full set of coefficients, you should be able to delete this.
tds<-targeting_dataset
#end data wrangling on test dataset



part3<-0
sa<-Sys.time()

#code to test function. Remove when done.
predicted_trips<-get_predict_etargeting(targeting_dataset)
#targeting_dataset<-cbind(phat,targeting_dataset)

sb<-Sys.time()
part3<-part3+sb-sa

predicted_trips <- predicted_trips %>% 
  group_by(hullnum2,date) %>%
  filter(prhat == max(prhat)) 


#Not sure where to put hhat right now, probably overwrite hhat in production_dataset.  

save(predicted_trips, file=file.path(savepath, "trips_combined.RData"))

