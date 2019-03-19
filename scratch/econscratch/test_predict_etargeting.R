# some code to test "get_predict_etargeting.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


datapath <- 'data/data_processed/econ'
load(file.path(datapath,"full_targeting.RData"))
#End code to test function. Remove when done.





#data wrangling on test datasets  -- once you have a full set of coefficients, you should be able to delete this.
colnames(targeting_dataset)[colnames(targeting_dataset)=="beta_fuel price "] <- "beta_fuel_price"
stocklist<-c("americanlobster", "codgb", "codgom")
test<-targeting_dataset[which(targeting_dataset$spstock2 %in% stocklist),]
tds<-test
#end data wrangling on test dataset




#code to test function. Remove when done.
phat<-get_predict_etargeting(test)
test<-cbind(phat,test)

#Not sure where to put hhat right now, probably overwrite hhat in production_dataset.  


