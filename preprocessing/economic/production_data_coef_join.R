# This pre-processing file:
  # 1. Pulls in the production equation coefficients and data
  # 2. Joins them together (based on spstock2, gearcat, and post).  We may not want to do that.
  #.3. Drop unnecessary variables.

# This is a little stupid, because it make a big dataset, instead of making a pair of matrices (one for data and one for coefficients). But whatever.

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

econrawpath <- 'data/data_raw/econ/'
econsavepath <- 'data/data_processed/econ/'

#Files to read -- sample data for now.
production_source<-"sample_PRODREGdata_forML_v3.dta"

production <- read.dta13(file.path(econrawpath, production_source))
production$startfy = as.Date(paste("5", "1",production$gffishingyear,sep="."), "%m.%d.%Y")
production$doffy=as.numeric(difftime(production$date,production$startfy, units="days")+1)

###############################################################
#THIS IS JUST FOR TESTING, REMOVE THIS LATER. I've faked the 2004-2015 variables so the factorization will work properly
production$fybak<-production$gffishingyear
production$gffishingyear <- sample(2004:2015,nrow(production), replace=T)
#THIS IS JUST FOR TESTING, REMOVE THIS LATER.
###############################################################

#clean up production dataset, expand month and year factor variables.
production$gearcat<-tolower(production$gearcat)
production$spstock2<-tolower(production$spstock)
production$spstock2<- gsub("_","",production$spstock2)



mygfyear<-as.data.frame(factor(production$gffishingyear))
mymonth<-as.data.frame(factor(production$month))

mymonth<-as.data.frame(model.matrix(~ . + 0, data=mymonth, contrasts.arg = lapply(mymonth, contrasts, contrasts=FALSE)))

mygfyear<-as.data.frame(model.matrix(~ . + 0, data=mygfyear, contrasts.arg = lapply(mygfyear, contrasts, contrasts=FALSE)))

colnames(mymonth)<-paste0("month",1:12)
colnames(mygfyear)<-paste0("fy",2004:2015)

production<-cbind(production, mymonth,mygfyear)
###############################################################
#THIS IS JUST FOR TESTING, REMOVE THIS LATER. I've faked the 2004-2015 variables so the factorization will work properly. Nothing bad will happen if you forget to remove this.
production$gffishingyear<-production$fybak
#THIS IS JUST FOR TESTING, REMOVE THIS LATER.
###############################################################

load(file.path(econsavepath,"production_coefs.RData"))

# merge production dataset and coefficients
production_dataset<-inner_join(production,production_coefs,by=c("gearcat","spstock2","post"))

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


production_dataset$spstock2<-tolower(production_dataset$spstock)
production_dataset$spstock2<- gsub("_","",production_dataset$spstock2)
production_dataset$spstock2<- gsub("gb","GB",production_dataset$spstock2)
production_dataset$spstock2<- gsub("ccgom","CCGOM",production_dataset$spstock2)
production_dataset$spstock2<- gsub("gom","GOM",production_dataset$spstock2)
production_dataset$spstock2<- gsub("snema","SNEMA",production_dataset$spstock2)



#Keep a subset of the variables
datavars=c("log_crew","log_trip_days","logh_cumul","primary","secondary")
betavars=paste0("beta_",datavars)
pd_cols<-colnames(production_dataset)

fydums<-pd_cols[grepl("^fy20", pd_cols)]
fycoefs<-pd_cols[grepl("^beta_fy20", pd_cols)]

monthdums<-pd_cols[grepl("^month", pd_cols)]
monthcoefs<-pd_cols[grepl("^beta_month", pd_cols)]
idvars=c("hullnum2", "id", "date","spstock2", "doffy")
necessary=c("multiplier", "q", "rmse", "price_lb_lag1","emean", "gffishingyear")
useful=c("gearcat","post", "logh")
mysubs=c(idvars, useful, datavars,betavars, fydums, monthdums, fycoefs, monthcoefs, necessary)

production_dataset<-production_dataset[mysubs]

pre_only_dataset<-production_dataset[which(production_dataset$post==0),]
post_only_dataset<-production_dataset[which(production_dataset$post==1),]


save(production_dataset, file=file.path(econsavepath, "full_production.RData"))
save(post_only_dataset, file=file.path(econsavepath, "post_production.RData"))
save(pre_only_dataset, file=file.path(econsavepath, "pre_production.RData"))

#rm(list=ls())







