# A function to handle jointness in production (technical interactions) 
#
# Inputs
#  wt: The working_targeting_dataset that contains coefficients and independent variables. 
# 	
# Outputs: 
# a modified version of the wt data table withextra/overwritten columns
# the c_ columns start as "catch multipliers", but end up as "catch"
# the l_ columns start as "landings multipliers", but end up as "landings"
# The p_columns start as "lag prices", and end up as "lag revenue ==expected revenue, by stock"
# The q_columns start as "quota prices", and end up as "quota costs, by stock"
# the r_columns start as "prices", and end up as "actual revenue, by stock"
# exp_rev_total is updated as sum lag_price*landings minus sum quota_price*catch
# actual_rev_total is updated as sum price*landings minus sum quota_price*catch


get_joint_production <- function(wt,spstock_names){

  catches<-paste0("c_",spstock_names)
  landings<-paste0("l_",spstock_names)
  daylimits <-paste0("dl_",spstock_names)
  quotaprices<-paste0("q_",spstock_names)
  lagp<-paste0("p_",spstock_names)
  prices<-paste0("r_",spstock_names)
  
  #overwrite the c_ multiplier and the l_multipliers with catch and landings in pounds
  # overwrite the quotaprices with quotacost
  # overwrite the lagp with expected revenue
  #overwrite the prices with actual revenue
  for(idx in 1:length(spstock_names)){
    set(wt, i = NULL, j = catches[idx], value = wt[[catches[idx]]]*wt[['harvest_sim']])
    set(wt, i = NULL, j = landings[idx], value = wt[[landings[idx]]]*wt[['harvest_sim']])
    
    #set(wt, i = NULL, j = landings[idx], value = ifelse(is.na(wt[[daylimits[idx]]]), wt[[landings[idx]]], ifelse(wt[[landings[idx]]]>= wt[[daylimits[idx]]], wt[[daylimits[idx]]], wt[[landings[idx]]])))
    wt [, landings[idx]:= ifelse(is.na(wt[[daylimits[idx]]]), wt[[landings[idx]]], ifelse(wt[[landings[idx]]] >= wt[[daylimits[idx]]], wt[[daylimits[idx]]], wt[[landings[idx]]]))]
    
    set(wt, i = NULL, j = quotaprices[idx], value = wt[[quotaprices[idx]]]*wt[[catches[idx]]])
    set(wt, i = NULL, j = lagp[idx], value = wt[[lagp[idx]]]*wt[[landings[idx]]])
    set(wt, i = NULL, j = prices[idx], value = wt[[prices[idx]]]*wt[[landings[idx]]])
  }
  
  ##compute quota costs, actual revenue, and expected revenue   
  ##Assemble formulas for
  
  my.erformula<-NULL 
  my.arformula<-NULL 
  my.qformula<-NULL 
  
  for(idx in 1:length(spstock_names)){
    my.erformula<- paste0(my.erformula,"+",lagp[idx],"+")
    my.arformula<- paste0(my.arformula,"+",prices[idx],"+")
    my.qformula<- paste0(my.qformula,"+",quotaprices[idx],"+")
    
  }
  my.erformula<-substr(my.erformula,1,nchar(my.qformula)-1)
  my.arformula<-substr(my.arformula,1,nchar(my.arformula)-1)
  my.qformula<-substr(my.qformula,1,nchar(my.qformula)-1)
  
  my.erformula<-paste0(my.erformula,"-quota_cost")
  my.arformula<-paste0(my.arformula,"-quota_cost")
  
  # parse(text=my.erformula, keep.source=FALSE)
   my.erformula<-parse(text=my.erformula, keep.source=FALSE)
   my.arformula<-parse(text=my.arformula, keep.source=FALSE)
   my.qformula<-parse(text=my.qformula, keep.source=FALSE)
  
    
  wt[, quota_cost:=eval(my.qformula)]
  wt[, exp_rev_total:=eval(my.erformula)]
  wt[, actual_rev_total:=eval(my.arformula)]
  
  return(wt)
  
}

