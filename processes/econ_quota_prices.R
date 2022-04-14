
q_fy<-0
for (day in 1:365){
# On the first day of each quarter, do something 
  if (day==1 | day==91 | day==182 | day==273){
  q_fy<-q_fy+1
  print(paste("It is quarter",q_fy))
  
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
  
  # extract elements of 
  # working_targeting<-copy(targeting_dataset[[day]]).   
  # You should just need one observation of prices.  
  # This is harder than it looks. Could 'pick' todays price, but better to pick the whole quarters price
  # you will have to go and get a subset of the targeting dataset[[1:90]] 
  
  }
}
    
    
  
  


# you will need to operate on 2 things:
#  1. The working_targeting dataset will give you spstock2 and it's price
#  2. fishery_holder will give you 
  # fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","bio_model", "cumul_catch_pounds")]
  # Be careful about units. The quota_price model is on 000s of mt. 
