# Read in Economic Production Data


targeting_dataset<-readRDS(file.path(econdatapath,econdatafile))
targeting_dataset[is.na(targeting_dataset)]<-0

targeting_coefs<-readRDS(file.path(econdatapath,target_coefs))
production_coefs<-readRDS(file.path(econdatapath, production_coefs))

multipliers<-readRDS(file.path(econdatapath, multiplier_loc))
outputprices<-readRDS(file.path(econdatapath, output_price_loc))

inputprices<-readRDS(file.path(econdatapath, input_price_loc))

#temp for debugging
#targeting_dataset$prhat<-targeting_dataset$pr



#load(file.path(econdatapath,"full_production.RData"))
#production_dataset[is.na(production_dataset)]<-0
#production_dataset<-production_dataset[which(production_dataset$gffishingyear %in% baseEconYrs),]
#production_dataset<-split(production_dataset, production_dataset$doffy)






