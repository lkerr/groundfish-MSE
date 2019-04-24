

# A function to do predictions for the production model. 
#
# prod_ds: Combined dataset of production data and coefficients recovered 
# 	from a log-log regression.
# logh=q+XB, where X is q, log crew, log trip days, log cumulative harvest, primary, secondary, and dummies for month and fishing year.
# 

get_predict_eproduction <- function(prod_ds){
  indepvars=c("log_crew","log_trip_days","logh_cumul","primary","secondary","constant")
  fyvars=paste0("fy",2004:2015)
  monthvars=paste0("month",1:12)
  
  datavars=c(indepvars,fyvars,monthvars)
  betavars=paste0("beta_",datavars)
  
  
  X<-as.matrix(prod_ds[datavars])
  X[is.na(X)]<-0
  
  B<-as.matrix(prod_ds[betavars])
  B[is.na(B)]<-0
  
  prod_ds$logh_hat<-rowSums(X*B)
  prod_ds$logh_hat=prod_ds$logh_hat+prod_ds$q
  
  #production
  # bad way to smear
  #prod_ds$harvest_sim<- exp(prod_ds$logh_hat + fx)*exp((prod_ds$rmse^2)/2)
  
  #good way to smear
  prod_ds$harvest_sim<- (exp(prod_ds$logh_hat))*prod_ds$emean 
  
  #expected revenue
  prod_ds$exp_rev_sim<- prod_ds$harvest_sim*prod_ds$price_lb_lag1
  prod_ds$exp_rev_total_sim<- prod_ds$harvest_sim*prod_ds$price_lb_lag1*prod_ds$multiplier
  
  selectvars<-c("hullnum2", "date", "spstock2","exp_rev_sim","exp_rev_total_sim","harvest_sim")
  
  prod_out<-prod_ds[selectvars]
  return(prod_out)
}

