get_hydra <- function(){
  #send hydra data to groundfish MSE?
  
  #for now load in data I already have for testing
  
  #Emily, change this to actually pull new hydra file
  load(here("functions/hydra/hydraDataList_msk.rda")) # update R list annually 
  
  #rearrange to look like data that we need
  species <- data.frame(name=hydraDataList_msk$speciesList, species= c(1:10))
  K <-as.numeric(hydraDataList_msk$growthK)
  Linf <- as.numeric(hydraDataList_msk$growthLinf)
  t0 <- 0 # is there something else I should be using here?
  vonbert <- data.frame(species,K, Linf,t0)
  
  # size bins
  binwidth <- hydraDataList_msk$binwidth%>%
    cbind(species)
  sizebin0 <- 0
  sizebin1 <- hydraDataList_msk$binwidth$sizebin1
  sizebin2 <- sizebin1 + hydraDataList_msk$binwidth$sizebin2 
  sizebin3 <- sizebin2 + hydraDataList_msk$binwidth$sizebin3
  sizebin4 <- sizebin3 + hydraDataList_msk$binwidth$sizebin4
  sizebin5 <- sizebin4 + hydraDataList_msk$binwidth$sizebin5
  sizebin <- as.data.frame(cbind(sizebin0,sizebin1, sizebin2, sizebin3, sizebin4, sizebin5, species))%>%
    full_join(vonbert)
  
  sizebins <- as.data.frame(cbind(sizebin0,sizebin1, sizebin2, sizebin3, sizebin4, sizebin5, species))%>%
    gather(bin, endbin, sizebin0:sizebin5)%>%
    group_by(species)%>%
    mutate(startbin= dplyr::lag(endbin))%>%
   dplyr::filter(!bin %in% c('sizebin0'))
  
  
  # calculate the number of fish in each bin- Problem this is not an integer
  observedSurvSize<- hydraDataList_msk$observedSurvSize
  SurvData <- gather(observedSurvSize, bin, prop, sizebin1:sizebin5)%>%
    mutate(N= ceiling(inpN*prop))%>% #fix by rounding?
    full_join(sizebins, by=c("species", "bin"))%>%
    full_join(vonbert)
  
  observedCatchSize <- hydraDataList_msk$observedCatchSize
  catchData <- gather(observedCatchSize, bin, prop, sizebin1:sizebin5)%>%
    mutate(N= ceiling(inpN*prop))%>% #fix by rounding?
    full_join(sizebins, by=c("species", "bin"))%>%
    full_join(vonbert)
  
  Surv_newbin<-SurvData%>%
    rowwise()%>%
    mutate(end = min(endbin, Linf-1), start= min(startbin, Linf-1)) #fix by choosing whichever is smallest?
  Catch_newbin <- catchData%>%
    rowwise()%>%
    mutate(end = min(endbin, Linf-1), start= min(startbin, Linf-1)) 
  
  #repeat rows based on N- each individual has its own row
  SurvRep <- as.data.frame(lapply(Surv_newbin, rep, Surv_newbin$N))
  CatchRep <- as.data.frame(lapply(Catch_newbin, rep, Catch_newbin$N))
  
  # some start bins are larger than Linf which will cause errors for calculating length
  # fixed this by forcing start to also be smaller than Linf
  # SurvCheck <- SurvRep%>%
  #   dplyr::filter(startbin>end)
  # CatchCheck <- CatchRep%>%
  #   dplyr::filter(startbin>end)
  # 
  # Survey <- anti_join(SurvRep,SurvCheck) # leave out problem lengths
  # Catch <- anti_join(CatchRep,CatchCheck)   
  
  hydraData <- list(observedSurSize=SurvRep,
                    observedCatchSize=CatchRep,
                    observedBiomass=hydraDataList_msk$observedBiomass,
                    observedCatch=hydraDataList_msk$observedCatch)
  return(hydraData)
}