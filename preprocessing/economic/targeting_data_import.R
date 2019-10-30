# This pre-processing file:
  # 1. Pulls in the targeting equation coefficients and data
  # 2. Joins them together (based on spstock2 and  gearcat). 
  #.3. Drop unnecessary variables.
# A little stupid to join the coefficients to the data, because it make a big dataset with lots of replicated data, instead of making a pair of matrices (one for data and one for coefficients). But whatever.
# need to update this file with variable changes and equation changes. Anna is sending over a stata .ster. for coefficients


target_coefs<-target_coef_outfile
production_coefs<-production_outfile

targeting_coefs<-readRDS(file.path(savepath,target_coefs))

production_coefs<-readRDS(file.path(savepath, production_coefs))
production_coefs[, post:=NULL]



inputprices<-readRDS(file.path(savepath, input_working))
multipliers<-readRDS(file.path(savepath, multiplier_working))
outputprices<-readRDS(file.path(savepath, output_working))


#for the counterfactual, we do something else -- we need average multipliers by hullnum, MONTH, spstock2.





for (wy in 2010:2015) {
    idx<-wy-2009
    
  yrsavefile<-paste0(yearly_savename,wy,".Rds")
  targeting_source<-paste0(yrstub,"_",wy,".dta")
  
  targeting <- read.dta13(file.path(rawpath, targeting_source))
  
  # Not quite right. I
  if (yearly_savename =="counterfactual"){
    wm<-rbindlist(multipliers)
    mygroup<-c("hullnum", "MONTH", "spstock2")
    wm<-wm[, lapply(.SD,mean), by=mygroup]
  }else {
  wm<-multipliers[[idx]]
  }
  wm[, gffishingyear:=NULL]
  
  wo<-outputprices[[idx]]
  wo[, gffishingyear:=NULL]
  
  wi<-inputprices[[idx]]
  wi[, gffishingyear:=NULL]
  
  
  
  

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
targeting<-production_coefs[targeting, on=c("spstock2","gearcat")]
targeting<-targeting_coefs[targeting, on=c("spstock2","gearcat")]



keycols<-c("gffishingyear","doffy", "hullnum", "id","spstock2")
setorderv(targeting, keycols)

td_cols<-colnames(targeting)

##################################  JOINS START HERE. We're processing over years, so no need to join on GFFISHINGYEAR or POST ###############
# Bring in multipliers
colnames(targeting)[colnames(targeting)=="month"] <- "MONTH"

targeting<-wm[targeting, on=c("hullnum","MONTH","spstock2")]

# Pull in output prices (day) -- could add this to the wi dataset
targeting<-wo[targeting, on=c("doffy", "gearcat")]

# Pull in input prices (hullnum-day-spstock2)
targeting<-wi[targeting, on=c("hullnum","doffy","spstock2")]
##################################  JOINS END HERE ###############

targeting[, fuelprice_len:=fuelprice*len]
targeting[, fuelprice_distance:=fuelprice*distance]


td_cols<-colnames(targeting)

 # We don't need every column, so this section of code keeps just the columns we need.
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
necessary=c("q", "gffishingyear", "emean","nchoices", "MONTH")

mysubs=c(idvars,necessary,useful_vars, targeting_vars, production_vars, fyvars, monthvars, betavars, alphavars, cmultipliers, lmultipliers, quota_prices, lag_output_prices, output_prices)

targeting<-targeting[, ..mysubs]


#there will be na values here because the nofish option is full of nas.  push these to zeros.

targeting[is.na(targeting)]<-0

#The targeting should have no NA values
sum(is.na(targeting))==0

# If that fails, use this to figure out which colSums(is.na(targeting))
#keycols<-c("gffishingyear","date", "hullnum", "id","spstock2")
#setorderv(targeting, keycols)

#the id is the distinct "hullnum-date" combination.  date encompasses gffishingyear and doffy.
# so I really only need 2 key columns (id and spstock2)
setkeyv(targeting, c("id","spstock2"))
targeting<-split(targeting, targeting$doffy)

saveRDS(targeting, file=file.path(savepath, yrsavefile),compress=FALSE)

rm(targeting)
gc()

}
#rm(list=ls())






