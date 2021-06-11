#Scenarios<-c(6,32,58,116)
Scenarios<-c(9,10,11,12)
####Set up files####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(tidyr)
library(DescTools)
library(plyr)
library(ggthemes)
setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[1],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/Discard Sims/HCR Sims/Sim_", Scenarios[1],"/sim", sep=""))
sims <- list.files()

sumCWratiots<-matrix(NA,ncol=length(sims),nrow=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
#setwd("C:/Users/jjesse/Box/Discard Sims/HCR Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[1],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  sumCWratiots[,k]<-omvalGlobal$codGOM$sumCW[169:190]
}

D<-as.data.frame(sumCWratiots)
D$Year<-2019:2040
Df<- D %>% gather(Year, sumCW, 1:(length(D)-1))
Df$Year<-rep(2019:2040,(length(D)-1))
Df<-na.omit(Df)
Df <- ddply(Df, "Year", summarise, median = MedianCI(sumCW)[1], CI_lower=MedianCI(sumCW)[2], CI_upper=MedianCI(sumCW)[3])
Df$HCR<-Scenarios[1]

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[2],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/Discard Sims/HCR Sims/Sim_", Scenarios[2],"/sim", sep=""))
sims <- list.files()

sumCWratiots<-matrix(NA,ncol=length(sims),nrow=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
#setwd("C:/Users/jjesse/Box/Discard Sims/HCR Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[2],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  sumCWratiots[,k]<-omvalGlobal$codGOM$sumCW[169:190]
}

D2<-as.data.frame(sumCWratiots)
D2$Year<-2019:2040
Df2<- D2 %>% gather(Year, sumCW, 1:(length(D2)-1))
Df2$Year<-rep(2019:2040,(length(D2)-1))
Df2<-na.omit(Df2)
Df2 <- ddply(Df2, "Year", summarise, median = MedianCI(sumCW)[1], CI_lower=MedianCI(sumCW)[2], CI_upper=MedianCI(sumCW)[3])
Df2$HCR<-Scenarios[2]
Df<-full_join(Df,Df2)

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[3],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/Discard Sims/HCR Sims/Sim_", Scenarios[3],"/sim", sep=""))
sims <- list.files()

sumCWratiots<-matrix(NA,ncol=length(sims),nrow=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
#setwd("C:/Users/jjesse/Box/Discard Sims/HCR Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[3],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  sumCWratiots[,k]<-omvalGlobal$codGOM$sumCW[169:190]
}

D2<-as.data.frame(sumCWratiots)
D2$Year<-2019:2040
Df2<- D2 %>% gather(Year, sumCW, 1:(length(D2)-1))
Df2$Year<-rep(2019:2040,(length(D2)-1))
Df2<-na.omit(Df2)
Df2 <- ddply(Df2, "Year", summarise, median = MedianCI(sumCW)[1], CI_lower=MedianCI(sumCW)[2], CI_upper=MedianCI(sumCW)[3])
Df2$HCR<-Scenarios[3]
Df<-full_join(Df,Df2)

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[4],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/Discard Sims/HCR Sims/Sim_", Scenarios[4],"/sim", sep=""))
sims <- list.files()

sumCWratiots<-matrix(NA,ncol=length(sims),nrow=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
#setwd("C:/Users/jjesse/Box/Discard Sims/HCR Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[4],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  sumCWratiots[,k]<-omvalGlobal$codGOM$sumCW[169:190]
}

D2<-as.data.frame(sumCWratiots)
D2$Year<-2019:2040
Df2<- D2 %>% gather(Year, sumCW, 1:(length(D2)-1))
Df2$Year<-rep(2019:2040,(length(D2)-1))
Df2<-na.omit(Df2)
Df2 <- ddply(Df2, "Year", summarise, median = MedianCI(sumCW)[1], CI_lower=MedianCI(sumCW)[2], CI_upper=MedianCI(sumCW)[3])
Df2$HCR<-Scenarios[4]
Df<-full_join(Df,Df2)

Df$HCR[Df$HCR==Scenarios[1]]<-'Ramp'
Df$HCR[Df$HCR==Scenarios[2]]<-'P*'
Df$HCR[Df$HCR==Scenarios[3]]<-'Step in F'
Df$HCR[Df$HCR==Scenarios[4]]<-'Ramped with variation constraint'
Df$HCR<-as.factor(Df$HCR)
Df$HCR<-ordered(Df$HCR,levels=c('Ramp','P*','Step in F','Ramped with variation constraint'))

#NEW PLOT
#colorblind plot
ggplot(Df, aes(x=Year, y=median,color=HCR)) +
  geom_line(size=1, alpha=0.8) +
  geom_ribbon(aes(ymin=CI_lower, ymax=CI_upper,fill=HCR), alpha=0.2) +
  theme_classic()+
  theme(text=element_text(size=18),legend.position='right')+
  ylab('Catch (mt)')+
  scale_color_colorblind()+scale_fill_colorblind()+
  scale_y_continuous(breaks = seq(0,3000,500),limits = c(0,3000))
