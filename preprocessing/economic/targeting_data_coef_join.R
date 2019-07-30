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
if(!require(data.table)) {  
  install.packages("data.table")
  require(data.table)}


# file paths for the raw and final directories

econrawpath <- './data/data_raw/econ'
econsavepath <- './data/data_processed/econ'

#Files to read -- sample data for now.
#targeting_source<-"sample_PRODREGdata_fys2009_2010_forML.dta"
targeting_source<-"sample_DCdata_fys2009_2010_forML.dta"


#Load in targeting coefficients
targeting_coefs<-readRDS(file.path(econsavepath,"targeting_coefs.Rds"))
production_coefs<-readRDS(file.path(econsavepath,"production_coefs.Rds"))

colnames(targeting_coefs)[colnames(targeting_coefs)=="beta_LApermit"] <- "beta_lapermit"
targeting_coefs$spstock2<-tolower(targeting_coefs$spstock2)

# read in the dataset
targeting <- read.dta13(file.path(econrawpath, targeting_source))


# My current 
if("emean" %in% colnames(targeting)){
  print("Yep, it's in there!")
} else {
  warning('emean hack, production predictions will be wrong')
  targeting$emean<-1
}  
  
  



targeting$startfy = paste("5", "1",targeting$gffishingyear,sep=".")
targeting$startfy = as.Date(paste("5", "1",targeting$gffishingyear,sep="."), "%m.%d.%Y")
targeting$doffy=as.numeric(difftime(targeting$date,targeting$startfy, units="days")+1)

#Follow naming conventions
targeting$spstock2<-tolower(targeting$spstock2)
targeting$spstock2<- gsub("_","",targeting$spstock2)

colnames(targeting)[colnames(targeting)=="LApermit"] <- "lapermit"

# HANDLE missings and NA.
# Crew and trip_days is coded as zero for no-fish. We will set these to NA.
# trawl_survey_weight is coded as NA if it's missing. Nothing to do here.

#targeting$crew[targeting$crew==0]<-NA
#targeting$trip_days[targeting$trip_days==0]<-NA

# Take Logs of these three
# targeting$log_crew<-log(targeting$crew)
# targeting$log_trip_days<-log(targeting$trip_days)
# targeting$log_trawl_survey_weight<-log(targeting$trawl_survey_weight)

# Set the log-values to zero.This is kludgy 

targeting$log_crew[is.na(targeting$log_crew)]<-0
targeting$log_trip_days[is.na(targeting$log_trip_days)]<-0
targeting$log_trawl_survey_weight[is.na(targeting$log_trawl_survey_weight)]<-0

#handle the no fish option
targeting_dataset$log_avg_crew[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$log_trip_days[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$log_crew[which(targeting_dataset$spstock2=="nofish")]<-0


targeting$primary<-1
targeting$secondary<-0

count_rows<-nrow(targeting)
cols_t<-ncol(targeting)


#pull in the targeting dataset
# note that left_join converts things to data.frames (not data.tables)
targeting<-left_join(targeting,production_coefs,by=c("gearcat","spstock2","post"))
count_rows_post<-nrow(targeting)
cols_pc<-ncol(production_coefs)
cols_final<-ncol(targeting)

#same number of rows.  sum of columns, minus the 3 merge columns
cols_final==(cols_pc+cols_t-3)
count_rows_post==count_rows


#same number of rows. Sum of number of columns, minus the 2 merge columns
if(cols_final !=(cols_pc+cols_t-3)){
  warning("Lost some Columns from the production-join")
}
if(count_rows_post !=(count_rows)){
  warning("Lost some Rows from the production-join")
}

# merge targeting dataset and coefficients
# Note, you'll have some NAs for some rows, especially no fish.
# Currently, I only have targeting coefficients for the pre-period.
#targeting_dataset<-left_join(targeting,targeting_coefs,by=c("gearcat","spstock2","post"))

targeting_dataset<-left_join(targeting,targeting_coefs,by=c("gearcat","spstock2"))
cols_final2<-ncol(targeting_dataset)
count_rows_post2<-nrow(targeting_dataset)

cols_tc<-ncol(targeting_coefs)

#same number of rows. Sum of number of columns, minus the 2 merge columns
if(cols_final2 !=(cols_final+cols_tc-2)){
  warning("Lost some Columns from the targeting dataset")
}
if(count_rows_post2 !=(count_rows_post)){
  warning("Lost some Rows from the targeting dataset")
}


targeting_dataset$spstock2<- gsub("gb","GB",targeting_dataset$spstock2)
targeting_dataset$spstock2<- gsub("ccgom","CCGOM",targeting_dataset$spstock2)
targeting_dataset$spstock2<- gsub("gom","GOM",targeting_dataset$spstock2)
targeting_dataset$spstock2<- gsub("snema","SNEMA",targeting_dataset$spstock2)



targeting_dataset$constant<- 1



targeting_dataset$month1<-as.numeric(targeting_dataset$month==1)
targeting_dataset$month2<-as.numeric(targeting_dataset$month==2)
targeting_dataset$month3<-as.numeric(targeting_dataset$month==3)
targeting_dataset$month4<-as.numeric(targeting_dataset$month==4)
targeting_dataset$month5<-as.numeric(targeting_dataset$month==5)
targeting_dataset$month6<-as.numeric(targeting_dataset$month==6)
targeting_dataset$month7<-as.numeric(targeting_dataset$month==7)
targeting_dataset$month8<-as.numeric(targeting_dataset$month==8)
targeting_dataset$month9<-as.numeric(targeting_dataset$month==9)
targeting_dataset$month10<-as.numeric(targeting_dataset$month==10)
targeting_dataset$month11<-as.numeric(targeting_dataset$month==11)
targeting_dataset$month12<-as.numeric(targeting_dataset$month==12)

targeting_dataset$fy2004<-as.numeric(targeting_dataset$gffishingyear==2004)
targeting_dataset$fy2005<-as.numeric(targeting_dataset$gffishingyear==2005)
targeting_dataset$fy2006<-as.numeric(targeting_dataset$gffishingyear==2006)
targeting_dataset$fy2007<-as.numeric(targeting_dataset$gffishingyear==2007)
targeting_dataset$fy2008<-as.numeric(targeting_dataset$gffishingyear==2008)
targeting_dataset$fy2009<-as.numeric(targeting_dataset$gffishingyear==2009)
targeting_dataset$fy2010<-as.numeric(targeting_dataset$gffishingyear==2010)
targeting_dataset$fy2011<-as.numeric(targeting_dataset$gffishingyear==2011)
targeting_dataset$fy2012<-as.numeric(targeting_dataset$gffishingyear==2012)
targeting_dataset$fy2013<-as.numeric(targeting_dataset$gffishingyear==2013)
targeting_dataset$fy2014<-as.numeric(targeting_dataset$gffishingyear==2014)
targeting_dataset$fy2015<-as.numeric(targeting_dataset$gffishingyear==2015)

#there will be na values here because the nofish option is full of nas.  push these to zeros.

targeting_dataset[is.na(targeting_dataset)]<-0




# Add nchoices column to the targeting dataset
targeting_dataset<- targeting_dataset   %>%
  group_by(id) %>%
  mutate(nchoices=n())

#Flag 1 row per gffishingyear, date, hullnum, id. This means instead of doing a unique, we can do a subset.
# Somethign like this retains only the first row tds<-tds[tds[, .I[1], by = id]$V1] 
targeting_dataset<-targeting_dataset %>% 
  group_by(id) %>% 
  mutate(idflag = row_number())

targeting_dataset$idflag[targeting_dataset$idflag>1]<-0
targeting_dataset<-as.data.table(targeting_dataset)




keycols<-c("gffishingyear","date", "hullnum", "id","spstock2")
setorderv(targeting_dataset, keycols)

spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len", "das_price_mean", "das_price_mean_len")

targeting_vars=c(spstock_equation, choice_equation)

betavars=paste0("beta_",targeting_vars)
betavars=c(betavars,"beta_constant")

#stop here. Assert that all the targeting and beta variables are zero for spstock2=="nofish"
test<-targeting_dataset[which(spstock2=="nofish")]
#table gffishingyear
# we will convert all the RHS variables and corresponding coefficients to zero for spstock=="nofish". This will force the eventual prediction of xb=0 and exp(xb)=1. This seems a little silly, but will be faster than doing setting them to 1 later on in the loop.
#also, you should really have written an lapply here.so lame

targeting_dataset$exp_rev_total[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$fuelprice_distance[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$distance[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$mean_wind[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$mean_wind_noreast[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$permitted[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$choice_prev_fish[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$partial_closure[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$start_of_season[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$wkly_crew_wage[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$len[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$fuelprice[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$fuelprice_len[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$das_price_mean[which(targeting_dataset$spstock2=="nofish")]<-0
targeting_dataset$das_price_mean_len[which(targeting_dataset$spstock2=="nofish")]<-0




production_vars=c("log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","constant")
alphavars=paste0("alpha_",production_vars)

td_cols<-colnames(targeting_dataset)

fydums<-td_cols[grepl("^fy20", td_cols)]
fycoefs<-td_cols[grepl("^alpha_fy20", td_cols)]

monthdums<-td_cols[grepl("^month", td_cols)]
monthcoefs<-td_cols[grepl("^alpha_month", td_cols)]



idvars=c("id", "hullnum", "date","spstock2", "doffy")
necessary=c("landing_multiplier_dollars", "catch_multiplier_dollars", "q", "gffishingyear", "emean","price_lb_lag1", "nchoices", "idflag")
useful=c("gearcat","post","h_hat","pr","choice")
mysubs=c(idvars,necessary,useful,fydums, monthdums, fycoefs, monthcoefs, targeting_vars,betavars,production_vars, alphavars)
#mysubs=c(idvars,necessary,useful,targeting_vars,betavars)
#mysubs=c(idvars,production_vars, alphavars, fydums, monthdums, fycoefs, monthcoefs,"q", "emean")



targeting_dataset<-targeting_dataset[, ..mysubs]
#The targeting_dataset should have no NA values
sum(is.na(targeting_dataset))==0

# If that fails, use this to figure out which colSums(is.na(targeting_dataset))
keycols<-c("gffishingyear","date", "hullnum", "id","spstock2")
setorderv(targeting_dataset, keycols)


saveRDS(targeting_dataset, file=file.path(econsavepath, "full_targeting.Rds"))

#  print(unique(warnings()))

#rm(list=ls())






