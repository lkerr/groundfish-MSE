# This code is just the counterfactual economic module.  There are a few differences from the standard "runEcon_module"
    #.  This does not produce an F.
    #.  We do not zero-out the "multipliers" for the closed stocks.
    #.  We do not 

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

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

#set up a list to hold the expected revenue by date, hullnum, and target spstock2
annual_revenue_holder<-as.list(NULL)

#Initialize the trips data.table. 
  if(y == fmyearIdx){
  keepcols<-c("hullnum","spstock2","choice_prev_fish")
  trips<-copy(targeting_dataset[[1]])
  trips<-trips[, ..keepcols]
  trips<-trips[spstock2!="nofish"]
  colnames(trips)[3]<-"targeted"
  trips<-trips[targeted==1]
  
  }

for (day in 1:365){
  
  # Subset for the day.  Add in production coeffients and construct some extra data.
working_targeting<-copy(targeting_dataset[[day]])
working_targeting<-get_predict_eproduction(working_targeting)
working_targeting[.("nofish"), on=c("spstock2"), harvest_sim:=0]


    # Keep or update choice_prev_fish
     working_targeting[trips, `:=` (tx2=targeted, tx=targeted) , on=c("hullnum","spstock2")]
     
     working_targeting[is.na(tx2), tx2 := 0]     
     working_targeting[is.na(tx), tx := choice_prev_fish]     
     working_targeting[, ttx := sum(tx),by=id]
     working_targeting[ttx>=2, tx := tx2]
     working_targeting[, choice_prev_fish :=tx]
     
     dropcol<-c('ttx', 'tx2', 'tx')
     working_targeting[, (dropcol) := NULL]
     
     
    #zero_out_targets will set the catch and landings multipliers to zero depending on the value of underACL, stockarea_open, and mproc$EconType


    #working_targeting<-joint_adjust_allocated_mults(working_targeting,fishery_holder, econtype)
    #working_targeting<-joint_adjust_others(working_targeting,fishery_holder, econtype)
    working_targeting<-get_joint_production(working_targeting,spstock2s) 
    working_targeting[, exp_rev_total:=exp_rev_total/1000]
    working_targeting[, actual_rev_total:=actual_rev_total/1000]
    
    working_targeting[.("nofish"), on=c("spstock2"), exp_rev_total:=0]
    
    
    # Predict targeting
  trips<-get_predict_etargeting(working_targeting)
    
    # Predict targeting
    # this is where infeasible trips should be eliminated.
    
    # trips<-zero_out_closed_areas_asc_cutout(trips,fishery_holder)
  
  # draw trips probabilistically.  A trip is selected randomly from the choice set. 
  # The probability of selection is equal to prhat
    trips<-get_random_draw_tripsDT(trips)
  #drop out trip that did not fish (they have no landings or catch). 

    catches<-get_reshape_catches(trips)
    landings<-get_reshape_landings(trips)
    
    #I don't think I need to do this.
    #target_rev<-get_reshape_targets_revenues(trips)
    #I don't think I need to do this.
  
  
  # update the fishery holder dataframe
  
  fishery_holder<-fishery_holder[catches, on="spstock2"]
  fishery_holder[, cumul_catch_pounds:= cumul_catch_pounds+daily_pounds_caught]
  fishery_holder[, daily_pounds_caught :=NULL]

  #This could probably be commented out, but we can leave it in for now.
  fishery_holder<-get_fishery_next_period_areaclose(fishery_holder)

  savelist<-c("id","hullnum","spstock2","doffy","exp_rev_total","actual_rev_total", "gearcat")
  savelist<-c("id","hullnum","spstock2","doffy","exp_rev_total","actual_rev_total", "gearcat","choice_prev_fish")
  mm<-c(grep("^c_",colnames(trips), value=TRUE),grep("^l_",colnames(trips), value=TRUE),grep("^r_",colnames(trips), value=TRUE))
  savelist=c(savelist,mm)
  annual_revenue_holder[[day]]<-trips[, ..savelist]

  trips<-trips[spstock2!="nofish"]
  trips<-trips[, c("spstock2","hullnum", "targeted")]
    
}

  fishery_holder[, removals_mt:=cumul_catch_pounds/(pounds_per_kg*kg_per_mt)+nonsector_catch_mt]
 
#contract that list down to a single data.table
  annual_revenue_holder<-rbindlist(annual_revenue_holder) 
  annual_revenue_holder$r<-r
  annual_revenue_holder$m<-m
  annual_revenue_holder$y<-y
  revenue_holder[[eyear_idx]]<-annual_revenue_holder
  
  rm(annual_revenue_holder)
# We probably want to contract this down further to a data.table of "hullnum","spstock2","exp_rev_total","targeted"
  
  
#   
# #subset fishery_holder to have just things that have a biological model. send it to a list?
# bio_output<-fishery_holder[which(fishery_holder$bio_model==1),]
# 
# 
# 
# # Put catch (mt) into the stock list, then compute F_full
# for(i in 1:nstock){
#   stock[[i]]$econCW[y]<-bio_output$removals_mt[bio_output$stocklist_index==i]
# 
#     stock[[i]]<-within(stock[[i]], {
#     F_full[y]<- get_F(econCW[y],J1N[y,],slxC[y,],M,waa[y,])
#   }) 
# }


