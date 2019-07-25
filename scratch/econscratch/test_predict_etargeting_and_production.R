# some code to test "get_predict_etargeting.R" and "get_predict_eproduction.R" makes more sense to test them here, because there's some overhead from loading stuff.

# empty the environment
rm(list=ls())
set.seed(2) 

source('processes/runSetup.R')

econsavepath <- 'scratch/econscratch'
############################################################
############################################################
# Pull in temporary dataset that contains economic data clean them up a little (this is temporary cleaning, so it belongs here)
############################################################
############################################################

load(file.path(econsavepath,"temp_biop.RData"))


datapath <- 'data/data_processed/econ'
savepath<-'scratch/econscratch'
targeting_dataset<-readRDS(file.path(datapath,"full_targeting.Rds"))





#data wrangling on test datasets  -- once you have a full set of coefficients, you should be able to delete this.
tds<-as.data.table(targeting_dataset)
#end data wrangling on test dataset



part3<-0
sa<-Sys.time()

#code to test function. Remove when done.
predicted_trips<-get_predict_etargeting(tds)
#targeting_dataset<-cbind(phat,targeting_dataset)

predicted_trips$del<-predicted_trips$prhat-predicted_trips$pr
summary(predicted_trips$del)




#code to test function. Remove when done.
tds<-get_predict_eproduction(tds)



#here, subset prod_ds to just contain the cols in mysubs
#then try to rerun the get_predict_eproduction on that and see if it works

tds$delta<-tds$harvest_sim-tds$h_hat
summary(tds$delta)

#We see maximum differences of magnitude 0.08 (7 hundredths of a pound), which is probably due to rounding differences. 
#I think stata will use quad precision internally, but only export in double precisions.  This is NBD.








#We see maximum differences of magnitude .001 (A tenth of 1%), which is probably due to rounding differences.  I think stata will use quad precision internally, but only export in double precisions.  This is NBD.
# 
# predicted_trips <- predicted_trips %>%
#   select(xb,prhat, pr, del, spstock2, exp_rev_total, das_charge, fuelprice_distance, distance, mean_wind, mean_wind_noreast, permitted, lapermit ,partial_closure ,start_of_season, wkly_crew_wage, len, fuelprice, fuelprice_len, everything())
#  
# predicted_trips<-predicted_trips[order(-predicted_trips$del),]

# sb<-Sys.time()
# part3<-part3+sb-sa
# 
# predicted_trips <- predicted_trips %>% 
#   group_by(hullnum,date) %>%
#   filter(prhat == max(prhat)) 
# 
# 
# #Not sure where to put hhat right now, probably overwrite hhat in production_dataset.  
# 
# saveRDS(predicted_trips, file=file.path(savepath, "trips_combined.Rds"))

