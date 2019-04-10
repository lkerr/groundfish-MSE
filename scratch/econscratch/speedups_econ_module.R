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

#END SETUPS

#Test different ways to subset these datasets. 
# BASELINE METHOD using which

hold_targ<-split(targeting_dataset, targeting_dataset$doffy)


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
      summarise(totexpu=sum(expu))
    tds<-full_join(tds, temp1, by = "id")
    
  }
  
}


  

microbenchmark(ans1 <- f1(), ans3<-f3(), times=10)





