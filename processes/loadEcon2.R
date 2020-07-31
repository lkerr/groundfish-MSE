# Read in Economic Production Data. "full_targeting...", "counterfactual..." or "validation..."  is large, so it makes sense to read in each econ_year as needed.

econdatafile<-paste0(econ_data_stub,econ_base_draw,".Rds")
targeting_dataset<-readRDS(file.path(econdatapath,econdatafile))

wm<-multipliers[[econ_mult_idx_draw]]
if ('gffishingyear' %in% colnames(wm)){
  wm[, gffishingyear:=NULL]
}
wo<-outputprices[[econ_outputprice_idx_draw]]
if ('gffishingyear' %in% colnames(wo)){
  wo[, gffishingyear:=NULL]
}
wi<-inputprices[[econ_inputprice_idx_draw]]
if ('gffishingyear' %in% colnames(wi)){
  wi[, gffishingyear:=NULL]
}
#temp for debugging
#targeting_dataset$prhat<-targeting_dataset$pr

#This would be a good place to adjust any indep variables in the targeting_dataset. (like forcing the fy dummy to a different value 






