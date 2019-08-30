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
econdatapath <- 'data/data_processed/econ'

savefile<-"full_targeting_datalist.Rds"

target_coefs<-"targeting_coefs.Rds"
production_coefs<-"production_coefs.Rds"



targeting_coefs<-readRDS(file.path(econdatapath,target_coefs))
production_coefs<-readRDS(file.path(econdatapath, production_coefs))

multiplier_loc<-"sim_multipliers_post.Rds"
output_price_loc<-"sim_prices_post.Rds"
input_price_loc<-"sim_post_vessel_stock_prices.Rds"

multipliers<-readRDS(file.path(econdatapath, multiplier_loc))
outputprices<-readRDS(file.path(econdatapath, output_price_loc))

inputprices<-readRDS(file.path(econdatapath, input_price_loc))




for (wy in 2011:2015) {
    idx<-wy-2009
  
  yrsavefile<-paste0("full_targeting_",wy,".Rds")
  targeting_source<-paste0("econ_data_",wy,".dta")
  
  targeting <- read.dta13(file.path(econrawpath, targeting_source))
  
  
  
  
  wm<-multipliers[[idx]]
  wo<-outputprices[[idx]]
  wi<-inputprices[[idx]]
  
  
  

# My current 
if("emean" %in% colnames(targeting)){
  print("Yep, it's in there!")
} else {
  warning('emean hack, production predictions will be wrong')
  targeting$emean<-1
}  
targeting$startfy = paste("5", "1",targeting$gffishingyear,sep=".")
targeting$startfy = as.Date(paste("5", "1",targeting$gffishingyear,sep="."), "%m.%d.%Y")
targeting$doffy=as.integer(difftime(targeting$date,targeting$startfy, units="days")+1)

#Follow naming conventions
targeting$spstock2<-tolower(targeting$spstock2)
targeting$spstock2<- gsub("_","",targeting$spstock2)


targeting$spstock2<- gsub("gb","GB",targeting$spstock2)
targeting$spstock2<- gsub("ccgom","CCGOM",targeting$spstock2)
targeting$spstock2<- gsub("gom","GOM",targeting$spstock2)
targeting$spstock2<- gsub("snema","SNEMA",targeting$spstock2)

# need to fix up these.


colnames(targeting)[colnames(targeting)=="LApermit"] <- "lapermit"
targeting$primary<-as.integer(1)
targeting$secondary<-as.integer(0)
targeting$constant<- as.numeric(1)



targeting$month1<-as.integer(targeting$month==1)
targeting$month2<-as.integer(targeting$month==2)
targeting$month3<-as.integer(targeting$month==3)
targeting$month4<-as.integer(targeting$month==4)
targeting$month5<-as.integer(targeting$month==5)
targeting$month6<-as.integer(targeting$month==6)
targeting$month7<-as.integer(targeting$month==7)
targeting$month8<-as.integer(targeting$month==8)
targeting$month9<-as.integer(targeting$month==9)
targeting$month10<-as.integer(targeting$month==10)
targeting$month11<-as.integer(targeting$month==11)
targeting$month12<-as.integer(targeting$month==12)

targeting$fy2004<-as.integer(targeting$gffishingyear==2004)
targeting$fy2005<-as.integer(targeting$gffishingyear==2005)
targeting$fy2006<-as.integer(targeting$gffishingyear==2006)
targeting$fy2007<-as.integer(targeting$gffishingyear==2007)
targeting$fy2008<-as.integer(targeting$gffishingyear==2008)
targeting$fy2009<-as.integer(targeting$gffishingyear==2009)
targeting$fy2010<-as.integer(targeting$gffishingyear==2010)
targeting$fy2011<-as.integer(targeting$gffishingyear==2011)
targeting$fy2012<-as.integer(targeting$gffishingyear==2012)
targeting$fy2013<-as.integer(targeting$gffishingyear==2013)
targeting$fy2014<-as.integer(targeting$gffishingyear==2014)
targeting$fy2015<-as.integer(targeting$gffishingyear==2015)





# Add nchoices column to the targeting dataset
targeting<- targeting   %>%
  group_by(id) %>%
  mutate(nchoices=n())


targeting<-as.data.table(targeting)
gc()
# pull in coefficients
targeting<-production_coefs[targeting, on=c("spstock2","gearcat","post")]
targeting<-targeting_coefs[targeting, on=c("gearcat","spstock2")]



keycols<-c("gffishingyear","doffy", "hullnum", "id","spstock2")
setorderv(targeting, keycols)

spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
#spstock_equation=c("exp_rev_total",  "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")

choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")
#choice_equation=c("len" )


targeting_vars=c(spstock_equation, choice_equation)
production_vars=c("log_crew","log_trip_days","log_trawl_survey_weight","primary", "secondary", "constant")

td_cols<-colnames(targeting)


# Bring in multipliers
colnames(targeting)[colnames(targeting)=="month"] <- "MONTH"

targeting<-wm[targeting, on=c("hullnum","MONTH","spstock2","gffishingyear","post")]

# Pull in output prices (day) -- could add this to the wi dataset
targeting<-wo[targeting, on=c("doffy","gffishingyear", "post", "gearcat")]

# Pull in input prices (hullnum-day-spstock2)
targeting<-wi[targeting, on=c("hullnum","doffy","spstock2","gffishingyear","post")]

targeting[, fuelprice_len:=fuelprice*len]
targeting[, fuelprice_distance:=fuelprice*distance]
targeting[is.na(targeting)]<-0

td_cols<-colnames(targeting)

 
 cmultipliers<-td_cols[grepl("^c_", td_cols)]
 lmultipliers<-td_cols[grepl("^l_", td_cols)]
 quota_prices<-td_cols[grepl("^q_", td_cols)]
 lag_output_prices<-td_cols[grepl("^p_", td_cols)]
 output_prices<-td_cols[grepl("^r_", td_cols)]
# notinsubs<-c(betavars,production_vars, alphavars, cmultipliers, lmultipliers, quota_prices, output_prices,lag_output_prices)

betavars<-grep("^beta",colnames(targeting) , value=TRUE)
alphavars<-grep("^alpha",colnames(targeting) , value=TRUE)

fyvars<-grep("^fy",colnames(targeting) , value=TRUE)
monthvars<-grep("^month",colnames(targeting) , value=TRUE)

idvars=c("id", "hullnum","spstock2", "doffy")
necessary=c("q", "gffishingyear", "emean","nchoices", "idflag")
necessary=c("q", "gffishingyear", "emean","nchoices", "MONTH")
useful=c("gearcat","post","h_hat","xb_post","choice")
#useful=c("gearcat","post","h_hat","choice")

mysubs=c(idvars,necessary,useful, targeting_vars, production_vars, fyvars, monthvars, betavars, alphavars, cmultipliers, lmultipliers, quota_prices, lag_output_prices, output_prices)

targeting<-targeting[, ..mysubs]


#there will be na values here because the nofish option is full of nas.  push these to zeros.

targeting[is.na(targeting)]<-0

#The targeting should have no NA values
sum(is.na(targeting))==0

# If that fails, use this to figure out which colSums(is.na(targeting))
#keycols<-c("gffishingyear","date", "hullnum", "id","spstock2")
#setorderv(targeting, keycols)


targeting<-split(targeting, targeting$doffy)

saveRDS(targeting, file=file.path(econdatapath, yrsavefile),compress=FALSE)

rm(targeting)
gc()

}
#rm(list=ls())






