get_lengthConvert <- function(stock, hydraData){

  # we want each species as a sub-list like stock object in groundfish MSE
   
  # assign length with random uniform distribution across bins
  Survlengths <- rowwise(hydraData$observedSurSize)%>%
    mutate(L=runif(1, min=startbin, max=end))
  
  Catchlengths <- rowwise(hydraData$observedCatchSize)%>%
    mutate(L=runif(1, min=startbin, max=end))
  
  # convert length at age using inverse Von Bert
  Survage <- Survlengths%>%
    rowwise()%>%
    mutate(age=ceiling(((-log(1-L/Linf))/K+t0)))#round up
    
  
  Catchage <- Catchlengths%>%
    rowwise()%>%
    mutate(age=ceiling(((-log(1-L/Linf))/K+t0)))%>% #round up
    select(fishery, year,species, name, age)
  
  # create plus group of 10 for now need to decide for different stocks
  Survage$age[Survage$age>10]<- 10
  Catchage$age[Catchage$age>10]<- 10  
  
  # calculate proportions at age and bring annual total data back in
  paaSurv <-list()
  paaCN <-list()
  
  Survtemp<- dplyr::filter(Survage, species==i)
    paaSurvtemp <-  Survtemp%>%
      select(survey, year,species, name, age)%>%
      group_by(survey, year, species, name, age)%>%
      count()%>%
      group_by(survey, year, species, name)%>%
      mutate(total=sum(n), paa=n/total)%>%
      select(survey, year,species,name,age,paa)%>%
      spread(age,paa)%>%
      ungroup()
    
    CNtemp <- dplyr::filter(Catchage, species==i)
    paaCNtemp <- CNtemp%>%
      select(fishery, year,species, name, age)%>%
      group_by(fishery, year, species, name, age)%>%
      count()%>%
      group_by(fishery, year, species, name)%>%
      mutate(total=sum(n), paa=n/total)%>%
      select(fishery, year,species,name,age,paa)%>%
      spread(age,paa)%>%
      ungroup()
    
     # fill in NA with zero
    paaSurvtemp[is.na(paaSurvtemp)]<-0
    paaCNtemp[is.na(paaCNtemp)]<- 0
    
    #assign to list and filter survey
     paaSurv <-dplyr::filter(paaSurvtemp, survey==1)
     paaCatch <- paaCNtemp
     sumSurv <- dplyr::filter(hydraData$observedBiomass, species==i, survey==1)
     sumCatch <- dplyr::filter(hydraData$observedCatch, species==i)

     
 # hydrastock =list(paaIN=list(),
 #                      paaCN=list(),
 #                      sumIN=list(),
 #                      sumCW=list())
 


 out <- within(stock, { 
   paaIN=paaSurv
   paaCN=paaCatch
   sumIN=sumSurv
   sumCW=sumCatch
 })
  
  return(out)
  }