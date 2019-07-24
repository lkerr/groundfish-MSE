# some code to run the economic module.
# This code will eventually take in the catch limits, by stock, and either biomass  


############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea")]
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0

revenue_holder<-as.data.table(NULL)



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




for (day in 1:365){
  #   subset both the targeting and production datasets based on date and jams them to data.tables
  
  working_production<-data.table(production_dataset[[day]])
  working_targeting<-data.table(targeting_dataset[[day]])
  
  ###################################
  #   overwrite cumulative harvest and log cumulative catch of each stock. This was needed for getting cumulative harvest back into the production functions. we're not doing that anymore.
  # working_production<-left_join(working_production,fishery_holder, by="spstock2")
  # working_production$h_cumul<-working_production$cumul_catch_pounds
  # working_production$logh_cumul<-log(working_production$cumul_catch_pounds)
  ###################################
  
  # predict_eproduction: predict harvest of each stock by each vessel condition on targeting that stock.  Also predict revenue from that stock, and all revenue.  keep just 5 columns: hullnum2, date, spstock as key variables.  harvest, revenue, and expected revenue as columns that I care about. 
  
  production_outputs<-get_predict_eproduction(working_production)
  
  
  
  #This bit needs to be replaced with a function that handles the "jointness"
  #expected revenue from this species
  production_outputs$exp_rev_sim<- production_outputs$harvest_sim*production_outputs$price_lb_lag1
  production_outputs$exp_rev_total_sim<- production_outputs$harvest_sim*production_outputs$price_lb_lag1*production_outputs$multiplier
  
  #use the revenue multiplier to construct total revenue for this trip.
  #This bit needs to be replaced with a function that handles the "jointness"
  
  
     
  #   use those three key variables to merge-update harvest, revenue, and expected revenue in the targeting dataset
  joincols<-c("hullnum2","date", "spstock2")
  working_targeting<-as.data.table(left_join(working_targeting,production_outputs, by=joincols))
  
  
  #fill exp_rev_sim, exp_rev_total_sim, harvest_sim=0 for the nofish options
  working_targeting$exp_rev_sim[is.na(working_targeting$exp_rev_sim)]<-0
  working_targeting$exp_rev_total_sim[is.na(working_targeting$exp_rev_total_sim)]<-0
  working_targeting$harvest_sim[is.na(working_targeting$harvest_sim)]<-0
  
  #overwrite the values of the exp_rev_total, exp_rev, and harvest in the targeting dataset.
   working_targeting$exp_rev<-working_targeting$exp_rev_sim
   working_targeting$exp_rev_total<-working_targeting$exp_rev_total_sim
   working_targeting$h_hat<-working_targeting$harvest_sim

   
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
  
  
  daily_catch<- trips[, c("spstock2","h_hat")]
  colnames(daily_catch)[2]<-"cumul_catch_pounds"
  daily_catch<-rbind(daily_catch,fishery_holder[, c("spstock2","cumul_catch_pounds")])

  #DT style
  daily_catch<-daily_catch[,.(cumul_catch_pounds = sum(cumul_catch_pounds)),by=spstock2]
  
  #daily_catch<- daily_catch %>% 
  #  group_by(spstock2) %>% 
  #  summarise(cumul_catch_pounds=sum(cumul_catch_pounds))
  
  fishery_holder<-get_fishery_next_period(daily_catch,fishery_holder)
  
  ####################################################################################################
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  # Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  
  
  #   add up today's revenue across the vessels (not necessary right now, but we end up with 'long' dataset of revenue)  
  # revenue<- trips %>% 
  #   group_by(hullnum2) %>% 
  #   summarise(totalrev=sum(exp_rev_total))
  
  # revenue<-trips[c("hullnum2","spstock2","exp_rev_total")]
  # revenue_holder<-rbind(revenue_holder,revenue)
  
  revenue_holder<-rbind(revenue_holder,trips[, c("hullnum2","spstock2","date","exp_rev_total")])
}

fishery_holder$removals_mt<-fishery_holder$cumul_catch_pounds/(pounds_per_kg*kg_per_mt)+fishery_holder$nonsector_catch_mt

#subset fishery_holder to have just things that have a biological model. send it to a list?
bio_output<-fishery_holder[which(fishery_holder$bio_model==1),]



# Put catch (mt) into the stock list, then compute F_full
for(i in 1:nstock){
  stock[[i]]$econCW[y]<-bio_output$removals_mt[bio_output$stocklist_index==i]

    stock[[i]]<-within(stock[[i]], {
    F_full[y]<- getF(econCW[y],J1N[y,],slxC[y,],M,waa[y,])
  }) 
}


