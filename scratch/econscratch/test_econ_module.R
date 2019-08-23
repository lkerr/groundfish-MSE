# some code to run the economic module.
# This code will eventually take in the catch limits, by stock, and either biomass  


############################################################
#Preamble stuff that is contained in other places.
#load in functions
#set class to not HPCC
#load libraries
#declare some paths to read and save things that I'm scratchpadding
############################################################

# you ran runSim.R and save the bio parameters here
# econsavepath <- 'scratch/econscratch'
# save(bio_params_for_econ,file=file.path(econsavepath,"temp_biop.RData"))

#rm(list=ls())

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
#make sure there is a nofish in bio_params_for_econ

#scratchdir<-"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/scratch/econscratch"
#Rcpp::sourceCpp(file.path(scratchdir,"matsums.cpp"))
m<-1
econtype<-mproc[m,]
myvars<-c("LandZero","CatchZero","EconType")
econtype<-econtype[myvars]
############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

revenue_holder<-as.list(NULL)

##########################################################################################
##############SOME CODE TO SET ACLS low to verify closing works###########################
#here's a couple lines to quickly set underACL to "FALSE", stockarea_open to FALSE
# fishery_holder$underACL[3]<-as.logical("FALSE")
# fishery_holder$stockarea_open[fishery_holder$stockarea=="GB"] <-as.logical("FALSE")

#Set the sectorACLS for lobster, plaice, codGB, codGOM, halibut, winterSNEMA, yellowtail CCGOM to a small number
#This is a non-mult, unit stock, GB stock, GOM stock, non-allocated, SNEMA, and CCGOM stock.
# fishery_holder$sectorACL[1]<-100
# fishery_holder$sectorACL[2]<-100
# fishery_holder$sectorACL[3]<-100
# fishery_holder$sectorACL[4]<-100
# fishery_holder$sectorACL[7]<-100
# fishery_holder$sectorACL[25]<-100
# fishery_holder$sectorACL[28]<-100
##########################################################################################
##########################################################################################

# It may be faster to change the way this model runs.  Currently, it's day-by-day and the ACLs are checked at
# the end of each day (to shut the fishery down).
# It may be better to 
#  predict for the entire year at the same time, generate a "cumulative harvest" under "all open"
#  Find the date that the first quota binds, then predict from that point forward under "1 closed"
#  Repeat until you get to the end of the year or all quotas bind.

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

# z<-function(){
  set.seed(2)

  #source('processes/loadEcon.R')
  
  
   day<-30
  # test30<-targeting_dataset[[day]]
  
  #for (day in 1:365){
  #   subset the targeting dataset based on date 
  start_time<-proc.time()
  # Subset for the day.  Predict targeting
  working_targeting<-copy(targeting_dataset[[day]])
  get_predict_eproduction(working_targeting)

  eproduction2<-eproduction2+proc.time()[3]-start_time[3]
  
  #Right here is where we need to zero things out.
  #zero_out_targets will set the catch and landings multipliers to zero depending on the value of underACL, stockarea_open, and mproc$EconType
  zero_out_targets(working_targeting,fishery_holder, econtype)

  # working_targeting<-zero_out_nontargets(working_targeting,fishery_holder, econtype)


  
  
  
  start_time<-proc.time()
  #Update the dataset with expected revenue that accounts for jointness and quota costs
  working_targeting<-get_joint_production2(working_targeting,spstock2s) 
  working_targeting[, exp_rev_total:=exp_rev_total/1000]
  working_targeting[, wkly_crew_wage:=wkly_crew_wage/1000]
  

  prep_target_dc<-prep_target_dc+proc.time()[3]-start_time[3]
  
  
  
  start_time<-proc.time() 
  trips<-get_predict_etargeting(working_targeting)
  #setcolorder(trips,"xb","prhat")
  etargeting<-etargeting+proc.time()[3]-start_time[3]
  
  
  # Predict targeting
  # this is where infeasible trips should be eliminated.
  start_time<-proc.time() 
  zero_out_closed_asc_cutout(trips,fishery_holder)
  zero_out<-zero_out+proc.time()[3]-start_time[3]
  
  # draw trips probabilistically.  A trip is selected randomly from the choice set. 
  # The probability of selection is equal to prhat
  start_time<-proc.time() 
  trips<-get_random_draw_tripsDT(trips)
  randomdraw<-randomdraw+proc.time()[3]-start_time[3]
  
  catches<-get_reshape_catches(trips)
  landings<-get_reshape_landings(trips)

  #I don't think I need to do this.
  target_rev<-get_reshape_targets_revenues(trips)
  #I don't think I need to do this.
  
  
  ####################################################################################################
  # This will need to get restructured a bit -- catch and landings are now coming out of the c_ and l_ columns
  # Easy to contract/collapse these down, but then they have to get stripped of the c_ prefixes and reshaped wide.
  ####################################################################################################
  # update the fishery holder dataframe
  
  
  # left join landings into fishery_holder.  Replace fishery holder's cumul_catch_pounds=cumul_catch_pounds+daily_catch  remove daily_catch?  
  
  fishery_holder<-fishery_holder[catches, on="spstock2"]
  fishery_holder[, cumul_catch_pounds:= cumul_catch_pounds+daily_pounds_caught]
  fishery_holder[, daily_pounds_caught :=NULL]

  get_fishery_next_period_areaclose2(fishery_holder)
  
  
  # old way
  # daily_catch<- trips[, c("spstock2","harvest_sim", "targeted")]
  # colnames(daily_catch)[2]<-"cumul_catch_pounds"
  # daily_catch<-rbind(daily_catch,fishery_holder[, c("spstock2","cumul_catch_pounds","targeted")])
  # 
  # #DT style
  # daily_catch<-daily_catch[,.(cumul_catch_pounds = sum(cumul_catch_pounds), targeted = sum(targeted)),by=spstock2]
  # setorder(daily_catch,spstock2)
  # setorder(fishery_holder,spstock2)
  # nrow(daily_catch)==nrow(fishery_holder)
  # 
  # 
  # fishery_holder<-get_fishery_next_period_areaclose(daily_catch,fishery_holder)
  # holder_update_flatten<-holder_update_flatten+proc.time()[3]-start_time[3]

  ####################################################################################################
  # Expand from harvest of the target to harvest of all using the catch multiplier matrices
  # Not written yet.  Not sure if we need revenue by stock to be saved for each vessel? Or just catch? 
  
  
  #   add up today's revenue across the vessels (not necessary right now, but we end up with 'long' dataset of revenue)  
  # revenue<- trips %>% 
  #   group_by(hullnum) %>% 
  #   summarise(totalrev=sum(exp_rev_total))
  
  # revenue<-trips[c("hullnum","spstock2","exp_rev_total")]

  #Save expected, actual, target, catches, landings, and revenue.  
  start_time<-proc.time() 
  savelist<-c("hullnum","spstock2","date","exp_rev_total","actual_rev_total")
  mm<-c(grep("^c_",colnames(trips), value=TRUE),grep("^l_",colnames(trips), value=TRUE),grep("^r_",colnames(trips), value=TRUE))
  savelist=c(savelist,mm)
  revenue_holder[[day]]<-trips[, ..savelist]
  next_period_flatten2<-next_period_flatten2+proc.time()[3]-start_time[3]
  
}
# }
# 

  start_time<-proc.time() 
  revenue_holder<-rbindlist(revenue_holder) 
  next_period_flatten2<-next_period_flatten2+proc.time()[3]-start_time[3]
  
  
loop_end<-proc.time()

runtime<-loop_end[3]-loop_start[3]

subset
eproduction
eproduction2
prep_target_join
prep_target_dc
etargeting
zero_out
randomdraw
holder_update_flatten
holder_update_flatten2
next_period_flatten2
runtime




# 
# fishery_holder$removals_mt<-fishery_holder$cumul_catch_pounds/(pounds_per_kg*kg_per_mt)+fishery_holder$nonsector_catch_mt
# 
# #subset fishery_holder to have just things that have a biological model. send it to a list?
# bio_output<-fishery_holder[which(fishery_holder$bio_model==1),]
# 
# # Put catch (mt) into the stock list, then compute F_full
# for(i in 1:nstock){
#   stock[[i]]$econCW[y]<-bio_output$removals_mt[bio_output$stocklist_index==i]
# 
#     stock[[i]]<-within(stock[[i]], {
#     F_full[y]<- get_F(econCW[y],J1N[y,],slxC[y,],M,waa[y,])
#   }) 
# }
# 

