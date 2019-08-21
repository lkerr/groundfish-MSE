

# A function to handle jointness in production (technical interactions) 
#
# Inputs
#  wt: The working_targeting_dataset that contains coefficients and independent variables. 
# 	
# Outputs: 
# a modified version of the wt data table withextra/overwritten columns
# the c_ columns start as "catch multipliers", but end up as "catch"
# the l_ columns start as "landings multipliers", but end up as "landings"
# exp_rev_total is updated as sum lag_price*landings minus sum quota_price*catch
# actual_rev_total is updated as sum price*landings minus sum quota_price*catch



get_joint_production <- function(wt,spstock_names){
  
  
  catches<-paste0("c_",spstock_names)
  landings<-paste0("l_",spstock_names)
  
  quotaprices<-paste0("q_",spstock_names)
  lagp<-paste0("p_",spstock_names)
  prices<-paste0("r_",spstock_names)
  
  
  #overwrite the c_ multiplier with catch in pounds
  for(j in catches){
    set(wt, i=NULL, j=j, value=wt[[j]]*wt[['harvest_sim']])
  }
  #overwrite the l_ multiplier with landings in pounds
  for(j in landings){
    set(wt, i=NULL, j=j, value=wt[[j]]*wt[['harvest_sim']])
  }
  
  #compute quota costs of a choice  
  Z<-as.matrix(wt[, ..quotaprices])
  A<-as.matrix(wt[,..catches])
  wt[, quota_cost:=rowSums(Z*A)]
  
  #compute total expected revenues in 1000s of dollars
  Z<-as.matrix(wt[, ..landings])
  A<-as.matrix(wt[,..lagp])
  A<-Z*A
  
  wt[, exp_rev_total:=(rowSums(A)-quota_cost)]
  #wt$exp_rev_total<-(rowSums(A)-wt$quota_cost)/1000
  #Right here, you could replace the columns (p_*) of wt with the columns of A (also p_*) if you wanted to save expected revenue by species
  
  
  #compute actual revenues
  A<-as.matrix(wt[,..prices])
  A<-Z*A
  wt[, actual_rev_total:=(rowSums(A)-quota_cost)]
  
  #wt$actual_rev_total<-(rowSums(A)-wt$quota_cost)
  #Right here, you could replace the columns (r_*) of wt with the columns of A (also r_*) if you wanted to save actual revenue by species
  

  return(wt)
}

