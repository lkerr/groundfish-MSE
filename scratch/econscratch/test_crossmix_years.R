# This is a code fragment that describes how to join the input prices, output prices, and multipliers to the "data"
# You might want to "mix" or cross these to the data. 
# You might be able to do this by a-synchronizing the year in the "data" and the "year_idx" in the multipliers. You would have to 
#    a. un-list the "data"
#    b. change the "join" columns

 
############################################################
#Preamble stuff that is contained in other places.
#load in functions
#set class to not HPCC
#load libraries
#declare some paths to read and save things that I'm scratchpadding
############################################################

# you ran runSim.R and save the bio parameters here
# econsavepath <- 'scratch/econscratch'
# save(bio_params_for_econ,file=file.path(econsavepath,"temp_biop.RData"))

#rm(list=ls())

# empty the environment
rm(list=ls())
set.seed(2) 

source('processes/runSetup.R')
library(microbenchmark)
#library(Rcpp)
econsavepath <- 'scratch/econscratch'
############################################################
############################################################
# Pull in temporary dataset that contains economic data clean them up a little (this is temporary cleaning, so it belongs here)
############################################################
############################################################

load(file.path(econsavepath,"temp_biop.RData"))
#make sure there is a nofish in bio_params_for_econ

#scratchdir<-"/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE/scratch/econscratch"
#Rcpp::sourceCpp(file.path(scratchdir,"matsums.cpp"))

m<-1

econtype<-mproc[m,]
myvars<-c("LandZero","CatchZero","EconType")
econtype<-econtype[myvars]
############################################################
############################################################
# Not sure if there's a cleaner place to put this.  This sets up a container data.frame for each year of the economic model. 
############################################################
############################################################

fishery_holder<-bio_params_for_econ[,c("stocklist_index","stockName","spstock2","sectorACL","nonsector_catch_mt","bio_model","SSB", "mults_allocated", "stockarea","non_mult")]
fishery_holder$underACL<-as.logical("TRUE")
fishery_holder$stockarea_open<-as.logical("TRUE")
fishery_holder$cumul_catch_pounds<-0
fishery_holder$targeted<-0

revenue_holder<-as.list(NULL)
  #source('processes/loadEcon.R')


readin<-0

merge.prod<-0
construct.months<-0
predict.production<-0
merge.inputs<-0
merge.outputs<-0
merge.multipliers<-0
cleanup1<-0
cleanup2<-0
joint.product<-0
e.targeting<-0

top_loop_start<-Sys.time()

myyear<-2015
year_idx<-myyear-2009

#################all this stuff should go into the targeting_data_import step#####################
wm<-multipliers[[year_idx]]
wo<-outputprices[[year_idx]]
wi<-inputprices[[year_idx]]
econdatafile<-paste0("full_targeting_",myyear,".Rds")

targeting_dataset<-readRDS(file.path(econdatapath,econdatafile))
start<-Sys.time()

targeting_dataset<-wm[targeting_dataset, on=c("hullnum","MONTH","spstock2","gffishingyear","post")]
# Probably need something like
targeting_dataset<-as.data.table(unlist(targeting_dataset))
targeting_dataset<-wm[targeting_dataset, on=c("hullnum","MONTH","spstock2")]



# Pull in output prices (day) -- could add this to the wi dataset
targeting_dataset<-wo[targeting_dataset, on=c("doffy","gffishingyear", "post", "gearcat")]

# Pull in input prices (hullnum-day-spstock2)
targeting_dataset<-wi[targeting_dataset, on=c("hullnum","doffy","spstock2","gffishingyear","post")]

targeting_dataset[, fuelprice_len:=fuelprice*len]
targeting_dataset[, fuelprice_distance:=fuelprice*distance]
targeting_dataset[is.na(targeting_dataset)]<-0
merge.multipliers<-merge.multipliers+Sys.time()-start

#################end #####################




              
