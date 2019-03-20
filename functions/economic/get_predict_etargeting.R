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
 attach(tds)
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
  return(tds$prhat)
  detach(tds)
  
}


# This is another way to do it. 
# tds$util<-beta_exp_rev*exp_rev_total + beta_distance*distance + beta_das_charge*das_charge + beta_fuelprice_distance*fuelprice_distance + beta_start_of_season*start_of_season+beta_crew*crew + beta_price_one_day_lag*price_lb_lag1 +beta_avg_wind*mean_wind + beta_avg_wind2*mean_wind_2+beta_permitted*permitted + beta_lapermitted*LApermit +das_charge_len*beta_das_charge_len+ beta_max_wind*max_wind+beta_max_wind2*max_wind_2
#   
# #Add in the alternative-specific effects 
#   tds$util<-tds$util + beta_fuelprice*fuelprice+beta_fuelprice_len*fuelprice_len+beta_wkly_crew_wage*wkly_crew_wage
# tds$util[is.na(tds$util)]<-0
# 
# tds$expu<-exp(tds$util)

