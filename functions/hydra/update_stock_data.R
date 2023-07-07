update_stock_data <- function(i,hydraData){

  stock <- stock[[i]]
  # Filter the whole paaIN object (proportions at age of index) by the species, turn it into a matrix object
  paaIN.df <- dplyr::filter(hydraData$paaIN,species==i)[,6:(5+stock$page)]
  paaIN.matrix <- as.matrix(paaIN.df)
  
  # Filter the whole paaCN object (proportiona at age of catch) by the species, turn it into a matrix object
  paaCN.df <- dplyr::filter(hydraData$paaCN,species==i)[,6:(5+stock$page)]
  paaCN.matrix <- as.matrix(paaCN.df)
  
  # Filter the total index (with observation error) by species
  sumIN <- dplyr::filter(as.data.frame(hydraData$IN),species==i,survey==1)[,"obsbiomass"]
  
  # Filter the total catch (with observation error) by species
  sumCW <- dplyr::filter(as.data.frame(hydraData$CN),species==i)[,"obscatch"]
  
  N <- dplyr::filter(hydraData$abundance,Species==i)[,"Abundance"]
  Biomass <- dplyr::filter(hydraData$biomass,Species==i)[,"Biomass"]
  # stock[[]]$sumIN<- sumSurv$predbiomass
  # stock[[]]$sumCW<- sumCatch$predcatch
  # stock[[]]$N<- hydraData$abundance
  # stock[[]]$Biomass <- hydraData$biomass
  
  # stock$sumIN <- as.vector(sumIN)
  # 
  # out <- within(stock, { 
  #   paaIN<- as.vector(t(paaIN.matrix))
  #   paaCN<- as.vector(t(paaCN.matrix))
  #   sumIN <- as.vector(sumIN)
  #   sumCW <- as.vector(sumCW)
  #   N <- as.vector(N)
  #   Biomass <- Biomass
  # })
  
  out<-stock
  out$paaIN <- matrix(paaIN.matrix, ncol = stock$page)
  out$paaCN<- matrix(paaCN.matrix, ncol=stock$page)
  out$sumIN <- as.vector(sumIN)
  out$sumCW <- as.vector(sumCW)
  out$N <- as.vector(N)
  out$SSB <- Biomass
  out$planBtrigger <- 0
  
  return(out)
}