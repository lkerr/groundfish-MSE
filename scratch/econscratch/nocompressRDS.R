
# empty the environment
library(microbenchmark)
econdatapath <- 'data/data_processed/econ'
econdatafile<-paste0("full_targeting_",myyear,".Rds")

econdatafile2<-paste0("full_targeting_datalist.Rds")
targeting_dataset2<-readRDS(file.path(econdatapath,econdatafile2))


sq<-function(){
  econdatafile<-paste0("full_targeting_",myyear,".Rds")
  targeting_dataset<-readRDS(file.path(econdatapath,econdatafile))
}


all_in<-function(){
wt<-targeting_dataset2[[2]]
  }

microbenchmark(ans_cf<-all_in(), times=10)


# If I load a new block of data every economic year, this adds about 2.5 seconds per simulated economic year. But I'm only holding a small dataset of ~435mb in momory.
# If I load all data into a list and then subset that list, I now have to hold 6 times as much data in memory (2552mb). 



