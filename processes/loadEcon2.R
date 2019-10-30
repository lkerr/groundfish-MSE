# Read in Economic Production Data. "full_targeting" is large, so it makes sense to read in each econ_year as needed.

econdatafile<-paste0(econ_data_stub,econ_year_draw,".Rds")
targeting_dataset<-readRDS(file.path(econdatapath,econdatafile))

wm<-multipliers[[econ_idx_draw]]
wm[, gffishingyear:=NULL]

wo<-outputprices[[econ_idx_draw]]
wo[, gffishingyear:=NULL]

wi<-inputprices[[econ_idx_draw]]
wi[, gffishingyear:=NULL]

#temp for debugging
#targeting_dataset$prhat<-targeting_dataset$pr

#This would be a good place to adjust any indep variables in the targeting_dataset. (like forcing the fy dummy to a different value 






