# some code to test "get_predict_eproduction.R"


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))

econsavepath<-'scratch/econscratch'
econdatapath <- 'data/data_processed/econ'
load(file.path(econdatapath,"full_production.RData"))



prod_ds<-production_dataset


#code to test function. Remove when done.
production_outputs<-get_predict_eproduction(production_dataset)


#here, subset prod_ds to just contain the cols in mysubs
#then try to rerun the get_predict_eproduction on that and see if it works

needcols<-c("hullnum2","date","spstock2","gearcat","h_hat")
tester<-prod_ds[needcols]

production_outputs<-left_join(production_outputs,tester, by=c("hullnum2", "date", "spstock2"))
production_outputs$delta<-production_outputs$harvest_sim-production_outputs$h_hat
summary(production_outputs$delta)

#We see maximum differences of magnitude 0.07 (7 hundredths of a pound), which is probably due to rounding differences.  I think stata will use quad precision internally, but only export in double precisions.  This is NBD.


