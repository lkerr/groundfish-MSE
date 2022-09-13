# This stores the Simulation level a place. These are performance metrics that are useful for a multispecies model, but are not necessarily economic.
# Borrowed from get_fillRepArrays, but simpler because my objects are in the global environment

get_fillRepArraysSimLevel <- function(simulation_container){
  simulation_container$HHI_fleet[r,m,y]<-HHI
  simulation_container$Shannon_fleet[r,m,y]<-shannon
  return(simulation_container)
  
}


