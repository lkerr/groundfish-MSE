# This stores the Simulation level a place. These are performance metrics that are useful for a multispecies model, but are not necessarily economic.
# Borrowed from get_fillRepArrays, but simpler because my objects are in the global environment instead of elements of stock

get_fillRepArraysSimLevel <- function(simulation_container){
  simulation_container$HHI_fleet[r,m,y]<-HHI
  simulation_container$Shannon_fleet[r,m,y]<-shannon
  simulation_container$Theil_managed_CtoB[r,m,y]<-Theil_managed_CtoB
  simulation_container$Theil_managed_Relative_C[r,m,y]<-Theil_managed_Relative_C

  return(simulation_container)
  
}


