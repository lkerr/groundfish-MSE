#load in targeting data

#rm(list=ls())
# set.seed(2) 

# empty the environment
rm(list=ls())

source('processes/runSetup.R')
source('processes/loadEcon.R')

library(data.table)


library(microbenchmark)

econsavepath <- 'scratch/econscratch'
############################################################
############################################################
# Pull in temporary dataset that contains economic data clean them up a little (this is temporary cleaning, so it belongs here)
############################################################
############################################################

load(file.path(econsavepath,"temp_biop.RData"))




############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 
############################################################
############################################################

fishery_holder<-bio_params_for_econ[c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea")]
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0

revenue_holder<-NULL

#METHOD 2-  DATA.TABLE is winning so far
day<-300
working_production<-data.table(production_dataset[[day]])
working_targeting<-data.table(targeting_dataset[[day]])

production_outputs<-get_predict_eproduction(working_production)



#This bit needs to be replaced with a function that handles the "jointness"
#expected revenue from this species
production_outputs$exp_rev_sim<- production_outputs$harvest_sim*production_outputs$price_lb_lag1
production_outputs$exp_rev_total_sim<- production_outputs$harvest_sim*production_outputs$price_lb_lag1*production_outputs$multiplier

#use the revenue multiplier to construct total revenue for this trip.
#This bit needs to be replaced with a function that handles the "jointness"



#   use those three key variables to merge-update harvest, revenue, and expected revenue in the targeting dataset
joincols<-c("hullnum","date", "spstock2")




working_targeting<-working_targeting[1:5197]


sq<-function(){
  working_targeting<-as.data.table(left_join(working_targeting,production_outputs, by=joincols))
}


cbind_style<-function(){
  working_targeting2<-cbind(working_targeting,production_outputs$harvest_sim)
}






microbenchmark(ans_cf<-sq(), ans_cb <- cbind_style(), times=100 )


















# 
# dtstyle <- function() {
#   
#   for (day in 1:365){
#     #This comes in as a data.table now
#     
#     
#     tds<-targeting_dataset[[day]]
# 
#     tds[, csum := cumsum(prhat), by = id]
#     
#     #make one draw per id, then replicate it nchoices time and place it into tds$draw
#     tdss<-unique(tds[,c("id","nchoices")])
#     td<-runif(nrow(tdss), min = 0, max = 1)
#     tds$draw<-rep(td,tdss$nchoices)
#     
#     #Foreach id, keep the row for which draw is the smallest value that is greater than csum
#     
#     tds<-tds[tds$draw<tds$csum,]
#     tds<-tds[tds[, .I[1], by = id]$V1] 
#     
#   }
# }
# 
# 
# # 
# tidystyle <- function() {
#   for (day in 1:365){
#     #This comes in as a data.table now
#     
#     tds<-targeting_dataset[[day]]
#     tds[, csum := cumsum(prhat), by = id]
#     
#     #make one draw per id, then replicate it nchoices time and place it into tds$draw
#     tdss<-unique(tds[,c("id","nchoices")])
#     td<-runif(nrow(tdss), min = 0, max = 1)
#     tds$draw<-rep(td,tdss$nchoices)
#     
#     tds<-tds[tds$draw<tds$csum,]
#     
#     tds <-
#       tds %>% 
#       group_by(id) %>% 
#       filter(row_number()==1)
#     
#     }
#   
#   
# }
# 
# microbenchmark(ans_dtstyle<-dtstyle(), ans_tidy <- tidystyle(), times=10)
# 
# 
# 
# 
# #This takes a while
# # tds <-
# #   tds %>% 
# #   group_by(id) %>% 
# #   filter(row_number()==1)
# 
# 
# 
# 
# 
# daily_catch<- trips[, c("spstock2","h_hat")]
# colnames(daily_catch)[2]<-"cumul_catch_pounds"
# daily_catch<-rbind(daily_catch,fishery_holder[c("spstock2","cumul_catch_pounds")])
# 
# 
# daily_catch<-as.data.table(daily_catch)
# 
# 
# 
# 
# 
# dtstyle <- function() {
#   daily_catch<-daily_catch[, cumul_catch_pounds := sum(cumul_catch_pounds),by=list(spstock2)]
# }
# 
# 
# 
# 
# 
# tidystyle <- function() {
#   daily_catch<- daily_catch %>% 
#     group_by(spstock2) %>% 
#     summarise(cumul_catch_pounds=sum(cumul_catch_pounds))
#   
# }
# 
# 
# 
# open_hold<-fishery_holder
# 
# countF<-function(){
#   num_closed<-sum(open_hold$open==FALSE)
# }
# 
# 
# diffs<-function(){
#   nrow(open_hold)-sum(open_hold$open)
# }
# 
# lengther<-function(){
#   (length(open_hold[open_hold$open==FALSE]))
# }
# 
# 
# 
# 
# 
# 
# microbenchmark(ans_cf<-countF(), ans_diffs <- diffs(), ans_len<-lengther(), times=100 )
# 
# 
# 



