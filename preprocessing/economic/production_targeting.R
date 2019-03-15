# Read in Production and Targeting datasets from Stata to .Rdata format.  
# Need to Read in the production and targeting coefficients

if(!require(readstata13)) {  
  install.packages("readstata13")
  require(readstata13)}

# file paths for the raw and final directories

rawpath <- 'data/data_raw/econ/'
savepath <- 'data/data_processed/econ/'

#Files to read -- sample data for now.
targeting_source<-"sample_DCdata_gillnets_fy2012_forML.dta"
production_source<-"sample_PRODREGdata_gillnets_fy2012_forML.dta"

# read in the datasets
targeting <- read.dta13(file.path(rawpath, targeting_source))
production <- read.dta13(file.path(rawpath, production_source))
# read in the estimated coefficients







# I think we don't want to drop any data out of the datasets until right before the simulations.
# May make sense to sort data here


# We will want to always have the datasets merged regression coefficients here.
# save processed data
save(targeting, file=file.path(savepath, "econ_targeting.Rdata"))
save(production, file=file.path(savepath, "econ_production.Rdata"))


