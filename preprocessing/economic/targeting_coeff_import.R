# Read in Production and Targeting coefficients to .Rds  
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

# gillnet_targeting_coef_source<-"nlogit_gillnet_pre_coefs.txt" #(I'll just pull the first GILLNET and FIRST TRAWL coefs)

trawl_targeting_coef_source<-"asclogit_trawl_post_coefs.txt" 
gillnet_targeting_coef_source<-"asclogit_gillnet_post_coefs.txt"



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

 

# This is code to pull out ASC logit coefficients for trawl
asc_coefs <- read.csv(file.path(rawpath,trawl_targeting_coef_source), sep="\t", header=TRUE,stringsAsFactors=FALSE)
asc_coefs<-asc_coefs[,-3]

#Separate on the ":" and tidy up white space a bit
asc_coefs<-separate(asc_coefs,X,into=c("equation","variable"),sep=":", remove=TRUE, fill="right")
asc_coefs$equation<-gsub(",","", asc_coefs$equation)
asc_coefs$equation<-trimws(asc_coefs$equation, which=c("both"))
asc_coefs$variable<-gsub(",","", asc_coefs$variable)
asc_coefs$variable<-trimws(asc_coefs$variable, which=c("both"))
asc_coefs$gearcat<-"TRAWL"


#Repeat for gillnet and then stack together.
gn_coefs <- read.csv(file.path(rawpath,gillnet_targeting_coef_source), sep="\t", header=TRUE,stringsAsFactors=FALSE)
gn_coefs<-gn_coefs[,-3]


#Separate on the ":" and tidy up white space a bit
gn_coefs<-separate(gn_coefs,X,into=c("equation","variable"),sep=":", remove=TRUE, fill="right")
gn_coefs$equation<-gsub(",","", gn_coefs$equation)
gn_coefs$equation<-trimws(gn_coefs$equation, which=c("both"))
gn_coefs$variable<-gsub(",","", gn_coefs$variable)
gn_coefs$variable<-trimws(gn_coefs$variable, which=c("both"))
gn_coefs$gearcat<-"GILLNETS"

asc_coefs<-rbind(asc_coefs,gn_coefs)
asc_coefs$variable[asc_coefs$variable=="_cons"] <-"constant"

rm(gn_coefs)



# Split asc_coefs into two dataframes. One where equation=="spstock2" and the other where equation~="spstock2" 
asc_coefs$variable<-paste0("beta_",asc_coefs$variable)

all_coefs<-asc_coefs[which(asc_coefs$equation=="spstock2"),]
#drop the equation column. Spread
all_coefs<-all_coefs[,-1]
all_coefs<-spread(all_coefs,variable,coefficient)



asc_coefs2<-asc_coefs[which(asc_coefs$equation!="spstock2"),]
colnames(asc_coefs2)[1]<-"spstock2"

asc_coefs2<-spread(asc_coefs2,variable,coefficient)
targeting_coefs<-inner_join(asc_coefs2,all_coefs, by="gearcat")

#The "start of season" variable goes in slightly differently for gillnet and trawl

#
targeting_coefs$beta_start_of_season.x[is.na(targeting_coefs$beta_start_of_season.x)] <- targeting_coefs$beta_start_of_season.y[is.na(targeting_coefs$beta_start_of_season.x)]
targeting_coefs<-within(targeting_coefs, rm(beta_start_of_season.y))

colnames(targeting_coefs)[colnames(targeting_coefs)=="beta_start_of_season.x"] <- "beta_start_of_season"
colnames(targeting_coefs)[colnames(targeting_coefs)=="beta_exp_rev_total_das"] <- "beta_exp_rev_total"

#Force NAs to zero. This is legit. I promise.
targeting_coefs[is.na(targeting_coefs)]<-0
targeting_coefs<-as.data.table(targeting_coefs)

setcolorder(targeting_coefs,c("gearcat", "spstock2"))
#targeting_coefs[, c("beta_o.das_price_mean","beta_o.das_price_mean_len"):=NULL]

saveRDS(targeting_coefs, file=file.path(savepath, "targeting_coefs.Rds"))
rm(list=c("all_coefs","asc_coefs","asc_coefs2"))

#write.csv(targeting_coefs, file="asc.txt")
#verified that coefficients match

#  Deprecated 
#  nlogit_gillnet <- read.csv(file.path(rawpath,gillnet_targeting_coef_source), sep="\t", header=TRUE,stringsAsFactors=FALSE)
#  nlogit_gillnet<-nlogit_gillnet[,-3]
#  colnames(nlogit_gillnet)<-c("eq_co","value")
#  #parse the combined "eq_co" column
#  out <- do.call(rbind,strsplit(as.character(nlogit_gillnet$eq_co),':'))
#  nlogit_gillnet<-cbind(out,nlogit_gillnet)
#  #Add extra columns for gear and pre/post, just in case
#  nlogit_gillnet<-cbind("gillnet","0",nlogit_gillnet)
#  colnames(nlogit_gillnet)<-c("gear", "post","equation","variable","eq_co","value")
#  
#  nlogit_gillnet$variable<-as.character(nlogit_gillnet$variable)
#  nlogit_gillnet$variable[which(nlogit_gillnet$variable=="_cons")]<-"constant"
#  nlogit_gillnet$variable2<- paste0("beta_", nlogit_gillnet$variable)
#  
#This is a good place to stop until I see the data.

# outdated cleaning
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
#transpose and send to dataframe, fix naming, and characters

# targeting_coefs<-inner_join(stocks,ALL, by="gearcat")
# 
# targeting_coefs$spstock2<- gsub("_","",targeting_coefs$spstock2)

