# Set up a container dataframe that contains:
# year, nomyear  
# row of mproc
# Gross Revenues
# Other Fleet-level performance metrics 


econ_outputs<-data.frame()
  yx0 = rep(NA, nyear)
  yearvec<- 1:nyear
  mproc_vec <- 1:nrow(mproc)
  
  econ_outputs<-merge(yearvec,mproc_vec, by=NULL)
  colnames(econ_outputs)<-c("year","nmproc")
  econ_outputs$Gross_Revenue<-  NA
  econ_outputs$Gini<-  NA
  econ_outputs$Gross_GF_Revenue<-  NA
  
  




