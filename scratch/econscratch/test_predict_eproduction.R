# some code to test "get_predict_eproduction.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))

savepath<-'scratch/econscratch'
datapath <- 'data/data_processed/econ'
load(file.path(datapath,"full_production.RData"))



prod_ds<-production_dataset


#code to test function. Remove when done.
production_outputs<-get_predict_eproduction(production_dataset)


#here, subset prod_ds to just contain the cols in mysubs
#then try to rerun the get_predict_eproduction on that and see if it works




#Not sure where to put hhat right now, probably overwrite hhat in production_dataset.  
#production_dataset<-cbind(production_dataset,hhat)
#production_dataset$hhat<-hhat


