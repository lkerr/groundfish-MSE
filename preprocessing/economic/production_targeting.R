# Read in Production and Targeting datasets from Stata to .Rdata format.  
# Need to Read in the production and targeting coefficients

if(!require(readstata13)) {  
  install.packages("readstata13")
  require(readstata13)}
if(!require(tidyr)) {  
  install.packages("tidyr")
  require(tidyr)}

# file paths for the raw and final directories

rawpath <- 'data/data_raw/econ/'
savepath <- 'data/data_processed/econ/'

#Files to read -- sample data for now.
targeting_source<-"sample_DCdata_gillnets_fy2012_forML.dta"
production_source<-"sample_PRODREGdata_gillnets_fy2012_forML.dta"

targeting_coef_source<-"asclogit.txt"
production_coef_source<-"production_regs_V27.txt"
production_coef_source<-"prod29.txt" #temp overwriting

# read in the datasets
targeting <- read.dta13(file.path(rawpath, targeting_source))
production <- read.dta13(file.path(rawpath, production_source))





# I think we don't want to drop any data out of the datasets until right before the simulations.
# May make sense to sort data here

# We will want to always have the datasets merged regression coefficients here.
# save processed data
save(targeting, file=file.path(savepath, "econ_targeting.RData"))
save(production, file=file.path(savepath, "econ_production.RData"))


##########################
# BEGIN readin of econometric model of production coefficients 
##########################
# read in the estimated coefficients from txt files
production_coefs <- read.csv(file.path(rawpath,production_coef_source), sep=",", header=TRUE,stringsAsFactors=FALSE)

## Deal with zeroing out coefficients ##

nc<-ncol(production_coefs)
# zero out the insignificant ones 
wc<-2
while(wc<nc){
  idxM<-NULL 
  idxM<-which(production_coefs[wc+1]>.1) 
  production_coefs[,wc][idxM]<-0
  wc<-wc+2
}
# Drop out the p-values since we don't need them anymore. these are the odd columns 3:nc. Super ugly code, but works.
wc<-nc
while(wc>=3){
  production_coefs<-production_coefs[-wc]
  wc<-wc-2
}
## End zeroing out coefficients ##



#push the first column into the row names and drop that column
rownames(production_coefs)<-production_coefs[,1]
production_coefs<-production_coefs[,-1]

#transpose and send to dataframe, fix naming, and characters
production_coefs<-as.data.frame(t(production_coefs))

#take the rownames, push them into a column, and make sure they are characters. un-name the rows
model <- rownames(production_coefs)
production_coefs<-cbind(model,production_coefs)
production_coefs$model<-as.character(production_coefs$model)
rownames(production_coefs)<-NULL


# parse the "model" string variable to facilitate merging to production dataset
production_coefs<-separate(production_coefs,model,into=c("estimator","post","gearcat","spstock"),sep="[_]", remove=TRUE)

# you will eventually merge on post, gearcat, and spstock


save(production_coefs, file=file.path(savepath, "production_coefs.RData"))


#Repeat for the ASCLogit coefficients (not done yet)


#save(targeting_coefs, file=file.path(savepath, "targeting_coefs.RData"))

# Desired output   
## 40ish rows (2 gears x2 time periods x 10ish stocks)
## 3 key columns (post, gearcat, spstock)
## 29 columns: "real variables", 12 categoricals for months,  12 categoricals for years
 





