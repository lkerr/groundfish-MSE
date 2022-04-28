# Load in quota price coefficients
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
if(!require(here)) {  
  install.packages("here")
  require(here)}

# Setting up the data.
# Before you do anything, you put all your "data" files into the 
# /data/data_raw/econ folder
here::i_am("preprocessing/economic/quota_price_coefs.R")

# file paths for the raw and final directories
# windows is kind of stupid, so you'll have to deal with it in some way.
savepath <- here("data","data_processed","econ")
rawpath <- savepath
# Just a guess on your paths.  
#rawpath <- 'C:/Users/abirken/Documents/GitHub/groundfish-MSE/data/data_raw/econ'
#savepath <- 'C:/Users/abirken/Documents/GitHub/groundfish-MSE/data/data_processed/econ'



# 
# ##############Independent variables in the Production equation ##########################
# ### If there are different the equations, you can set there up here, then use their suffix in the mproc file to use these new targeting equations
# ### example, using ProdEqn=tiny in the mproc file and uncommenting the next  line will be regression with 2 RHS variables and no constant.
# # production_vars_tiny=c("log_crew","log_trip_days")
# 
selection=c("quota_remaining_BOQ","QuotaFraction","Q2","Q3", "Q4","constant")
badj_GDP=c("live_priceGDP","quota_remaining_BOQ","WTswtquota_remaining_BOQ","WTDswtquota_remaining_BOQ", "Q2","Q3", "Q4","constant")


#names of quota price files.
quotaprice_coefs_in<-"quota_price_linear.txt"
quotaprice_coefs_out<-"quotaprice_coefs.Rds"





##########################
# BEGIN readin of econometric model of quota price coefficients 
##########################
# p value, above which we set the coefficient to zero.  You can set this to 1.0 if you want.
thresh<-1.0

## Function to zero out coefficients that are non statistically significant##
zero_out<-function(working_coefs,pcut){
  nc<-ncol(working_coefs)
  # zero out the insignificant ones 
  wc<-2
  while(wc<nc){
    idxM<-NULL 
    idxM<-which(working_coefs[wc+1]>pcut) 
    working_coefs[,wc][idxM]<-0
    wc<-wc+2
  }
  working_coefs
}

## Function to drop out the p-values##
droppval<-function(working_coefs){
  nc<-ncol(working_coefs)
  # zero out the insignificant ones 
  wc<-nc
  while(wc>=3){
    working_coefs<-working_coefs[-wc]
    wc<-wc-2
  }
  working_coefs
}

### Code works for post-as-post and post-as-pre as long as the pre_process files are run separately  
quotaprice_coefs <- read.csv(file.path(rawpath,quotaprice_coefs_in), sep="\t", header=TRUE,stringsAsFactors=FALSE)

qc_rownames<-quotaprice_coefs[,1]
#here is a good place to gsub out the ":", "_I", and _cons to constant
#qc_rownames<-gsub(":","_",qc_rownames)
qc_rownames<-gsub("_I","",qc_rownames)
qc_rownames<-gsub("_cons","constant",qc_rownames)
qc_rownames<-gsub("__","_",qc_rownames)
qc_rownames<-gsub("#","X",qc_rownames)
qc_rownames<-gsub("c\\.","",qc_rownames)

quotaprice_coefs<-zero_out(quotaprice_coefs,thresh)
quotaprice_coefs<-droppval(quotaprice_coefs)



# Keep the sescond row 
quotaprice_coefs<-quotaprice_coefs[,2]

#transpose and send to dataframe, fix naming, and characters
quotaprice_coefs<-as.data.frame(t(quotaprice_coefs))
colnames(quotaprice_coefs)<-qc_rownames
 

# parse the "model" string variable to facilitate merging to production dataset

## Rename columns 
### First, Unlabel.  Strip out the equal signs. Prepend "alpha_" to all
# colnames(quotaprice_coefs)[colnames(quotaprice_coefs)=="Number of Crew (Log)"] <- "log_crew"
# colnames(quotaprice_coefs)[colnames(quotaprice_coefs)=="Trip Length Days (Log)"] <- "log_trip_days"
# colnames(quotaprice_coefs)[colnames(quotaprice_coefs)=="Cumulative Harvest (Log)"] <- "logh_cumul"
# colnames(quotaprice_coefs)[colnames(quotaprice_coefs)=="Primary Target"] <- "primary"
# colnames(quotaprice_coefs)[colnames(quotaprice_coefs)=="Secondary Target"] <- "secondary"
# colnames(quotaprice_coefs)[colnames(quotaprice_coefs)=="Trawl Survey Biomass (Log)"]<- "log_trawl_survey_weight"
# colnames(quotaprice_coefs)[colnames(quotaprice_coefs)=="Sector ACL (Log)"]<- "log_sector_acl"
# 
# colnames(quotaprice_coefs)<- tolower(gsub("=","",colnames(quotaprice_coefs)))



quotaprice_coefs<-as.data.table(quotaprice_coefs)
saveRDS(quotaprice_coefs, file=file.path(savepath, quotaprice_coefs_out), compress=FALSE)
rm(list=c("badj_GDP","selection","qc_rownames","quotaprice_coefs_in","quotaprice_coefs_out"))


