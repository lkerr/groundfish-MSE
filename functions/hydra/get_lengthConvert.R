get_lengthConvert <- function(hydraData){
  
  # we want each species as a sub-list like stock object in groundfish MSE
  with(hydraData, {
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
  stockName <- unique(Survage$name)
  
  for (s in stockName) {
    Survtemp <- filter(Survage,name==s)
    paaSurvtemp <-  Survtemp%>%
      select(survey, year,species, name, age)%>%
      group_by(survey, year, species, name, age)%>%
      count()%>%
      group_by(survey, year, species, name)%>%
      mutate(total=sum(n), paa=n/total)%>%
      select(survey, year,species,name,age,paa)%>%
      spread(age,paa)
    
    CNtemp <- filter(Catchage,name=='Goosefish')
    paaCNtemp <- CNtemp%>%
      select(fishery, year,species, name, age)%>%
      group_by(fishery, year, species, name, age)%>%
      count()%>%
      group_by(fishery, year, species, name)%>%
      mutate(total=sum(n), paa=n/total)%>%
      select(fishery, year,species,name,age,paa)%>%
      spread(age,paa)
    
     # fill in NA with zero
    paaSurvtemp[is.na(paaSurvtemp)]<-0
    paaCNtemp[is.na(paaCNtemp)]<- 0
    
    #assign to list
     paaSurv[[s]]<-paaSurvtemp
     paaCN[[s]]<- paaCNtemp
  }
 

  
  stock <- list()
  for (i in 1:length(stockName)) {
    stock[[i]] <- list(paaIN=filter(paaSurv[[i]], survey==1),
                       paaCN=filter(paaCN[[i]]),
                       sumIN=filter(hydraDataList_msk$observedBiomass, survey==1, species==i),
                       sumCW=filter(hydraDataList_msk$observedCatch, species==i))
    
  }
  names(stock)<- stockName
  
 #saveRDS(stock,file= "stock.rdat")
  
})
  return(stock)
  }