# Read in Economic Production Data

econdatapath <- 'data/data_processed/econ'
load(file.path(econdatapath,"full_targeting.RData"))
load(file.path(econdatapath,"full_production.RData"))
production_dataset[is.na(production_dataset)]<-0
targeting_dataset[is.na(targeting_dataset)]<-0

production_dataset<-production_dataset[which(production_dataset$gffishingyear %in% baseEconYrs),]
targeting_dataset<-targeting_dataset[which(targeting_dataset$gffishingyear %in% baseEconYrs),]

# Add nchoices column to the targeting dataset
targeting_dataset<- targeting_dataset   %>%
  group_by(id) %>%
  mutate(nchoices=n())

#temp for debugging
targeting_dataset$prhat<-targeting_dataset$pr

targeting_dataset<-data.table(targeting_dataset)
#split the production and targeting datasets into a list of datasets
production_dataset<-split(production_dataset, production_dataset$doffy)
targeting_dataset<-split(targeting_dataset, targeting_dataset$doffy)

