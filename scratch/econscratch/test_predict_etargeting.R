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



predicted_trips$del<-predicted_trips$prhat-predicted_trips$pr
summary(predicted_trips$del)


test<-predicted_trips[predicted_trips$hullnum2==286,]
test<-test[test$date==as.Date("2009-09-05"),]

#We see maximum differences of magnitude .001 (A tenth of 1%), which is probably due to rounding differences.  I think stata will use quad precision internally, but only export in double precisions.  This is NBD.

predicted_trips <- predicted_trips %>%
  select(xb,prhat, pr, del, spstock2, exp_rev_total, das_charge, fuelprice_distance, distance, mean_wind, mean_wind_noreast, permitted, lapermit ,partial_closure ,start_of_season, wkly_crew_wage, len, fuelprice, fuelprice_len, everything())
 
predicted_trips<-predicted_trips[order(-predicted_trips$del),]

# sb<-Sys.time()
# part3<-part3+sb-sa
# 
# predicted_trips <- predicted_trips %>% 
#   group_by(hullnum2,date) %>%
#   filter(prhat == max(prhat)) 
# 
# 
# #Not sure where to put hhat right now, probably overwrite hhat in production_dataset.  
# 
# save(predicted_trips, file=file.path(savepath, "trips_combined.RData"))

