# Read in Economic Production Data

econdatapath <- 'data/data_processed/econ'
targeting_dataset<-readRDS(file.path(econdatapath,"full_targeting.Rds"))
targeting_dataset[is.na(targeting_dataset)]<-0

targeting_dataset<-targeting_dataset[which(targeting_dataset$gffishingyear %in% baseEconYrs),]


#temp for debugging
#targeting_dataset$prhat<-targeting_dataset$pr

targeting_dataset<-data.table(targeting_dataset)
#split the targeting dataset into a list of datasets
targeting_dataset<-split(targeting_dataset, targeting_dataset$doffy)


#load(file.path(econdatapath,"full_production.RData"))
#production_dataset[is.na(production_dataset)]<-0
#production_dataset<-production_dataset[which(production_dataset$gffishingyear %in% baseEconYrs),]
#production_dataset<-split(production_dataset, production_dataset$doffy)






