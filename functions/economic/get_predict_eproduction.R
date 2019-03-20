

# A function to do predictions for the production model. 
#
# prod_ds: Combined dataset of production data and coefficients recovered 
# 	from a log-log regression.
# logh=q+XB, where X is q, log crew, log trip days, log cumulative harvest, primary, secondary, and dummies for month and fishing year.
# 

get_predict_eproduction <- function(prod_ds){
 attach(prod_ds)
  
  datavars=c("log_crew","log_trip_days","logh_cumul","primary","secondary")
  betavars=paste0("beta_",datavars)
  
  
  X<-as.matrix(prod_ds[datavars])
  X[is.na(X)]<-0
  
  B<-as.matrix(prod_ds[betavars])
  B[is.na(B)]<-0
  
  prod_ds$logh_hat<-rowSums(X*B)
  prod_ds$logh_hat=prod_ds$logh_hat+q

  # Pull the fy dummies out, replace NAs with zeros, and multiply them by the fy coefs
  fydums<-subset(prod_ds, select = grepl("^fy20", names(prod_ds)))
  fydums[is.na(fydums)]<-0
  fycoefs<-subset(prod_ds, select = grepl("^beta_fy20", names(prod_ds)))
  fycoefs[is.na(fycoefs)]<-0
  
  fx<-rowSums(fydums*fycoefs)
  monthdums<-subset(prod_ds, select = grepl("^months", names(prod_ds)))
  monthdums[is.na(monthdums)]<-0
  monthcoefs<-subset(prod_ds, select = grepl("^beta_month", names(prod_ds)))
  monthcoefs[is.na(monthcoefs)]<-0
  
  fx<-fx+ rowSums(monthdums*monthcoefs)
  prod_ds$logh_hat<- prod_ds$logh_hat + fx
  
  hhat<-exp(prod_ds$logh_hat)*exp((rmse^2)/2)
  detach(prod_ds)
  
  return(hhat)
  
}

