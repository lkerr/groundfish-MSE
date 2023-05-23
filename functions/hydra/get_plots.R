get_plots <- function(biomass, catch) {
  library(here)
  library(tidyverse)
  
  #give a rep # to group by for plotting
  for (k in 1:r) {
   True_Biomass[[k]]$rep <-k 
   True_Catch[[k]]$rep<-k
  }
 #combine into one data frame
  biomass<- as.data.frame(do.call(rbind, True_Biomass))
  catch <- as.data.frame(do.call(rbind,True_Catch))
  species <- unique(biomass$Species)
  fleets <- unique(catch$fleet)
  
  #can make them look pretty later; saved functions/hydra/Plots
  for (i in 1:length(species)) {
    for (j in 1:length(fleets)) {
      temp_data_biomass <- dplyr::filter(biomass, Species==i)
      p1 <- ggplot(temp_data_biomass)+geom_line(aes(Year, Biomass, group=rep))
      setwd(here("functions/hydra/plots"))
      ggsave(p1, file=paste0('biomass_',i,'.png'))
      
      temp_data_catch <- dplyr::filter(catch, species==i & fleets==j)
      p2 <- ggplot(temp_data_catch)+geom_line(aes(year, catch, group=rep))
      ggsave(p2, file=paste0('catch_',i,'_',j,'.png'))
    }
    } 
  


}
