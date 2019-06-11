# some code to test speeds


rm(list=ls())


ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))

#source('processes/loadLibs.R')
library(microbenchmark)
library(data.table)

datapath <- 'data/data_processed/econ'
load(file.path(datapath,"full_targeting.RData"))
load(file.path(datapath,"full_production.RData"))

targeting_dataset<-targeting_dataset[which(targeting_dataset$gffishingyear==2009),]
production_dataset<-production_dataset[which(production_dataset$gffishingyear==2009),]


fishery_holder<-unique(targeting_dataset[c("spstock2")])
fishery_holder$open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-1
fishery_holder$acl<-1e16
fishery_holder$bio_model<-0
fishery_holder$bio_model[fishery_holder$spstock2 %in% c("codGB","pollock","haddockGB","yellowtailflounderGB")]<-1

revenue_holder<-NULL

#END SETUPS

#Test different ways to subset these datasets. 
# BASELINE METHOD using which

production_dataset<-split(production_dataset, production_dataset$doffy)
targeting_dataset<-split(targeting_dataset, targeting_dataset$doffy)


#METHOD 2-- BASELINE


#METHOD 1-  baseline aggregate
f1 <- function() {
  for (day in 1:365){
    tds<-hold_targ[[day]]
    
    datavars=c("exp_rev_total","distance","das_charge","fuelprice_distance","start_of_season","crew","price_lb_lag1","mean_wind","mean_wind_2","permitted","lapermit","das_charge_len","max_wind","max_wind_2","fuelprice","fuelprice_len","wkly_crew_wage")
    
    betavars=paste0("beta_",datavars)
    
    X<-as.matrix(tds[datavars])
    X[is.na(X)]<-0
    
    B<-as.matrix(tds[betavars])
    B[is.na(B)]<-0
    
    tds$xb=rowSums(X*B)
    tds$expu<-exp(tds$xb)
    

    totexpu<-aggregate(tds$expu,by=list(id=tds$id), FUN=sum)
    colnames(totexpu)=c("id","totalu")
    tds<-full_join(tds, totexpu, by = "id")
    
  }
}


#METHOD 2-  tapply
f2  <- function() {
  for (day in 1:365){
    tds<-hold_targ[[day]]
    
    datavars=c("exp_rev_total","distance","das_charge","fuelprice_distance","start_of_season","crew","price_lb_lag1","mean_wind","mean_wind_2","permitted","lapermit","das_charge_len","max_wind","max_wind_2","fuelprice","fuelprice_len","wkly_crew_wage")
    
    betavars=paste0("beta_",datavars)
    
    X<-as.matrix(tds[datavars])
    X[is.na(X)]<-0
    
    B<-as.matrix(tds[betavars])
    B[is.na(B)]<-0
    
    tds$xb=rowSums(X*B)
    tds$expu<-exp(tds$xb)
    
    
    totexpu<-tapply(tds$expu, tds$id, FUN=sum)
  }
  
}





#METHOD 3-  dplyr 
f3  <- function() {
  for (day in 1:365){
    tds<-hold_targ[[day]]
    
    datavars=c("exp_rev_total","distance","das_charge","fuelprice_distance","start_of_season","crew","price_lb_lag1","mean_wind","mean_wind_2","permitted","lapermit","das_charge_len","max_wind","max_wind_2","fuelprice","fuelprice_len","wkly_crew_wage")
    
    betavars=paste0("beta_",datavars)
    
    X<-as.matrix(tds[datavars])
    X[is.na(X)]<-0
    
    B<-as.matrix(tds[betavars])
    B[is.na(B)]<-0
    
    tds$xb=rowSums(X*B)
    tds$expu<-exp(tds$xb)
    
    temp1<- tds %>% 
      group_by(id) %>% 
      summarise(totexpu2=sum(expu))
    tds<-full_join(tds, temp1, by = "id")
    
  }
  
}




#METHOD 4-  ave 
f4  <- function() {
  for (day in 1:365){
    tds<-hold_targ[[day]]
    
    datavars=c("exp_rev_total","distance","das_charge","fuelprice_distance","start_of_season","crew","price_lb_lag1","mean_wind","mean_wind_2","permitted","lapermit","das_charge_len","max_wind","max_wind_2","fuelprice","fuelprice_len","wkly_crew_wage")
    
    betavars=paste0("beta_",datavars)
    
    X<-as.matrix(tds[datavars])
    X[is.na(X)]<-0
    
    B<-as.matrix(tds[betavars])
    B[is.na(B)]<-0
    
    tds$xb=rowSums(X*B)
    tds$expu<-exp(tds$xb)
    
    tds<-tds%>% 
      group_by(id) %>% 
      mutate(totexpu3=sum(expu))
    
  }
  
}



f5  <- function() {
  
for (day in 1:365){
  
working_production<-production_dataset[[day]]
working_targeting<-targeting_dataset[[day]]

working_production<-left_join(working_production,fishery_holder, by="spstock2")

production_outputs<-get_predict_eproduction(working_production)

#   
#   use those three key variables to merge-update harvest, revenue, and expected revenue in the targeting dataset
joincols<-c("hullnum2","date","spstock2")
working_targeting<-left_join(working_targeting,production_outputs, by=joincols)



}
}

  

f6  <- function() {
  
  for (day in 1:365){
    
    working_production<-production_dataset[[day]]
    working_targeting<-targeting_dataset[[day]]
    working_production<-left_join(working_production,fishery_holder, by="spstock2")
    
    production_outputs<-get_predict_eproduction(working_production)
    
    #   
    #   use those three key variables to merge-update harvest, revenue, and expected revenue in the targeting dataset
    joincols<-c("id","spstock2")
    working_targeting<-left_join(working_targeting,production_outputs, by=joincols)
    
    
    
  }
}




microbenchmark(ans5 <- f5(), ans6<-f6(), times=10)


tdsb<-tds

tds<-tds%>% 
  group_by(id) %>% 
  mutate(totexpu3=sum(expu))




