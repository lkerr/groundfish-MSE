# This pre-processing file:
  # 1. Pulls in the targeting equation coefficients and data
  # 2. Joins them together (based on spstock2 and  gearcat). 
  #.3. Drop unnecessary variables.
# A little stupid to join the coefficients to the data, because it make a big dataset with lots of replicated data, instead of making a pair of matrices (one for data and one for coefficients). But whatever.
# need to update this file with variable changes and equation changes. Anna is sending over a stata .ster. for coefficients
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


# file paths for the raw and final directories

econrawpath <- './data/data_raw/econ'
econsavepath <- './data/data_processed/econ'

#Files to read -- sample data for now.
targeting_source<-"sample_DCdata_fys2009_2010_forML.dta"

#Load in targeting coefficients
load(file.path(econsavepath,"targeting_coefs.RData"))

colnames(targeting_coefs)[colnames(targeting_coefs)=="beta_LApermit"] <- "beta_lapermit"
targeting_coefs$spstock2<-tolower(targeting_coefs$spstock2)

# read in the dataset
targeting <- read.dta13(file.path(econrawpath, targeting_source))


targeting$startfy = paste("5", "1",targeting$gffishingyear,sep=".")
targeting$startfy = as.Date(paste("5", "1",targeting$gffishingyear,sep="."), "%m.%d.%Y")
targeting$doffy=as.numeric(difftime(targeting$date,targeting$startfy, units="days")+1)

#Follow naming conventions
targeting$spstock2<-tolower(targeting$spstock2)
targeting$spstock2<- gsub("_","",targeting$spstock2)

colnames(targeting)[colnames(targeting)=="LApermit"] <- "lapermit"






# merge targeting dataset and coefficients
# Note, you'll have some NAs for some rows, especially no fish.
targeting_dataset<-left_join(targeting,targeting_coefs,by=c("gearcat","spstock2"))
targeting_dataset$spstock2<- gsub("gb","GB",targeting_dataset$spstock2)
targeting_dataset$spstock2<- gsub("ccgom","CCGOM",targeting_dataset$spstock2)
targeting_dataset$spstock2<- gsub("gom","GOM",targeting_dataset$spstock2)
targeting_dataset$spstock2<- gsub("snema","SNEMA",targeting_dataset$spstock2)



#I expect the number of columns in targeting dataset to be number in targeting, plus number in targeting coefs, minus 2 (because I had 2 match columns)

check<- ncol(targeting)+ncol(targeting_coefs)-2
if(ncol(targeting_dataset) !=check){
  warning("Lost some Columns from the targeting dataset")
}

targeting_dataset$constant<- 1


datavars=c("exp_rev_total","das_charge","fuelprice_distance","mean_wind","mean_wind_noreast","permitted","lapermit","distance","wkly_crew_wage","len","fuelprice","fuelprice_len","start_of_season","partial_closure","constant")
betavars=paste0("beta_",datavars)
idvars=c("id", "hullnum2", "date","spstock2", "doffy")
necessary=c( "multiplier", "q", "gffishingyear")
useful=c("gearcat","post","h_hat","pr")
mysubs=c(idvars,necessary,useful,datavars,betavars)
#mysubs is broken

targeting_dataset<-targeting_dataset[mysubs]

save(targeting_dataset, file=file.path(econsavepath, "full_targeting.RData"))

#rm(list=ls())






