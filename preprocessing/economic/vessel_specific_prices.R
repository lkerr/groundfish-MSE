# Read in pre- and post- multipliers to two lists and save those to Rds 
# Tested working. Make a small change if we want to get different regression results (there are 4 sets of models for each gear, we haven't picked a "best " model yet).

rm(list=ls())
if(!require(readstata13)) {  
  install.packages("readstata13")
  require(readstata13)}
if(!require(tidyr)) {  
  install.packages("tidyr")
  require(tidyr)}
if(!require(dplyr)) {  
  install.packages("dplyr")
  require(dplyr)}
if(!require(data.table)) {  
  install.packages("data.table")
  require(data.table)}

# file paths for the raw and final directories
# windows is kind of stupid, so you'll have to deal with it in some way.
rawpath <- './data/data_raw/econ'
savepath <- './data/data_processed/econ'


price_location<-"hullnum_spstock2_input_prices.dta"

preoutfile<-"sim_pre_vessel_stock_prices.Rds"
postoutfile<-"sim_post_vessel_stock_prices.Rds"

mults <- read.dta13(file.path(rawpath, price_location))
mults<-as.data.table(mults)

#multipre<-mults[post==0]
#multipre<-split(multipre,multipre$gffishingyear)

multipost<-mults[post==1]

multipost<-split(multipost,multipost$gffishingyear)


saveRDS(multipost, file=file.path(savepath, postoutfile), compress=FALSE)
#saveRDS(multipre, file=file.path(savepath, preoutfile),compress=FALSE)
rm(list=ls())


