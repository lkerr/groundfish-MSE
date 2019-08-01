
# Benchmarking Rccp sugar
# # test the same outputs
# day<-2
# 
# working_targeting<-targeting_dataset[[day]]
# base<-get_predict_eproduction(working_targeting)
# sugar<-get_predict_eproductionCpp(working_targeting)
# lappS<-lapply(targeting_dataset,get_predict_eproductionCpp)
# 
# all.equal(base,sugar)
# all.equal(base,lappS[[2]])
# #YES!
# 
# sq<-function(){
# for (day in 1:365){
#   #   subset both the targeting and production datasets based on date and jams them to data.tables
# 
#   working_targeting<-targeting_dataset[[day]]
#   working_targeting<-get_predict_eproduction(working_targeting)
# 
# }
#    
# }
# 
# 
# sugar_style<-function(){
#   for (day in 1:365){
#     #   subset both the targeting and production datasets based on date and jams them to data.tables
#     
#     working_targeting<-targeting_dataset[[day]]
#     working_targeting<-get_predict_eproductionCpp(working_targeting)
#     
#   }
#   
# }
# 
# 
# sugar_lapply<-function(){
#     #   subset both the targeting and production datasets based on date and jams them to data.tables
#     
#     working_targeting<-lapply(targeting_dataset,get_predict_eproductionCpp)
# 
#   }
#   
# 
# 
# # ans_s_lapply<-sugar_lapply
#  microbenchmark(ans_sq<-sq(), ans_sugar<-sugar_style(), times=10)
# 
# 
# 
# 

