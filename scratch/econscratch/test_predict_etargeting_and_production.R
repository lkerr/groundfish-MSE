# some code to test "get_predict_etargeting.R" and "get_predict_eproduction.R" makes more sense to test them here, because there's some overhead from loading stuff.

# something is broken -- verify primary==1 and secondary==0?  Check if things work for choice==1

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

#load(file.path(econsavepath,"temp_biop.RData"))


datapath <- 'data/data_processed/econ'
savepath<-'scratch/econscratch'
#targeting_dataset<-readRDS(file.path(datapath,"full_targeting.Rds"))

tds<-targeting_dataset[[1]]
is.data.table(tds)
# prODUCTION SHOULD WORK.
#code to test function. Remove when done.
tds<-get_predict_eproduction(tds)

#here, subset prod_ds to just contain the cols in mysubs
#then try to rerun the get_predict_eproduction on that and see if it works

tds$harvest_sim[tds$spstock2=="nofish"]<-0
tds$delta<-abs(tds$harvest_sim-tds$h_hat)

summary(tds$delta)
#Works well!  
#setcolorder(tds,c("spstock2","delta","harvest_sim","h_hat"))
#setorder(tds,-delta)

#here, you can summary if choice==0 or choice==1
#tdss<-tds[which(tds$choice==1)]
#summary(tdss$delta)

#data wrangling on test datasets  -- once you have a full set of coefficients, you should be able to delete this
tds<-targeting_dataset
#end data wrangling on test dataset. lol no so much wrangling.



part3<-0
sa<-Sys.time()

#code to test function. Remove when done.
predicted_trips<-get_predict_etargeting(tds)
#targeting_dataset<-cbind(phat,targeting_dataset)

predicted_trips[, del:=prhat-pr]
summary(predicted_trips$del)

setcolorder(predicted_trips,c("prhat", "pr", "del", "xb"))
fy9<-predicted_trips[which(predicted_trips$gffishingyear==2009)]
summary(fy9$del)

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

