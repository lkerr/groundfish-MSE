# Read in Production and Targeting coefficients to .RData.  
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

#rawpath <- 'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE/data/data_raw/econ'
#savepath <- 'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE/data/data_processed/econ'


production_coef_pre<-"production_regs_actual_pre_forR.txt"
production_coef_post<-"production_regs_actual_post_forR.txt"



##########################
# BEGIN readin of econometric model of production coefficients 
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

# read in the estimated coefficients from txt files
production_coefs <- read.csv(file.path(rawpath,production_coef_pre), sep="\t", header=TRUE,stringsAsFactors=FALSE)

production_coefs<-zero_out(production_coefs,thresh)
production_coefs<-droppval(production_coefs)


# Drop out the p-values since we don't need them anymore. these are the odd columns 3:nc. Super ugly code, but works.
## End zeroing out coefficients ##



#push the first column into the row names and drop that column
rownames(production_coefs)<-production_coefs[,1]
production_coefs<-production_coefs[,-1]

#transpose and send to dataframe, fix naming, and characters
production_coefs<-as.data.frame(t(production_coefs))


### Repeat for the post coefs 

production_coefs_post <- read.csv(file.path(rawpath,production_coef_post), sep="\t", header=TRUE,stringsAsFactors=FALSE)

production_coefs_post<-zero_out(production_coefs_post,thresh)
production_coefs_post<-droppval(production_coefs_post)

#push the first column into the row names and drop that column
rownames(production_coefs_post)<-production_coefs_post[,1]
production_coefs_post<-production_coefs_post[,-1]
#transpose and send to dataframe, fix naming, and characters
production_coefs_post<-as.data.frame(t(production_coefs_post))

### Bring together 
production_coefs[setdiff(names(production_coefs_post), names(production_coefs))] <- NA
production_coefs_post[setdiff(names(production_coefs), names(production_coefs_post))] <- NA
production_coefs<-rbind(production_coefs,production_coefs_post)
rm(production_coefs_post)
#take the rownames, push them into a column, and make sure they are characters. un-name the rows
model <- rownames(production_coefs)
production_coefs<-cbind(model,production_coefs)
production_coefs$model<-as.character(production_coefs$model)
rownames(production_coefs)<-NULL


# parse the "model" string variable to facilitate merging to production dataset
production_coefs<-separate(production_coefs,model,into=c("gearcat","spstock2","post"),sep="[_]", remove=TRUE)

## Rename columns 
### First, Unlabel.  Strip out the equal signs. Prepend "alpha_" to all
colnames(production_coefs)[colnames(production_coefs)=="Number of Crew (Log)"] <- "log_crew"
colnames(production_coefs)[colnames(production_coefs)=="Trip Length Days (Log)"] <- "log_trip_days"
colnames(production_coefs)[colnames(production_coefs)=="Cumulative Harvest (Log)"] <- "logh_cumul"
colnames(production_coefs)[colnames(production_coefs)=="Primary Target"] <- "primary"
colnames(production_coefs)[colnames(production_coefs)=="Secondary Target"] <- "secondary"
colnames(production_coefs)[colnames(production_coefs)=="Trawl Survey Biomass (Log)"]<- "log_trawl_survey_weight"
colnames(production_coefs)<- tolower(gsub("=","",colnames(production_coefs)))


production_coefs<-production_coefs[,c(which(colnames(production_coefs)!="constant"),which(colnames(production_coefs)=="constant"))]
production_coefs<-production_coefs[,c(which(colnames(production_coefs)!="rmse"),which(colnames(production_coefs)=="rmse"))]

colnames(production_coefs)[5:ncol(production_coefs)-1]<-paste0("alpha_",colnames(production_coefs[5:ncol(production_coefs)-1]))
# you will eventually merge on post, gearcat, and spstock
production_coefs$gearcat<-tolower(production_coefs$gearcat)
production_coefs$spstock2<-tolower(production_coefs$spstock2)
production_coefs$post<-as.numeric(production_coefs$post)

#You've zero filled the n/a's in the prediction code, but fine to keep here.
############ I think the safest thing to do is fill any NA coefficients with zeros.
production_coefs[is.na(production_coefs)] <- 0
############ In the data, fill any corresponding NAs also with zeros -- this would mostly be biomass or fishing year

production_coefs<-as.data.table(production_coefs)


save(production_coefs, file=file.path(savepath, "production_coefs.RData"))



