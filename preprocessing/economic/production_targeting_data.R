# This pre-processing file:
  # 1. Pulls in the production equation coefficients and data
  # 2. Joins them together (based on spstock2, gearcat, and post).  We may not want to do that.

  # 3. Pulls in the targeting equation coefficients and data
  # 4. Joins them together. 
# This is a little stupid, because it make a big dataset, instead of making a pair of matrices (one for data and one for coefficients). But whatever.

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

# 
# # read in the datasets
targeting <- read.dta13(file.path(rawpath, targeting_source))


targeting$spstock2<-tolower(targeting$spstock)
targeting$spstock2<- gsub("_","",targeting$spstock2)


production <- read.dta13(file.path(rawpath, production_source))
###############################################################
#THIS IS JUST FOR TESTING, REMOVE THIS LATER.
production$gffishingyear <- sample(2004:2015,nrow(production), replace=T)
#THIS IS JUST FOR TESTING, REMOVE THIS LATER.
###############################################################                        

#clean up production dataset, expand month and year factor variables.
production$gearcat<-tolower(production$gearcat)
production$spstock2<-tolower(production$spstock2)

mygfyear<-as.data.frame(factor(production$gffishingyear))
mymonth<-as.data.frame(factor(production$month))
###############################################################
#THIS IS JUST FOR TESTING, REMOVE THIS LATER.
production$gffishingyear <- 2012
#THIS IS JUST FOR TESTING, REMOVE THIS LATER.
###############################################################                        


mymonth<-as.data.frame(model.matrix(~ . + 0, data=mymonth, contrasts.arg = lapply(mymonth, contrasts, contrasts=FALSE)))

mygfyear<-as.data.frame(model.matrix(~ . + 0, data=mygfyear, contrasts.arg = lapply(mygfyear, contrasts, contrasts=FALSE)))

colnames(mymonth)<-paste0("months",1:12)
colnames(mygfyear)<-paste0("fy",2004:2015)

production<-cbind(production, mymonth,mygfyear)


load(file.path(savepath,"targeting_coefs.RData"))
load(file.path(savepath,"production_coefs.RData"))

# merge production dataset and coefficients
production_dataset<-inner_join(production,production_coefs,by=c("gearcat","spstock2","post"))

# This is the place where you would drop-out the "post" variable
post_only<-production_coefs[which(production_coefs$post==1),]
post_production_dataset<-inner_join(production,post_only,by=c("gearcat","spstock2"))

pre_only<-production_coefs[which(production_coefs$post==0),]
pre_production_dataset<-inner_join(production,pre_only,by=c("gearcat","spstock2"))

#do some error checking on the merge
# I expect the exact number of rows in "production_dataset" as there are in production. Anything else is a problem.
if(nrow(production_dataset) != nrow(production)){
  warning("Lost some Rows from the production dataset")
}
#I expect the number of columns in production dataset to be number in production, plus number in production coefs, minus 3 (because I had 3 match columns)

check<- ncol(production)+ncol(production_coefs)-3
if(ncol(production_dataset) !=check){
  warning("Lost some Columns from the production dataset")
}


save(production_dataset, file=file.path(savepath, "full_production.RData"))
save(post_production_dataset, file=file.path(savepath, "post_production.RData"))
save(pre_production_dataset, file=file.path(savepath, "pre_production.RData"))



# merge targeting dataset and coefficients
# Note, you'll have some NAs for some rows, especially no fish.
targeting_dataset<-left_join(targeting,targeting_coefs,by=c("gearcat","spstock2"))



#I expect the number of columns in targeting dataset to be number in targeting, plus number in targeting coefs, minus 2 (because I had 2 match columns)

check<- ncol(targeting)+ncol(targeting_coefs)-2
if(ncol(targeting_dataset) !=check){
  warning("Lost some Columns from the targeting dataset")
}


save(targeting_dataset, file=file.path(savepath, "full_targeting.RData"))




