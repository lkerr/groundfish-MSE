
# empty the environment
rm(list=ls())
set.seed(2) 

source('processes/runSetup.R')
library(microbenchmark)
#library(Rcpp)
econsavepath <- 'scratch/econscratch'
############################################################
############################################################
# Pull in temporary dataset that contains economic data clean them up a little (this is temporary cleaning, so it belongs here)
############################################################
############################################################

load(file.path(econsavepath,"temp_biop.RData"))


fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea")]
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

revenue_holder<-as.list(NULL)



subset<-0 
eproduction<-0
eproduction2<-0
prep_target_join<-0
prep_target_dc<-0
etargeting<-0
zero_out<-0
randomdraw<-0
holder_update_flatten <-0
next_period_flatten2 <-0
runtime<-0
holder_update_flatten2<-0
loop_start<-proc.time()
revenue_holder<-as.list(NULL)


for (day in 1:100){
  #   subset both the targeting and production datasets based on date and jams them to data.tables
  start_time<-proc.time()
  # Subset for the day.  Predict targeting
  working_targeting<-targeting_dataset[[day]]
  working_targeting<-get_predict_eproduction(working_targeting)
  eproduction2<-eproduction2+proc.time()[3]-start_time[3]
  
  
  start_time<-proc.time()
  #This bit needs to be replaced with a function that handles the "jointness"
  #expected revenue from this species
  working_targeting$exp_rev_total<- working_targeting$harvest_sim*working_targeting$price_lb_lag1*working_targeting$landing_multiplier_dollars
  
  #use the revenue multiplier to construct total revenue for this trip.
  #This bit needs to be replaced with a function that handles the "jointness"
  
  prep_target_dc<-prep_target_dc+proc.time()[3]-start_time[3]
  
  
  
  start_time<-proc.time() 
  trips<-get_predict_etargeting(working_targeting)
  etargeting<-etargeting+proc.time()[3]-start_time[3]
  
  
  # Predict targeting
  # this is where infeasible trips should be eliminated.
  start_time<-proc.time() 
  # IF ALL fishery_holder$open=TRUE, we can skip the zero_out_closed_asc step
  trips<-zero_out_closed_asc_cutout(trips,fishery_holder)
  zero_out<-zero_out+proc.time()[3]-start_time[3]
  
  ################################################################################################
  #  OBSOLETE!
  #  Keep the "best trip"  -- sort on id and prhat. then keep the id with the largest prhat.
  #  trips<-get_best_trip(trips)
  #  OBSOLETE!
  ################################################################################################
  
  # draw trips probabilistically.  A trip is selected randomly from the choice set. 
  # The probability of selection is equal to prhat
  start_time<-proc.time() 
  trips<-get_random_draw_tripsDT(trips)
  randomdraw<-randomdraw+proc.time()[3]-start_time[3]
  
  
  
  ####################################################################################################
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  #   Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  #   Pull out daily catch, rename the catch colum, and rbind to the holder. aggregate to update cumulative catch 
  ####################################################################################################
  # update the fishery holder dataframe
  
  start_time<-proc.time() 
  daily_catch<- trips[, c("spstock2","harvest_sim", "targeted")]
  colnames(daily_catch)[2]<-"cumul_catch_pounds"
  daily_catch<-rbind(daily_catch,fishery_holder[, c("spstock2","cumul_catch_pounds","targeted")])
  
  #DT style
  daily_catch<-daily_catch[,.(cumul_catch_pounds = sum(cumul_catch_pounds), targeted = sum(targeted)),by=spstock2]
  setorder(daily_catch,spstock2)
  setorder(fishery_holder,spstock2)
  nrow(daily_catch)==nrow(fishery_holder)
  
  
  fishery_holder<-get_fishery_next_period(daily_catch,fishery_holder)
  holder_update_flatten<-holder_update_flatten+proc.time()[3]-start_time[3]
  
  ####################################################################################################
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  # Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  
  
  #   add up today's revenue across the vessels (not necessary right now, but we end up with 'long' dataset of revenue)  
  # revenue<- trips %>% 
  #   group_by(hullnum) %>% 
  #   summarise(totalrev=sum(exp_rev_total))
  
  # revenue<-trips[c("hullnum","spstock2","exp_rev_total")]
  
  start_time<-proc.time() 
  revenue_holder[[day]]<-trips[, c("hullnum","spstock2","date","exp_rev_total")]
  next_period_flatten2<-next_period_flatten2+proc.time()[3]-start_time[3]
  
}


# This is a rewrite of get_fishery_next_period()
# we want to do
#For the mults_allocated stocks, we need:
#  If any unit stocks are closed, everything is closed
#If any SNEMA stocks are closed, all snema are closed
#If any GB are closed all gb are closed
#if YTF in CCGOM is closed, then 



new_get_fishery_next_period <- function(dc,fh){
  fh$cumul_catch_pounds<-dc$cumul_catch_pounds
  fh$targeted<-dc$targeted
  
  fh$sectorACL_pounds<-fh$sectorACL*pounds_per_kg*kg_per_mt
  fh$open<-fh$cumul_catch<fh$sectorACL_pounds
  
  #split into allocated and non-allocated
  z0<-fh[which(fh$mults_allocated==0)]
  z0$stockarea_closed<-as.logical(FALSE)
   
  fh<-fh[which(fh$mults_allocated==1)]
  
  num_closed<-sum(fh$open==FALSE)
  if (num_closed==0){
    fh$stockarea_closed<-as.logical(FALSE)
    # If nothing is closed, just return fh
  }
  else{
    
    #it's easer to check if "any" stock in an area is closed than it is to check that ALL stocks are open.
    # so we'll do that, then "flip" it over to a new open variable.
    fh<-fh[,stockarea_closed :=(sum(open==FALSE))>0, by=list(mults_allocated,stockarea)]
    
    unit_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="Unit"))
    gb_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="GB"))
    gom_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="GOM"))
    snema_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="SNEMA"))
    ccgom_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="CCGOM"))
    
    
    if (unit_check>=1){
      fh$stockarea_closed=TRUE 
    } else{
      
      if (gb_check>=1 & gom_check>=1){
        fh$stockarea_closed[which(fh$stockarea=="CCGOM")]=TRUE 
        snema_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="SNEMA"))
      }
    }
  }  
  
  #reassemble
  fh<-rbind(fh,z0)
  fh$stockarea_open=!fh$stockarea_closed
  fh[,stockarea_closed:=NULL]

  #fh<-as.data.table(fh)
  return(fh)
}



microbenchmark(ans_sq<-get_fishery_next_period(daily_catch, fishery_holder), ans_new<-get_fishery_next_period(daily_catch, fishery_holder), times=1000)
# 

