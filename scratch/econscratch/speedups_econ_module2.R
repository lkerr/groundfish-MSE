#load in targeting data

#rm(list=ls())
# set.seed(2) 

# empty the environment
rm(list=ls())

source('processes/runSetup.R')
source('processes/loadEcon.R')
library(microbenchmark)





datapath <- 'data/data_processed/econ'
targeting_dataset<-readRDS(file.path(datapath,"full_targeting.Rds"))





#data wrangling on test datasets  -- once you have a full set of coefficients, you should be able to delete this.
tds<-as.data.table(head(targeting_dataset,5000))
#end data wrangling on test dataset



#code to test function. Remove when done.
harvest_sim<-get_predict_eproduction(tds)

#here, subset prod_ds to just contain the cols in mysubs
#then try to rerun the get_predict_eproduction on that and see if it works








  tds<-cbind(tds,harvest_sim)







microbenchmark(ans_cf<-sq(), ans_cb <- cbind_style(), times=100)










