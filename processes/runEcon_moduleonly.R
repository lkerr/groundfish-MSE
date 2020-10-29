# This code is for running a standalone economic module.  There are a few differences from the standard "runEcon_module"
    #.  This does not produce an F.
    #.  We do not zero-out the "multipliers" for the closed stocks.

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
annual_revenue_holder<-list()

#set up a list to hold the date, spstock2, and aggregate metrics, like open/closed status and cumulative catch
annual_fishery_status_holder<-list()


#set up a list to hold the prhat by date, hullnum, and target spstock2
# This will be a pretty big list
annual_prhat_holder<-list()


#Initialize the most_recent_target data.table. 
#This could move to preprocessing; I'll need to set one up for the entire simulation dataset (all 6 years)
# You need to save it as a .RDS and then read.  And you need to figure out what to do with your merge statements In order to keep *all*
# most_recent_target<-readRDS()
if(y == fmyearIdx){
  keepcols<-c("hullnum","spstock2","OG_choice_prev_fish")
  most_recent_target<-copy(targeting_dataset[[1]])
  most_recent_target<-most_recent_target[, ..keepcols]
  most_recent_target<-most_recent_target[spstock2!="nofish"]
  most_recent_target<-most_recent_target[OG_choice_prev_fish==1]
  setnames(most_recent_target,"OG_choice_prev_fish","targeted")
  #You should write an assert type statment that most_recent_target has >=1 rows.
}

for (day in 1:365){
  
  # Subset for the day.  Add in production coeffients and construct some extra data.
  working_targeting<-copy(targeting_dataset[[day]])
  
  
  working_targeting<-get_predict_eproduction(working_targeting)

working_targeting[spstock2=="nofish", harvest_sim:=0L]
working_targeting [, harvest_sim:= ifelse(is.na(dl_primary), harvest_sim, ifelse(harvest_sim >= dl_primary, dl_primary, harvest_sim))]

# Uncomment this to use AB's existing h_hats
#  working_targeting[,harvest_sim :=h_hat]

# Update choice_prev_fish
    working_targeting[most_recent_target, choice_prev_fish:=targeted, on=c("hullnum","spstock2")]
    working_targeting[is.na(choice_prev_fish), choice_prev_fish := 0]
     
    # working_targeting$choice_prev_fish<-working_targeting$OG_choice_prev_fish
     
    #These functions will set the catch and landings multipliers to zero depending on the value of underACL, stockarea_open, and mproc$EconType


    working_targeting<-joint_adjust_allocated_mults(working_targeting,fishery_holder, econtype)
    working_targeting<-joint_adjust_others(working_targeting,fishery_holder, econtype)
    working_targeting<-get_joint_production(working_targeting,spstock2s) 
    
    # adjust for DAS costs.
    # subtract off das_costs from expected and actual  revenue.
    # The _das variable is computed exactly the same as the exp_rev_total variable. 
    # If necessary the DAS and/or QUOTA costs should be set to zero either in the data  
    working_targeting[, exp_rev_total:=exp_rev_total-das_cost]
    working_targeting[, actual_rev_total:=actual_rev_total-das_cost]

    working_targeting[spstock2=="nofish", exp_rev_total:=0L]
    working_targeting[spstock2=="nofish", actual_rev_total:=0L]
    
    #rescale
    working_targeting[, exp_rev_total:=exp_rev_total/1000]
    working_targeting[, actual_rev_total:=actual_rev_total/1000]
    #fill the _das variables
    working_targeting[, exp_rev_total_das:=exp_rev_total]
    working_targeting[, actual_rev_total_das:=actual_rev_total]
    
    

    
  # Predict targeting
  trips<-get_predict_etargeting(working_targeting)
    
    # Predict targeting
    # this is where infeasible trips should be eliminated.
    
     trips<-zero_out_closed_areas_asc_cutout(trips,fishery_holder)
  

     pr_savelist<-c("hullnum","spstock2","doffy","prhat")
     
    # This takes a subset of the trips data.table and reshapes it wide 
     annual_prhat_holder[[day]]<-dcast(trips[,..pr_savelist],hullnum + doffy ~ spstock2, value.var="prhat")
     
     
     
  # draw trips probabilistically.  A trip is selected randomly from the choice set. 
  # The probability of selection is equal to prhat
    trips<-get_random_draw_tripsDT(trips)
  #drop out trip that did not fish (they have no landings or catch). 
    #trips<-trips[spstock2!="nofish"]
    
    
    
    catches<-get_reshape_catches(trips)
    landings<-get_reshape_landings(trips)
    
    #I don't think I need to do this.
    #target_rev<-get_reshape_targets_revenues(trips)
    #I don't think I need to do this.
  
  
  # update the fishery holder dataframe
  
  
  # left join landings into fishery_holder.  Replace fishery holder's cumul_catch_pounds=cumul_catch_pounds+daily_catch  remove daily_catch?  
  
  fishery_holder<-fishery_holder[catches, on="spstock2"]
  fishery_holder[, cumul_catch_pounds:= cumul_catch_pounds+daily_pounds_caught]
  fishery_holder[, daily_pounds_caught :=NULL]

  fishery_holder<-get_fishery_next_period_areaclose(fishery_holder)
  savelist<-c("id","hullnum","spstock2","doffy","exp_rev_total","exp_rev_total_das","actual_rev_total", "gearcat")
  savelist<-c("id","hullnum","spstock2","doffy","exp_rev_total","exp_rev_total_das", "actual_rev_total", "gearcat","choice_prev_fish","OG_choice_prev_fish")
  
  mm<-c(grep("^c_",colnames(trips), value=TRUE),grep("^l_",colnames(trips), value=TRUE),grep("^r_",colnames(trips), value=TRUE))
  savelist=c(savelist,mm)
  # Save the trip-level and fishery level metrics to the appropriate places
  annual_revenue_holder[[day]]<-trips[, ..savelist]
  
  
  savelist2<-c("spstock2","sectorACL","bio_model","SSB","mults_allocated", "stockarea","underACL", "stockarea_open","cumul_catch_pounds", "sectorACL_pounds")
  
  annual_fishery_status_holder[[day]]<-fishery_holder[,..savelist2]
  annual_fishery_status_holder[[day]]$doffy<-day
  
  # prepare the trips data.table for the next iteration
  trips<-trips[, c("spstock2","hullnum", "targeted","choice_prev_fish","OG_choice_prev_fish")]
 
  #merge in the previous value of choice_prev_fished
  trips<-merge(trips,most_recent_target, by=c("hullnum","targeted"), all=TRUE, suffixes=c("T","MRT"))
  #overwrite with the previous the target stock is no_fish
  most_recent_target<-copy(trips)
  
  
  setnames(most_recent_target,"spstock2T","spstock2", skip_absent=TRUE)
  most_recent_target[spstock2=="nofish", spstock2 :=spstock2MRT]
  most_recent_target[is.na(spstock2), spstock2 :=spstock2MRT]
  
  
  keepcols<-c("hullnum","spstock2","targeted")
  most_recent_target<-most_recent_target[, ..keepcols]

}

  fishery_holder[, removals_mt:=cumul_catch_pounds/(pounds_per_kg*kg_per_mt)+nonsector_catch_mt]
#contract the trip-level list down to a single data.table 
  annual_revenue_holder<-rbindlist(annual_revenue_holder) 

  annual_revenue_holder$r<-r
  annual_revenue_holder$m<-model
  annual_revenue_holder$y<-y
  annual_revenue_holder$year<-yrs[y]
  #perhaps
  # annual_revenue_holder<-c(annual_revenue_holder,econtype)
  
  revenue_holder[[yearitercounter]]<-annual_revenue_holder
  
  rm(annual_revenue_holder)

  #contract the fishery-level list down to a single data.table
  annual_fishery_status_holder<- rbindlist(annual_fishery_status_holder) 
  annual_fishery_status_holder$r<-r
  annual_fishery_status_holder$m<-model
  annual_fishery_status_holder$y<-y
  annual_fishery_status_holder$year<-yrs[y]
  
  #perhaps
  # annual_fishery_status_holder<-c(annual_fishery_status_holder,econtype)
  fishery_output_holder[[yearitercounter]]<-annual_fishery_status_holder
  rm(annual_fishery_status_holder)
  
  
  
  
  
  #contract the fishery-level list down to a single data.table
  annual_prhat_holder<- rbindlist(annual_prhat_holder,use.names=TRUE,fill=TRUE) 
  annual_prhat_holder$r<-r
  annual_prhat_holder$m<-model
  annual_prhat_holder$y<-y
  annual_prhat_holder$year<-yrs[y]
  
  #perhaps
  # annual_fishery_status_holder<-c(annual_fishery_status_holder,econtype)
  fishery_prhat_holder[[yearitercounter]]<-annual_prhat_holder
  rm(annual_prhat_holder)
  
  
  
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


