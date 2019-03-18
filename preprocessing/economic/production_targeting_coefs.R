# Read in Production and Targeting datasets from Stata to .Rdata format.  
# Need to Read in the production and targeting coefficients

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


targeting_coef_source<-"asclogits_ALL.txt" #(I'll just pull the first GILLNET and FIRST TRAWL coefs)
production_coef_pre<-"production_regs_actual_pre_forR.txt"
production_coef_post<-"production_regs_actual_post_forR.txt"



##########################
# BEGIN readin of econometric model of production coefficients 
##########################
# p value, above which we set the coefficient to zero.  You can set this to 1.0 if you want.
thresh<-0.10

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

### Reapeat for the post coefs 

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
colnames(production_coefs)[colnames(production_coefs)=="Number of Crew (Log)"] <- "logcrew"
colnames(production_coefs)[colnames(production_coefs)=="Trip Length (Log)"] <- "logtripdays"
colnames(production_coefs)[colnames(production_coefs)=="Cumulative Harvest (Log)"] <- "loghcumul"
colnames(production_coefs)[colnames(production_coefs)=="Primary Target"] <- "primary"
colnames(production_coefs)[colnames(production_coefs)=="Secondary Secondary"] <- "secondary"
colnames(production_coefs)<- tolower(gsub("=","",colnames(production_coefs)))

production_coefs<-production_coefs[,c(which(colnames(production_coefs)!="rmse"),which(colnames(production_coefs)=="rmse"))]

colnames(production_coefs)[6:ncol(production_coefs)-1]<-paste0("beta_",colnames(production_coefs[6:ncol(production_coefs)-1]))
# you will eventually merge on post, gearcat, and spstock
production_coefs$gearcat<-tolower(production_coefs$gearcat)
production_coefs$spstock2<-tolower(production_coefs$spstock2)
production_coefs$post<-as.numeric(production_coefs$post)

save(production_coefs, file=file.path(savepath, "production_coefs.RData"))









#Repeat for the ASCLogit coefficients (not done yet)

asc_coefs <- read.csv(file.path(rawpath,targeting_coef_source), sep="\t", header=TRUE,stringsAsFactors=FALSE)
asc_coefs<-asc_coefs[-1,]

asc_coefs<-zero_out(asc_coefs,thresh)
asc_coefs<-droppval(asc_coefs)

# fix up X (coef name)
asc_coefs$X<-tolower(asc_coefs$X)





asc_coefs$X[asc_coefs$X=="total expected revenues (expected revenues*multiplier)"] <-"exp_rev"
asc_coefs$X[asc_coefs$X=="distance (in miles) from port to month-specific stock area"] <-"distance"
asc_coefs$X[asc_coefs$X=="das charge"] <-"das_charge"
asc_coefs$X[asc_coefs$X=="number of crew"] <-"crew"
asc_coefs$X[asc_coefs$X=="start of fishing season indicator (months 1 and 2)"] <-"start_of_season"
asc_coefs$X[asc_coefs$X=="open-access/permit to fish"] <-"permitted"
asc_coefs$X[asc_coefs$X=="limited-access permit to fish"] <-"lapermitted"

asc_coefs$X[asc_coefs$X=="fuel price*distance"] <-"fuelprice_distance"
asc_coefs$X[asc_coefs$X=="fuel price*vessel length"] <-"fuelprice_len"

asc_coefs$X[asc_coefs$X=="das charge*vessel length"] <-"das_charge_len"
asc_coefs$X[asc_coefs$X=="max wind speed (m/s)"] <-"max_wind"
asc_coefs$X[asc_coefs$X=="max wind speed squared"] <-"max_wind2"
asc_coefs$X[asc_coefs$X=="max wind speed squared"] <-"max_wind2"
asc_coefs$X<-gsub("fuel price*vessel length","fuelprice_len ", asc_coefs$X)

asc_coefs$X<-gsub("\\(deflated\\)","", asc_coefs$X)



stocklist<-c("americanlobster", "codgb", "codgom", "haddockgom", "haddockgb", "monkfish", "nofish", "other", "pollock", "skates", "spinydogfish", "whitehake", "yellowtailflounderccgom","americanplaiceflounder", "redsilveroffshorehake","redfish","seascallop","squidmackerelbutterfishherrin","winterfloundergb","witchflounder","yellowtailfloundergb", "yellowtailfloundersnema")


#Delete this line for the final version 
stocklist<-c("american_lobster", "cod_gb", "cod_gom")

asc_coefs$spstock2<-0

for (ws in stocklist){ 
  wr<-grep(ws,asc_coefs$X)
  asc_coefs$spstock2[(wr+1):(wr+3)]<-ws
  asc_coefs<-asc_coefs[-wr,]
}

ALL<-asc_coefs[which(asc_coefs$spstock2==0),]
ALL<-ALL[!names(ALL) %in% c("spstock2")]
rownames(ALL)<-ALL[,1]
ALL<-ALL[,-1]

ALL<-as.data.frame(t(ALL))
ALL$gearcat<-rownames(ALL)
rownames(ALL)<-NULL
  


stocks<-asc_coefs[-which(asc_coefs$spstock2==0),]
stocks<-gather(stocks,'GILLNETS','TRAWL', key="gearcat", value="coef")
stocks<-spread(stocks,X,coef)
#transpose and send to dataframe, fix naming, and characters

targeting_coefs<-inner_join(stocks,ALL, by="gearcat")

targeting_coefs$spstock2<- gsub("_","",targeting_coefs$spstock2)


colnames(targeting_coefs)[3:ncol(targeting_coefs)]<-paste0("beta_",colnames(targeting_coefs[3:ncol(targeting_coefs)]))

save(targeting_coefs, file=file.path(savepath, "targeting_coefs.RData"))





