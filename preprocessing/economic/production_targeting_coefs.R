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

# file paths for the raw and final directories
stupid<-'C:/Users/Min-Yang.Lee/Documents/groundfish-MSE'
rawpath <- '/data/data_raw/econ/'
savepath <- '/data/data_processed/econ/'

gillnet_targeting_coef_source<-"nlogit_gillnet_pre_coefs.txt" #(I'll just pull the first GILLNET and FIRST TRAWL coefs)

targeting_coef_source<-"asclogits_ALL_forR.txt" #(I'll just pull the first GILLNET and FIRST TRAWL coefs)
production_coef_pre<-"production_regs_actual_pre_forR2.txt"
production_coef_post<-"production_regs_actual_post_forR2.txt"



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
### First, Unlabel.  Strip out the equal signs. Prepend "beta_" to all
colnames(production_coefs)[colnames(production_coefs)=="Number of Crew (Log)"] <- "log_crew"
colnames(production_coefs)[colnames(production_coefs)=="Trip Length Days (Log)"] <- "log_trip_days"
colnames(production_coefs)[colnames(production_coefs)=="Cumulative Harvest (Log)"] <- "logh_cumul"
colnames(production_coefs)[colnames(production_coefs)=="Primary Target"] <- "primary"
colnames(production_coefs)[colnames(production_coefs)=="Secondary Target"] <- "secondary"
colnames(production_coefs)[colnames(production_coefs)=="Trawl Survey Biomass (Log)"]<- "log_trawl_survey_weight"
colnames(production_coefs)<- tolower(gsub("=","",colnames(production_coefs)))


production_coefs<-production_coefs[,c(which(colnames(production_coefs)!="constant"),which(colnames(production_coefs)=="constant"))]
production_coefs<-production_coefs[,c(which(colnames(production_coefs)!="rmse"),which(colnames(production_coefs)=="rmse"))]

colnames(production_coefs)[5:ncol(production_coefs)-1]<-paste0("beta_",colnames(production_coefs[5:ncol(production_coefs)-1]))
# you will eventually merge on post, gearcat, and spstock
production_coefs$gearcat<-tolower(production_coefs$gearcat)
production_coefs$spstock2<-tolower(production_coefs$spstock2)
production_coefs$post<-as.numeric(production_coefs$post)

#You've zero filled the n/a's in the prediction code, but fine to keep here.
############ I think the safest thing to do is fill any NA coefficients with zeros.
production_coefs[is.na(production_coefs)] <- 0
############ In the data, fill any corresponding NAs also with zeros -- this would mostly be biomass or fishing year

save(production_coefs, file=file.path(savepath, "production_coefs.RData"))


 nlogit_gillnet <- read.csv(file.path(stupid,rawpath,gillnet_targeting_coef_source), sep="\t", header=TRUE,stringsAsFactors=FALSE)
 nlogit_gillnet<-nlogit_gillnet[,-3]
 colnames(nlogit_gillnet)<-c("eq_co","value")
 #parse the combined "eq_co" column
 out <- do.call(rbind,strsplit(as.character(nlogit_gillnet$eq_co),':'))
 nlogit_gillnet<-cbind(out,nlogit_gillnet)
 #Add extra columns for gear and pre/post, just in case
 nlogit_gillnet<-cbind("gillnet","0",nlogit_gillnet)
 colnames(nlogit_gillnet)<-c("gear", "post","equation","variable","eq_co","value")
 
 nlogit_gillnet$variable<-as.character(nlogit_gillnet$variable)
 nlogit_gillnet$variable[which(nlogit_gillnet$variable=="_cons")]<-"constant"
 nlogit_gillnet$variable2<- paste0("beta_", nlogit_gillnet$variable)
 
  #This is a good place to stop until I see the data.
 
 

# This is code to pull out ASC logit coefficients, but we're not doing that anymore
# #Repeat for the ASCLogit coefficients (not done yet)
# asc_coefs <- read.csv(file.path(stupid,rawpath,targeting_coef_source), sep="\t", header=TRUE,stringsAsFactors=FALSE)
# asc_coefs<-asc_coefs[-1,]
# 
# # I'm just extracting the 1st set of regression results, these are in columns 1:5.  
# asc_coefs<-asc_coefs[,1:5]
# 
# 
# asc_coefs<-zero_out(asc_coefs,thresh)
# asc_coefs<-droppval(asc_coefs)
# 
# # fix up X (coef name)
# asc_coefs$X<-tolower(asc_coefs$X)
# 
# 
# 
# asc_coefs$X<-gsub(",","", asc_coefs$X)
# asc_coefs$X<-trimws(asc_coefs$X, which=c("both"))
# 
# asc_coefs$X<-gsub("\t)","", asc_coefs$X)
# asc_coefs$X<-gsub("one-day lag","", asc_coefs$X)
# asc_coefs$X<-gsub("\\(deflated\\)","", asc_coefs$X)
# asc_coefs$X<-trimws(asc_coefs$X, which=c("both"))
# 
# asc_coefs$X[asc_coefs$X=="price/lb"] <-"price_lb_lag1"
# 
# asc_coefs$X[asc_coefs$X=="total expected revenues (expected revenues*multiplier)"] <-"exp_rev_total"
# asc_coefs$X[asc_coefs$X=="distance (in miles) from port to month-specific stock area"] <-"distance"
# asc_coefs$X[asc_coefs$X=="das charge"] <-"das_charge"
# asc_coefs$X[asc_coefs$X=="number of crew"] <-"crew"
# asc_coefs$X[asc_coefs$X=="start of fishing season indicator (months 1 and 2)"] <-"start_of_season"
# asc_coefs$X[asc_coefs$X=="open-access/permit to fish"] <-"permitted"
# asc_coefs$X[asc_coefs$X=="limited-access permit to fish"] <-"lapermit"
# 
# asc_coefs$X[asc_coefs$X=="fuel price*distance"] <-"fuelprice_distance"
# asc_coefs$X[asc_coefs$X=="fuel price*vessel length"] <-"fuelprice_len"
# asc_coefs$X[asc_coefs$X=="fuel price"] <-"fuelprice"
# 
# asc_coefs$X[asc_coefs$X=="das charge*vessel length"] <-"das_charge_len"
# asc_coefs$X[asc_coefs$X=="max wind speed (m/s)"] <-"max_wind"
# asc_coefs$X[asc_coefs$X=="max wind speed squared"] <-"max_wind_2"
# 
# asc_coefs$X[asc_coefs$X=="avg. wind speed (m/s)"] <-"mean_wind"
# asc_coefs$X[asc_coefs$X=="avg. wind speed squared"] <-"mean_wind_2"
# 
# 
# asc_coefs$X<-gsub("fuel price*vessel length","fuelprice_len ", asc_coefs$X)
# 
# 
# asc_coefs$X<-gsub("average weekly wages for non-crew work","wkly_crew_wage", asc_coefs$X)
# 
# 



stocklist<-c("american_lobster", "cod_gb", "cod_gom", "haddock_gom", "haddock_gb", "monkfish", "other", "pollock", "skates", "spiny_dogfish", "white_hake", "yellowtail_flounder_ccgom","american_plaice_flounder", "red_silver_offshore_hake","redfish","sea_scallop","squid_mackerel_butterfish_herrin","winter_flounder_gb","winter_flounder_gom","witch_flounder","yellowtail_flounder_gb", "yellowtail_flounder_snema","summer_flounder")


#Delete this line for the final version 
#stocklist<-c("american_lobster", "cod_gb", "cod_gom")
# 
# asc_coefs$spstock2<-0
# 
# for (ws in stocklist){ 
#   wr<-grep(ws,asc_coefs$X)
#   asc_coefs$spstock2[(wr+1):(wr+3)]<-ws
#   asc_coefs<-asc_coefs[-wr,]
# }
# 
# 
# ALL<-asc_coefs[which(asc_coefs$spstock2==0),]
# ALL<-ALL[!names(ALL) %in% c("spstock2")]
# rownames(ALL)<-ALL[,1]
# ALL<-ALL[,-1]
# 
# ALL<-as.data.frame(t(ALL))
# ALL$gearcat<-rownames(ALL)
# rownames(ALL)<-NULL
#   
# 
# 
# stocks<-asc_coefs[-which(asc_coefs$spstock2==0),]
# stocks<-gather(stocks,'GILLNETS','TRAWL', key="gearcat", value="coef")
# stocks<-spread(stocks,X,coef)
# #transpose and send to dataframe, fix naming, and characters
# 
# targeting_coefs<-inner_join(stocks,ALL, by="gearcat")
# 
# targeting_coefs$spstock2<- gsub("_","",targeting_coefs$spstock2)
# 
# 
# colnames(targeting_coefs)[3:ncol(targeting_coefs)]<-paste0("beta_",colnames(targeting_coefs[3:ncol(targeting_coefs)]))
# targeting_coefs$spstock2[which(targeting_coefs$spstock2=="squidmackerelbutterfishherrin")]<-"squidmackerelbutterfishherring"
# 
# 
# #Force NAs to zero. This is legit. I promise. 
# targeting_coefs[is.na(targeting_coefs)]<-0
# 
# save(targeting_coefs, file=file.path(savepath, "targeting_coefs.RData"))
# 
# 



