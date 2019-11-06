# This code runs the economic module.
# It is essentially an alternate to the "get_implementationF" function.  
# It takes in 
#   Values from the stock dynamics models 
#   Data from the econometric models
#   
# And outputs F_full for each modeled stock and a dataset of daily targeting  outcomes
  

############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 

### Probably need to add the trawl survey (trawlsurvey) index here and then push over trawl survey values into the targeting dataset.  But you might do that in outside this function.
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea")]
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

#set up a list to hold the expected revenue by date, hullnum, and target spstock2
revenue_holder<-as.list(NULL)



############################################################
############################################################
# BEGIN ECON MODULE 
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




for (day in 1:365){
  #   subset both the targeting and production datasets based on date and jams them to data.tables
  # Subset for the day.  Predict targeting
  working_targeting<-targeting_dataset[[day]]
  working_targeting<-get_predict_eproduction(working_targeting)
  
  
  
  
  #This bit needs to be replaced with a function that handles the "jointness"
  #expected revenue from this species
  working_targeting$exp_rev_total<- working_targeting$harvest_sim*working_targeting$price_lb_lag1*working_targeting$landing_multiplier_dollars
  
  #use the revenue multiplier to construct total revenue for this trip.
  #This bit needs to be replaced with a function that handles the "jointness"
  
  
  
  
  trips<-get_predict_etargeting(working_targeting)
  
  
  # Predict targeting
  # this is where infeasible trips should be eliminated.

  trips<-zero_out_closed_asc_cutout(trips,fishery_holder)
  
  ################################################################################################
  #  OBSOLETE!
  #  Keep the "best trip"  -- sort on id and prhat. then keep the id with the largest prhat.
  #  trips<-get_best_trip(trips)
  #  OBSOLETE!
  ################################################################################################
  
  # draw trips probabilistically.  A trip is selected randomly from the choice set. 
  # The probability of selection is equal to prhat
  trips<-get_random_draw_tripsDT(trips)
  
  
  
  ####################################################################################################
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  #   Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  #   Pull out daily catch, rename the catch colum, and rbind to the holder. aggregate to update cumulative catch 
  ####################################################################################################
  # update the fishery holder dataframe
  
  
  daily_catch<- trips[, c("spstock2","harvest_sim", "targeted")]
  colnames(daily_catch)[2]<-"cumul_catch_pounds"
  daily_catch<-rbind(daily_catch,fishery_holder[, c("spstock2","cumul_catch_pounds","targeted")])
  
  #DT style
  daily_catch<-daily_catch[,.(cumul_catch_pounds = sum(cumul_catch_pounds), targeted = sum(targeted)),by=spstock2]
  setorder(daily_catch,spstock2)
  setorder(fishery_holder,spstock2)
  nrow(daily_catch)==nrow(fishery_holder)
  fishery_holder<-get_fishery_next_period(daily_catch,fishery_holder)
  
  ####################################################################################################
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  # Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  
  
  # save the hullnum, target spstock2, date, expected revenue, and targeted to a list
  revenue_holder[[day]]<-trips[, c("hullnum","spstock2","date","exp_rev_total","targeted")]
  
}

fishery_holder$removals_mt<-fishery_holder$cumul_catch_pounds/(pounds_per_kg*kg_per_mt)+fishery_holder$nonsector_catch_mt
 
#contract that list down to a single data.table
  revenue_holder<-rbindlist(revenue_holder) 
  revenue_holder$r<-r
  revenue_holder$m<-m
  revenue_holder$y<-y
# We probably want to contract this down further to a data.table of "hullnum","spstock2","exp_rev_total","targeted"
  
  
  
#subset fishery_holder to have just things that have a biological model. send it to a list?
bio_output<-fishery_holder[which(fishery_holder$bio_model==1),]



# Put catch (mt) into the stock list, then compute F_full
for(i in 1:nstock){
  stock[[i]]$econCW[y]<-bio_output$removals_mt[bio_output$stocklist_index==i]

    stock[[i]]<-within(stock[[i]], {
    F_full[y]<- get_F(econCW[y],J1N[y,],slxC[y,],M,waa[y,])
  }) 
}


