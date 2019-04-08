# A function to do predictions for the economic targeting model. 
#
# tds: Combined dataset of targeting data and asclogit coefficients 
# I need to :
# A. compute xb. 
# B. exponentiate
# C. Compute the total, by id
# D. Compute prob = exp(xb)/total exp(xb)

#.Unsure if the NA are handled properly.  Also unsure if the "No Fish" option will be properly constructed (Troubleshoot: if the utility function equation is fixed AND I get a matrix of NAs, then the utility for the no-fish option isn't properly being constructed. I'm pretty sure that this gets set =0 (so exp(0)=1). There are no coefficients for no fish model.

get_predict_etargeting <- function(tds){
  # pull the betas into matrix, pull the data variables into a matrix and mulitiply them.
  
  datavars=c("exp_rev_total","distance","das_charge","fuelprice_distance","start_of_season","crew","price_lb_lag1","mean_wind","mean_wind_2","permitted","lapermit","das_charge_len","max_wind","max_wind_2","fuelprice","fuelprice_len","wkly_crew_wage")
  
  betavars=paste0("beta_",datavars)
  
X<-as.matrix(tds[datavars])
X[is.na(X)]<-0
  
B<-as.matrix(tds[betavars])
B[is.na(B)]<-0

xb<-rowSums(X*B)
tds<-cbind(tds,xb)
tds$expu<-exp(tds$xb)
  totexpu<-aggregate(tds$expu,by=list(id=id), FUN=sum)
  colnames(totexpu)=c("id","totalu")
  
  # mergeback
  tds<-merge(x = tds, y = totexpu, by = "id", all = TRUE)
  tds$prhat<- tds$expu/tds$totalu
  
  return(tds)
}

