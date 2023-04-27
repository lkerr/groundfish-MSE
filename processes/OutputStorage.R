# This process is designed to store results in a list. It does not save that list to the disk.

# Read in some information from stock to compute derived statistics
cwdata<-NULL
for(i in 1:nstock){
  z<-data.frame( stock[[i]]$stockName,stock[[i]]$sumCW[y], stock[[i]]$SSB[y])
  names(z)<-c("stockName", "catch", "SSB")
  cwdata<-rbind(cwdata, z)
}
rm(z)
#Compute Fleet level HHI and shannon index. Store fishery-year level results
HHI<-get_HHI(cwdata, "catch")
shannon<-get_shannon(cwdata, "catch")
Theil_managed_CtoB<-get_relTheil(cwdata,"catch","SSB")
Theil_managed_Relative_C<-get_Theil(cwdata,"catch")


simlevelresults <- get_fillRepArraysSimLevel(simlevelresults)



# Do some cleanup that is specific to the economic model 
if(mproc$ImplementationClass[m]=="Economic"){
  # Put the economic performance measures into a place
  #If we have started management, put the economic results into their container
  if(y >= fmyearIdx){
    simlevelresults <- get_fillRepArraysEcon(simlevelresults)
    # Write the raw data out sometimes.
    if(chunk_flag==0 | yearitercounter==max_yiter){
      revenue_holder<-rbindlist(revenue_holder)
      tda <- as.character(Sys.time())
      tda <- gsub(':', '', tda)
      tda<-gsub(' ', '_', tda)
      tda2 <- paste0(tda,"_", round(runif(1, 0, 10000)))
      write.table(revenue_holder, file.path(econ_results_location, paste0("econ_",tda2, ".csv")), sep=",", row.names=FALSE)
      revenue_holder<-list()
      
      afsh<-rbindlist(fishery_output_holder)
      write.table(afsh, file.path(econ_results_location, paste0("econ_fishery_status_",tda2, ".csv")), sep=",", row.names=FALSE)
      afsh<-list()
      
      quotaprices<-rbindlist(fishery_quota_price_holder)
      write.table(quotaprices, file.path(econ_results_location, paste0("quota_prices_",tda2, ".csv")), sep=",", row.names=FALSE)
      quotaprices<-list()
      
      
    }
  }
}