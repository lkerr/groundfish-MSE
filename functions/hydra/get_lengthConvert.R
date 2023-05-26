get_lengthConvert <- function(stock,hydraData){

  # we want each species as a sub-list like stock object in groundfish MSE
   
  # assign length with random uniform distribution across bins
  Survlengths <- rowwise(hydraData$predSurSize)%>%
    mutate(L=runif(1, min=start, max=end))
  
  Catchlengths <- rowwise(hydraData$predCatchSize)%>%
    mutate(L=runif(1, min=start, max=end))
  
  # convert length at age using inverse Von Bert
  Survage <- Survlengths%>%
    rowwise()%>%
    mutate(age=ceiling(((-log(1-L/Linf))/K+t0)))#round up
    
  
  Catchage <- Catchlengths%>%
    rowwise()%>%
    mutate(age=ceiling(((-log(1-L/Linf))/K+t0)))%>% #round up
    select(fleet, year,species,inpN, name, age)
  
  # create plus group for now- better way to do this
  for(i in 1:length(stock))
  {
    Survage$age[Survage$age>stock[[i]]$page & Survage$species==i]<- stock[[i]]$page
    Catchage$age[Catchage$age>stock[[i]]$page & Catchage$species==i]<- stock[[i]]$page 
  }
  
  # calculate proportions at age and bring annual total data back in
  
  Survtemp<- dplyr::filter(Survage)
    paaSurvtemp <-  Survtemp%>%
      select(survey, year,inpN,species, name, age)%>%
      group_by(survey, year,inpN, species, name, age)%>%
      count()%>%
      group_by(survey, year,inpN, species, name)%>%
      mutate(total=sum(n), paa=n/total)%>%
      select(survey, year,inpN,species,name,age,paa)%>%
      spread(age,paa)
    
    CNtemp <- dplyr::filter(Catchage)
    paaCNtemp <- CNtemp%>%
      select(fleet, year,inpN,species, name, age)%>%
      group_by(fleet, year,inpN, species, name, age)%>%
      count()%>%
      group_by(fleet, year,inpN, species, name)%>%
      mutate(total=sum(n), paa=n/total)%>%
      select(fleet, year,inpN,species,name,age,paa)%>%
      spread(age,paa)
   
    year_gap<- data.frame(year=1:length(unique(paaSurvtemp$year)))
   
    #assign and filter survey
    paaSurv <- dplyr::data_frame()
    for(i in 1:hydraData$Nspecies)
    {
     paaSurv_temp <-dplyr::filter(paaSurvtemp, survey==1,species==i)%>%
       full_join(year_gap, by="year")%>%
       arrange(species)%>%
       arrange(year)
     
     paaSurv_temp[,6:(5+stock[[i]]$page)][is.na(paaSurv_temp[,6:(5+stock[[i]]$page)])] <- 0
     paaSurv_temp$species <- rep(i,nrow(paaSurv_temp))
     paaSurv <- dplyr::bind_rows(paaSurv,paaSurv_temp)
    }
     
     paaCatch<-dplyr::data_frame()
     for(i in 1:hydraData$Nspecies)
     {
       paaCatch_temp <- dplyr::filter(paaCNtemp,species==i)%>%
         full_join(year_gap, by="year")%>%
         arrange(species)%>%
         arrange(year)
         
       paaCatch_temp[,6:(5+stock[[i]]$page)][is.na(paaCatch_temp[,6:(5+stock[[i]]$page)])] <- 0
       paaCatch_temp$species <- rep(i,nrow(paaCatch_temp))
       paaCatch <- dplyr::bind_rows(paaCatch,paaCatch_temp)
     }

     
     # sumSurv <- dplyr::filter(as.data.frame(hydraData$predBiomass),species==i, survey==1)%>%
     #   full_join(year_gap, by="year")%>%
     #   arrange(year)
     # 
     # sumCatch <- dplyr::filter(as.data.frame(hydraData$predCatch), species==i)%>%
     #   full_join(year_gap, by='year')%>%
     #   arrange(year)
     # 
     # abundance <- dplyr::filter(as.data.frame(hydraData$abundance), Species==i)
     # biomass <- dplyr::filter(as.data.frame(hydraData$biomass), Species==i)
     
     # fill in NA with zero
     # paaSurv[is.na(paaSurv)]<- 0
     # paaCatch[is.na(paaCatch)]<- 0
     # sumSurv[is.na(sumSurv)]<- 0
     # sumCatch[is.na(sumCatch)]<- 0

    # rearrange paaSurv and paaCatch into matrix not list of ages
      # paaSurv <- data.matrix(paaSurv)
      # paaCatch <- data.matrix(paaCatch) 
                  
     
    # add error to index and catch (usually happens in get_indexData)
     # obs_sumCatch <- get_error_idx(type=oe_sumCW_typ, 
     #                                 idx=sumCatch$catch[y] * ob_sumCW, 
     #                                 par=oe_sumCW)
     # 
     # 
     # obs_paaCatch <- get_error_paa(type=oe_paaCN_typ, paa=paaCatch$catch[y,], 
     #                                par=oe_paaCN)
     # 
     # obs_sumSurv <- get_error_idx(type=oe_sumIN_typ, 
     #                               idx=sumSurv$biomass[y] * ob_sumIN, 
     #                               par=oe_sumIN)
     # 
     # 
     # obs_paaSurv <- get_error_paa(type=oe_paaIN_typ, paa=paaSurv$biomass[y,], 
     #                                par=oe_paaIN)
      
      
      out <- within(hydraData, { 
        paaIN<- paaSurv
        paaCN<- paaCatch
      })
      
      

  
  return(out)
}


