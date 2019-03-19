# some code to test "get_predict_etargeting.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


datapath <- 'data/data_processed/econ'
load(file.path(datapath,"full_targeting.RData"))
#End code to test function. Remove when done.





#data wrangling on test datasets  -- once you have a full set of coefficients, you should be able to delete this.
omitlist<-c("hiho")
tds<-targeting_dataset
#end data wrangling on test dataset




#code to test function. Remove when done.
phat<-get_predict_etargeting(targeting_dataset)
targeting_dataset<-cbind(phat,targeting_dataset)

#Not sure where to put hhat right now, probably overwrite hhat in production_dataset.  


