library(tidyverse)

s=4
tempstock <-stock[[s]]
year <- seq(from=1978, to=2018, by=1)
SSBest <- tempstock$res$SSB
Fest <- tempstock$res$F.report
Rest <- tempstock$res$N.age[,1]
catch <- tempstock$res$catch.pred[1,]
data <- as.data.frame(cbind(year,SSBest, Fest, Rest, catch))%>%
  gather("metric","measurement", 2:5)

summary <- ggplot(data)+geom_line(aes(x=year, y=measurement))+
  facet_grid(vars(metric), scales="free")+
  ggtitle(paste(stock[[s]]$stockName))

summary

#stock <- readRDS('test_stock_results.rds')
#stock <- readRDS('test_results2.rds')

ASAPstocks <-c(1,2,3,5,8,10)
for (i in ASAPstocks) {
  data <- stock[[i]]
  om_biomass <- as.data.frame(cbind(data$SSB,seq(1:44)))
  om_biomass<-dplyr::filter(om_biomass, V2<43)
  assess_biomass <- as.data.frame(cbind(data$parpop$SSBhat, seq(1:41)))
  p<-ggplot()+geom_line(data=om_biomass,aes(y=V1, x=V2))+
  geom_point(data=assess_biomass, aes(y=V1, x=V2))+
    labs(y='Biomass', x= "Year", title = paste0('stock ',i))
  print(p)
}


for (i in ASAPstocks) {
  data <- stock[[i]]
  om_biomass <- as.data.frame(cbind(data$SSB,seq(1:44)))
  om_biomass<-dplyr::filter(om_biomass, V2<41)
  colnames(om_biomass)<-c('om_biomass','Year')
  assess_biomass <- as.data.frame(cbind(data$parpop$SSBhat, seq(1:41)))
    colnames(assess_biomass)<-c("assess_biomass", 'Year')
  tempData<- full_join(om_biomass, assess_biomass)%>%
    gather(key='BiomassType', value='Biomass',1,3)
  
  p<-ggplot(tempData)+geom_line(aes(y=Biomass, x=Year, group=BiomassType, col=BiomassType))+
    labs(y='Biomass', x= "Year", title = paste0('stock ',i))+
    theme(legend.position = 'bottom', legend.title = element_blank())
  print(p)
}

PlanBstocks <-c(4,6,7,9)
for (i in PlanBstocks) {
  data <- stock[[i]]
  om_catch <- as.data.frame(cbind(data$planBdata$avg,seq(1:44)))
  om_catch<-dplyr::filter(om_catch, V2<41)
  colnames(om_catch)<-c('IN_catch','Year')
  assess_catch <- as.data.frame(cbind(data$planBest$pred_fit$fit, seq(1:41)))
  colnames(assess_catch)<-c("assess_catch", 'Year')
  tempData<- full_join(om_catch, assess_catch)%>%
    gather(key='CatchType', value='Catch',1,3)
  
  p<-ggplot(tempData)+geom_line(aes(y=Catch, x=Year, group=CatchType, col=CatchType))+
    labs(y='Catch', x= "Year", title = paste0('stock ',i))+
    theme(legend.position = 'bottom', legend.title = element_blank())
  print(p)
}
