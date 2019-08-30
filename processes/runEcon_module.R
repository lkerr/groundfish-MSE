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

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

#set up a list to hold the expected revenue by date, hullnum, and target spstock2
revenue_holder<-as.list(NULL)
  #Initialize the trips data.table. I need it to store the previous choice.
  keepcols<-c("hullnum","spstock2","choice_prev_fish")
  trips<-copy(targeting_dataset[[1]])
  trips<-trips[, ..keepcols]
  trips<-trips[spstock2!="nofish"]
  colnames(trips)[3]<-"targeted"



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

  # Subset for the day.  Add in production coeffients and construct some extra data.

working_targeting<-targeting_dataset[doffy==day]
working_targeting<-copy(working_targeting)

# bring in production coefficients
working_targeting<-production_coefs[working_targeting, on=c("spstock2","gearcat","post")]

# Construct Primary and Secondary
set(working_targeting,i=NULL, j="primary",as.integer(1))
set(working_targeting,i=NULL, j="secondary",as.integer(0))
set(working_targeting,i=NULL, j="constant",as.integer(1))

# Construct Month and Year
df2<-dcast(working_targeting,  id +spstock2 ~ gffishingyear , fun.aggregate = function(x) 1L, fill=0L,value.var = "gffishingyear")
df2[,c("id","spstock2"):=NULL]
colnames(df2)<-paste0("fy", colnames(df2))

df3<-dcast(working_targeting,  id +spstock2 ~ MONTH, fun.aggregate = function(x) 1L, fill=0L,value.var = "MONTH")
df3[,c("id","spstock2"):=NULL]
colnames(df3)<-paste0("month", colnames(df3))

working_targeting<-cbind(working_targeting,df2, df3)
  
  
  
  
working_targeting<-get_predict_eproduction(working_targeting)
working_targeting$harvest_sim[working_targeting$spstock2=="nofish"]<-0
# Drop unnecessary columns 
dropper<-grep("^alpha_",colnames(working_targeting), value=TRUE)
working_targeting[, (dropper):=NULL]

# Pull in multipliers 


working_targeting<-wm[working_targeting, on=c("hullnum","MONTH","spstock2","gffishingyear","post")]

# Pull in output prices
working_targeting<-wo[working_targeting, on=c("doffy","gffishingyear", "post")]

# Pull in input prices
working_targeting<-wi[working_targeting, on=c("hullnum","doffy","spstock2","gffishingyear","post")]

  
  
  
    working_targeting[, choice_prev_fish:=0]
    working_targeting<-working_targeting[trips, choice_prev_fish:=targeted , on=c("hullnum","spstock2")]
    
    
    
    #zero_out_targets will set the catch and landings multipliers to zero depending on the value of underACL, stockarea_open, and mproc$EconType
    
    working_targeting<-joint_adjust_allocated_mults(working_targeting,fishery_holder, econtype)
    working_targeting<-joint_adjust_others(working_targeting,fishery_holder, econtype)
    working_targeting<-get_joint_production(working_targeting,spstock2s) 
    working_targeting[, exp_rev_total:=exp_rev_total/1000]
working_targeting$exp_rev_total[working_targeting$spstock2=="nofish"]<-0

working_targeting[, fuelprice_len:=fuelprice*len]
working_targeting[, fuelprice_distance:=fuelprice*distance]
working_targeting<-targeting_coefs[working_targeting, on=c("gearcat","spstock2")]
    
    # Predict targeting
    trips<-get_predict_etargeting(working_targeting)
    
    # Predict targeting
    # this is where infeasible trips should be eliminated.
    
    trips<-zero_out_closed_areas_asc_cutout(trips,fishery_holder)
    
    # draw trips probabilistically.  A trip is selected randomly from the choice set. 
    # The probability of selection is equal to prhat
    trips<-get_random_draw_tripsDT(trips)
    #drop out trip that did not fish (they have no landings or catch). 
    trips<-trips[spstock2!="nofish"]
    
    catches<-get_reshape_catches(trips)
    landings<-get_reshape_landings(trips)
    
    #I don't think I need to do this.
    target_rev<-get_reshape_targets_revenues(trips)
    #I don't think I need to do this.
  
  
  # update the fishery holder dataframe
  
  
  # left join landings into fishery_holder.  Replace fishery holder's cumul_catch_pounds=cumul_catch_pounds+daily_catch  remove daily_catch?  
  
  fishery_holder<-fishery_holder[catches, on="spstock2"]
  fishery_holder[, cumul_catch_pounds:= cumul_catch_pounds+daily_pounds_caught]
  fishery_holder[, daily_pounds_caught :=NULL]

  fishery_holder<-get_fishery_next_period_areaclose(fishery_holder)
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  # Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  savelist<-c("hullnum","spstock2","date","exp_rev_total","actual_rev_total")
  mm<-c(grep("^c_",colnames(trips), value=TRUE),grep("^l_",colnames(trips), value=TRUE),grep("^r_",colnames(trips), value=TRUE))
  savelist=c(savelist,mm)
  revenue_holder[[day]]<-trips[, ..savelist]
  
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


