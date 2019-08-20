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


for (wy in 2010:2015) {
targeting_source<-paste0("econ_data_",wy,".dta")
savefile<-paste0("full_targeting_",wy,".Rds")
gc()

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
targeting$doffy=as.integer(difftime(targeting$date,targeting$startfy, units="days")+1)

#Follow naming conventions
targeting$spstock2<-tolower(targeting$spstock2)
targeting$spstock2<- gsub("_","",targeting$spstock2)

colnames(targeting)[colnames(targeting)=="LApermit"] <- "lapermit"
targeting$primary<-as.integer(1)
targeting$secondary<-as.integer(0)

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
#targeting<-left_join(targeting,targeting_coefs,by=c("gearcat","spstock2","post"))

targeting<-left_join(targeting,targeting_coefs,by=c("gearcat","spstock2"))
cols_final2<-ncol(targeting)
count_rows_post2<-nrow(targeting)
gc()
cols_tc<-ncol(targeting_coefs)

#same number of rows. Sum of number of columns, minus the 2 merge columns
if(cols_final2 !=(cols_final+cols_tc-2)){
  warning("Lost some Columns from the targeting dataset")
}
if(count_rows_post2 !=(count_rows_post)){
  warning("Lost some Rows from the targeting dataset")
}


targeting$spstock2<- gsub("gb","GB",targeting$spstock2)
targeting$spstock2<- gsub("ccgom","CCGOM",targeting$spstock2)
targeting$spstock2<- gsub("gom","GOM",targeting$spstock2)
targeting$spstock2<- gsub("snema","SNEMA",targeting$spstock2)



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

#Flag 1 row per gffishingyear, date, hullnum, id. This means instead of doing a unique, we can do a subset.
# Somethign like this retains only the first row tds<-tds[tds[, .I[1], by = id]$V1] 
targeting<-targeting %>% 
  group_by(id) %>% 
  mutate(idflag = row_number())

targeting$idflag[targeting$idflag>1]<-as.integer(0)
targeting<-as.data.table(targeting)

gc()


keycols<-c("gffishingyear","date", "hullnum", "id","spstock2")
setorderv(targeting, keycols)

spstock_equation=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
choice_equation=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")

targeting_vars=c(spstock_equation, choice_equation)

betavars=paste0("beta_",targeting_vars)
betavars=c(betavars,"beta_constant")


production_vars=c("log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","constant")
alphavars=paste0("alpha_",production_vars)

td_cols<-colnames(targeting)

fydums<-td_cols[grepl("^fy20", td_cols)]
fycoefs<-td_cols[grepl("^alpha_fy20", td_cols)]

monthdums<-td_cols[grepl("^month", td_cols)]
monthcoefs<-td_cols[grepl("^alpha_month", td_cols)]

cmultipliers<-td_cols[grepl("^c_", td_cols)]
lmultipliers<-td_cols[grepl("^l_", td_cols)]
quota_prices<-td_cols[grepl("^q_", td_cols)]
lag_output_prices<-td_cols[grepl("^p_", td_cols)]
output_prices<-td_cols[grepl("^r_", td_cols)]



idvars=c("id", "hullnum", "date","spstock2", "doffy")
necessary=c("q", "gffishingyear", "emean","nchoices", "idflag")
useful=c("gearcat","post","h_hat","pr","choice")
useful=c("gearcat","post","h_hat","choice")

mysubs=c(idvars,necessary,useful,fydums, monthdums, fycoefs, monthcoefs, targeting_vars,betavars,production_vars, alphavars, cmultipliers, lmultipliers, quota_prices, output_prices,lag_output_prices)

targeting<-targeting[, ..mysubs]


#there will be na values here because the nofish option is full of nas.  push these to zeros.

targeting[is.na(targeting)]<-0

#The targeting should have no NA values
sum(is.na(targeting))==0

# If that fails, use this to figure out which colSums(is.na(targeting))
#keycols<-c("gffishingyear","date", "hullnum", "id","spstock2")
#setorderv(targeting, keycols)

saveRDS(targeting, file=file.path(econsavepath, savefile))
rm(targeting)
gc()
}

#rm(list=ls())






