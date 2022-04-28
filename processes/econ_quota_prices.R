
q_fy<-0
for (day in 1:365){
# On the first day of each quarter, do something 
  if (day==1 | day==91 | day==182 | day==273){
  q_fy<-q_fy+1
  print(paste("It is quarter",q_fy))
  
  # Construct RHS variables for the selection and quota price equations 
  # Extract elements of fishery_holder that you need to compute fish prices
  quarterly<-fishery_holder[,c("stocklist_index","stockName","spstock2","sectorACL","bio_model", "cumul_catch_pounds")]
  quarterly$quota_remaining_BOQ<-sector_ACL-cumul_catch_pounds
  quarterly$quota_remaining_BOQ<-quota_remaining_BOQ/(pounds_per_kg*kg_per_mt)
  quarterly$fraction_remaining_BOQ<-quota_remaining_BOQ/sectorACL
  
  #Scale to 1000s of mt
  quarterly$quota_remaining_BOQ<-quota_remaining_BOQ/1000
  
  
  #Quarterly dummmies
  quarterly$q_fy1<-as.integer(q_fy==1)
  quarterly$q_fy2<-as.integer(q_fy==2)
  quarterly$q_fy3<-as.integer(q_fy==3)
  quarterly$q_fy4<-as.integer(q_fy==4)
  
  # Pull in quarterly prices
  
  }
}
    
    
  
  


#  fishery_holder will give you 
# fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","bio_model", "cumul_catch_pounds")]
# Be careful about units. The quota_price model is on 000s of mt. 
