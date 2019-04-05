# some code to test "get_predict_eproduction.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


datapath <- 'data/data_processed/econ'
load(file.path(datapath,"full_production.RData"))



prod_ds<-production_dataset


#code to test function. Remove when done.
production_outputs<-get_predict_eproduction(production_dataset)

#Not sure where to put hhat right now, probably overwrite hhat in production_dataset.  
#production_dataset<-cbind(production_dataset,hhat)
#production_dataset$hhat<-hhat


