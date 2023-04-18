get_lengthConvert <- function(stock, hydraData){

  # we want each species as a sub-list like stock object in groundfish MSE
   
  # assign length with random uniform distribution across bins
  Survlengths <- rowwise(hydraData$observedSurSize)%>%
    mutate(L=runif(1, min=start, max=end))
  
  Catchlengths <- rowwise(hydraData$observedCatchSize)%>%
    mutate(L=runif(1, min=start, max=end))
  
  # convert length at age using inverse Von Bert
  Survage <- Survlengths%>%
    rowwise()%>%
    mutate(age=ceiling(((-log(1-L/Linf))/K+t0)))#round up
    
  
  Catchage <- Catchlengths%>%
    rowwise()%>%
    mutate(age=ceiling(((-log(1-L/Linf))/K+t0)))%>% #round up
    select(fishery, year,species, name, age)
  
  # create plus group for now- better way to do this
  Survage$age[Survage$age>stock$page]<- stock$page
  Catchage$age[Catchage$age>stock$page]<- stock$page 
  
  # calculate proportions at age and bring annual total data back in
  
  Survtemp<- dplyr::filter(Survage)
    paaSurvtemp <-  Survtemp%>%
      select(survey, year,species, name, age)%>%
      group_by(survey, year, species, name, age)%>%
      count()%>%
      group_by(survey, year, species, name)%>%
      mutate(total=sum(n), paa=n/total)%>%
      select(survey, year,species,name,age,paa)%>%
      spread(age,paa)
    
    CNtemp <- dplyr::filter(Catchage)
    paaCNtemp <- CNtemp%>%
      select(fishery, year,species, name, age)%>%
      group_by(fishery, year, species, name, age)%>%
      count()%>%
      group_by(fishery, year, species, name)%>%
      mutate(total=sum(n), paa=n/total)%>%
      select(fishery, year,species,name,age,paa)%>%
      spread(age,paa)
   
   year_gap<- data.frame(year=seq(1:y))
               
    #assign and filter survey
     paaSurv <-dplyr::filter(paaSurvtemp, survey==1, species==i)%>%
       full_join(year_gap, by="year")%>%
       arrange(year)%>%
       ungroup()%>%
       select(!c(year,survey,species,name))
     
     paaCatch <- dplyr::filter(paaCNtemp, species==i)%>%
       full_join(year_gap, by="year")%>%
       arrange(year)%>%
       ungroup()%>%
       select(!c(fishery,year,species,name))
     
     sumSurv <- dplyr::filter(hydraData$observedBiomass,species==i, survey==1)%>%
       full_join(year_gap, by="year")%>%
       arrange(year)
     
     sumCatch <- dplyr::filter(hydraData$observedCatch, species==i)%>%
       full_join(year_gap, by='year')%>%
       arrange(year)

     # fill in NA with zero
     paaSurv[is.na(paaSurv)]<- 0
     paaCatch[is.na(paaCatch)]<- 0
     sumSurv[is.na(sumSurv)]<- 0
     sumCatch[is.na(sumCatch)]<- 0

    # rearrange paaSurv and paaCatch into matrix not list of ages
      paaSurv <- data.matrix(paaSurv)
      paaCatch <- data.matrix(paaCatch) 
                  
     
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
     
if (y==fyear) {
  out <- within(stock, { 
    paaIN[1:y,]<- paaSurv[1:y,]
    paaCN[1:y,]<- paaCatch[1:y,]
    sumIN[1:y]<- sumSurv$biomass[1:y]
    sumCW[1:y]<- sumCatch$catch[1:y]
  })
}else{
 out <- within(stock, { 
   paaIN[y,]<- paaSurv[y,]
   paaCN[y,]<- paaCatch[y,]
   sumIN[y]<- sumSurv$biomass[y]
   sumCW[y]<- sumCatch$catch[y]
   
   #obs_paaIN[y,]=obs_paaSurv
   #obs_paaCN[y,]=obs_paaCatch
   #obs_sumIN[y]=obs_sumSurv
   #obs_sumCW[y]=obs_sunCatch
 })
}
  
  return(out)
}


