

# empty the environment
rm(list=ls())
set.seed(2) 

source('processes/runSetup.R')
library(microbenchmark)
library("Rcpp")

scratchdir<-"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/scratch/econscratch"
Rcpp::sourceCpp(file.path(scratchdir,"matsums.cpp"))



sq<-function(){
  for (day in 1:365){
tdsDT<-targeting_dataset[[day]]
tdsDT<-get_predict_eproductionCpp(tdsDT)
  }
}
  
  dist<-function(){
     targeting_dataset<-lapply(targeting_dataset, get_predict_eproductionCpp)
  }     
  
  microbenchmark(ans_cf<-sq(),ans_cb <- dist(),  times=2)
  
uniq
drawu
tileout
tileout2
reorder
accum
filter1
filter2



 get_draws <- function(){
   #make one draw per id, then replicate it nchoices time and place it into tds$draw
   tdss<-unique(tdsDT[,c("id","nchoices")])
   td<-runif(nrow(tdss), min = 0, max = 1)
   tdsDT$draw<-rep(td,tdss$nchoices)
   return(tdsDT)
 }
 
 
 get_draws2 <- function(){
    #make one draw per id, then replicate it nchoices time and place it into tds$draw
    tdss<-tdsDT[idflag== 1]
    tdss<-tdss[,c("id","nchoices")]
    td<-runif(nrow(tdss), min = 0, max = 1)
    tdsDT$draw<-rep(td,tdss$nchoices)
    return(tdsDT)
 }
 
 
 
 tdsDT<-targeting_dataset[[2]]
 
 microbenchmark(ans_sq<-get_draws(),ans2 <-get_draws2(),   times=10)
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 filter_out <- function(tdsDT){
   
   tds<-tdsDT[order(tdsDT$id,tdsDT$prhat),]
   tds<-tds[, csum := cumsum(prhat), by = id]
 
   tds<-tds[tds$draw<tds$csum,]
   tds<-tds[tds[, .I[1], by = id]$V1] 
   return(tds)
   }
 
 day<-2
 
   working_targeting<-targeting_dataset[[day]]
   working_targeting<-get_predict_eproduction(working_targeting)
   working_targeting$exp_rev_total<- working_targeting$harvest_sim*working_targeting$price_lb_lag1*working_targeting$multiplier
   trips<-get_predict_etargeting(working_targeting)
   #trips<-zero_out_closed_asc_cutout(trips,fishery_holder)

   set.seed(2)
   tripsSQ<-get_random_draw_tripsDT(trips)

   set.seed(2)
   
   tripsnew<-get_draws(trips)
   tripsnew<-filter_out(tripsnew)
   setcolorder(tripsnew,"draw")
   
   setcolorder(tripsnew,colnames(tripsSQ))
   all.equal(tripsnew, tripsSQ)
   
   
   
   
   sq<-function(){
     set.seed(2)
     for (day in 1:365){
       working_targeting<-targeting_dataset[[day]]
       #   subset both the targeting and production datasets based on date and jams them to data.tables
       trips<-get_predict_etargeting(working_targeting)
       trips<-get_random_draw_tripsDT(trips)
     }
   }
   
   
   
   
   sq2<-function(){
     set.seed(2)
     for (day in 1:365){
       working_targeting<-targeting_dataset[[day]]
       #   subset both the targeting and production datasets based on date and jams them to data.tables
       trips<-get_predict_etargeting(working_targeting)
       trips<-get_draws(trips)
       trips<-filter_out(trips)
       }
   }
   
   
   
   
   set.seed(2)
   targeting_dataset<-lapply(targeting_dataset,get_draws)
   
   
   
   applydraw<-function(){
     set.seed(2)
     targeting_dataset<-lapply(targeting_dataset,get_draws)
     for (day in 1:365){
       #   subset both the targeting and production datasets based on date and jams them to data.tables
       working_targeting<-targeting_dataset[[day]]
       trips<-get_predict_etargeting(working_targeting)
       trips<-filter_out(trips)
     }
   }
   
   
   
   applydrawCpp<-function(){
     set.seed(2)
     targeting_dataset<-lapply(targeting_dataset,get_draws)
     for (day in 1:365){
       #   subset both the targeting and production datasets based on date and jams them to data.tables
       working_targeting<-targeting_dataset[[day]]
       trips<-get_predict_etargetingCpp(working_targeting)
       trips<-filter_out(trips)
     }
   }
   
   
    microbenchmark(ans_cf<-sq(),ans_cb <- applydrawCpp(),  times=5)
   
   
   
   

# 
# tds<-targeting_dataset
# 
# datavars=c("exp_rev_total","das_charge","fuelprice_distance","mean_wind","mean_wind_noreast","permitted","lapermit","distance","wkly_crew_wage","len","fuelprice","fuelprice_len","start_of_season","partial_closure","constant")
# 
# betavars=paste0("beta_",datavars)
# 
# 
# 
# sq <- function() {
#   for (day in 1:365){
#     tds<-targeting_dataset[[day]]
#     
#  X<-as.matrix(tds[, ..datavars])
#  B<-as.matrix(tds[, ..betavars])
#  Z<-rowSums(X*B)
# }
# }
# 
# 
# matrixing <- function() {
#   for (day in 1:365){
#     tds<-targeting_dataset[[day]]
#     
#     X<-as.matrix(tds[, ..datavars])
#     B<-as.matrix(tds[, ..betavars])
# 
#     Z<-.rowSums(X*B, nrow(X), ncol(X))
#   }
#   
#   }
# 
# 
# rfasting <- function() {
#   for (day in 1:365){
#     tds<-targeting_dataset[[day]]
#     
#     X<-as.matrix(tds[, ..datavars])
#     B<-as.matrix(tds[, ..betavars])
#     x1 <-Rfast::rowsums(X*B)
#     }
# }
# 
# 
# 
# 
# 
# microbenchmark(ans_cf<-sq(), ans_cb <- matrixing(), ans_cb <- rfasting(), times=10)
# 
# 
# 
# A<-matrix(1:6, nrow=3, ncol=2)
# B<-matrix(4:9, nrow=3, ncol=2)
# 
# Z<-A*B
# Z<-rowSums(Z)
# 
# Z2<-diag(A%*%t(B))




