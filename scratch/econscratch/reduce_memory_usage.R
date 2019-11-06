
# empty the environment
rm(list=ls())
set.seed(2) 

source('processes/runSetup.R')
library(microbenchmark)

m<-1

econtype<-mproc[m,]
myvars<-c("LandZero","CatchZero","EconType")
econtype<-econtype[myvars]
############################################################
############################################################
# It's better to store the production coefficients, targeting coefficients, and multipliers in three separate data.tables. Then use the DT join to pull them together
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

revenue_holder<-as.list(NULL)
#source('processes/loadEcon.R')

#Initialize the trips data.table. I need it to store the previous choice.
keepcols<-c("hullnum","spstock2","choice_prev_fish")
trips<-copy(targeting_dataset[[1]])
trips<-trips[, ..keepcols]
trips<-trips[spstock2!="nofish"]
colnames(trips)[3]<-"targeted"



#Load in targeting coefficients
targeting_coefs<-readRDS(file.path(econdatapath,"targeting_coefs.Rds"))
production_coefs<-readRDS(file.path(econdatapath,"production_coefs.Rds"))

colnames(targeting_coefs)[colnames(targeting_coefs)=="beta_LApermit"] <- "beta_lapermit"
targeting_coefs$spstock2<-tolower(targeting_coefs$spstock2)


baseEconYr<-2015
econdatapath <- 'data/data_processed/econ'
econdatafile<-paste0("full_targeting_",baseEconYr,".Rds")
targeting_dataset_bak<-readRDS(file.path(econdatapath,econdatafile))
targeting_dataset_bak[is.na(targeting_dataset_bak)]<-0

  targeting_dataset<-copy(targeting_dataset_bak)

  #temp for debugging
  #targeting_dataset$prhat<-targeting_dataset$pr
  
  targeting_dataset<-data.table(targeting_dataset)
  keycols<-c("id","spstock2")
  setkeyv(targeting_dataset, keycols)
  dropcols<-c(grep("^fy20", colnames(targeting_dataset)),grep("^alpha_month", colnames(targeting_dataset)))
  
  targeting_dataset[, (dropcols):=NULL]
  dropcols<-c(grep("^alpha", colnames(targeting_dataset)),grep("^beta", colnames(targeting_dataset)))
  targeting_dataset[, (dropcols):=NULL]
  dropcols<-c(grep("^p_", colnames(targeting_dataset)),grep("^l_", colnames(targeting_dataset)))
  targeting_dataset[, (dropcols):=NULL]
  dropcols<-c(grep("^q_", colnames(targeting_dataset)),grep("^r_", colnames(targeting_dataset)))
  targeting_dataset[, (dropcols):=NULL]
  dropcols<-c(grep("^c_", colnames(targeting_dataset)),grep("month", colnames(targeting_dataset)))
  targeting_dataset[, (dropcols):=NULL]
  
  format(object.size(targeting_dataset), units="Mb")

  targeting_dataset<-split(targeting_dataset, targeting_dataset$doffy)
  targeting_dataset_bak<-split(targeting_dataset_bak, targeting_dataset_bak$doffy)
  
  
    #method 2
  top_loop_start2<-Sys.time()
  
  for (day in 1:365){
    #   subset both the targeting and production datasets based on date and jams them to data.tables
    # Subset for the day.  Predict targeting
    working_targeting<-copy(targeting_dataset[[day]])
   #Merge production
    working_targeting<-working_targeting[production_coefs,on=c("gearcat","spstock2","post")]
    working_targeting<-working_targeting[targeting_coefs,on=c("gearcat","spstock2")]
    
  }
  
  
  top_loop_end2<-Sys.time()
  method2<-top_loop_end2-top_loop_start2
  
  
  

