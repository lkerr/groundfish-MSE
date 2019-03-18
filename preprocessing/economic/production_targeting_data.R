
if(!require(readstata13)) {  
  install.packages("readstata13")
  require(readstata13)}
if(!require(tidyr)) {  
  install.packages("tidyr")
  require(tidyr)}
if(!require(dplyr)) {  
  install.packages("dplyr")
  require(dplyr)}

# file paths for the raw and final directories

rawpath <- 'data/data_raw/econ/'
savepath <- 'data/data_processed/econ/'

#Files to read -- sample data for now.
targeting_source<-"sample_DCdata_gillnets_fy2012_forML.dta"
production_source<-"sample_PRODREGdata_gillnets_fy2012_forML.dta"

targeting_coef_source<-"asclogits_ALL.txt" #(I'll just pull the first GILLNET and FIRST TRAWL coefs)
production_coef_pre<-"production_regs_actual_pre_forR.txt"
production_coef_post<-"production_regs_actual_post_forR.txt"
# 
# # read in the datasets
targeting <- read.dta13(file.path(rawpath, targeting_source))
production <- read.dta13(file.path(rawpath, production_source))

production$gearcat<-tolower(production$gearcat)
production$spstock2<-tolower(production$spstock2)
# 
# 
# 
# 
# 
# # I think we don't want to drop any data out of the datasets until right before the simulations.
# # May make sense to sort data here
# 
# # We will want to always have the datasets merged with regression coefficients
# # save processed data
save(targeting, file=file.path(savepath, "econ_targeting.RData"))
save(production, file=file.path(savepath, "econ_production.RData"))







tt<-inner_join(production,production_coefs,by=c("gearcat","spstock2","post"))

save(production_coefs, file=file.path(savepath, "production_coefs.RData"))