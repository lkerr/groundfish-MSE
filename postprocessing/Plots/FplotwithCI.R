Scenarios<-c(6,32,58,116)
####Set up files####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(tidyr)
library(DescTools)
library(plyr)
setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[1],"/sim",sep=""))

sims <- list.files()

SSBratiots<-matrix(NA,ncol=length(sims),nrow=21)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Desktop/Council_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[1],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  SSBratiots[,k]<-omvalGlobal$codGOM$F_full[170:190]
}

Df<-as.data.frame(SSBratiots)
Df$Year<-2020:2040
Df<- Df %>% gather(Year, SSB, V1:V100)
Df$Year<-rep(2020:2040,100)
Df <- ddply(Df, "Year", summarise, median = MedianCI(SSB)[1], CI_lower=MedianCI(SSB)[2], CI_upper=MedianCI(SSB)[3])
Df$HCR<-Scenarios[1]

setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[2],"/sim",sep=""))
sims <- list.files()

SSBratiots<-matrix(NA,ncol=length(sims),nrow=21)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Desktop/Council_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[2],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  SSBratiots[,k]<-omvalGlobal$codGOM$F_full[170:190]
}

Df2<-as.data.frame(SSBratiots)
Df2$Year<-2020:2040
Df2<- Df2 %>% gather(Year, SSB, V1:V100)
Df2$Year<-rep(2020:2040,100)
Df2 <- ddply(Df2, "Year", summarise, median = MedianCI(SSB)[1], CI_lower=MedianCI(SSB)[2], CI_upper=MedianCI(SSB)[3])
Df2$HCR<-Scenarios[2]
Df<-full_join(Df,Df2)

setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[3],"/sim",sep=""))
sims <- list.files()

SSBratiots<-matrix(NA,ncol=length(sims),nrow=21)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Desktop/Council_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[3],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  SSBratiots[,k]<-omvalGlobal$codGOM$F_full[170:190]
}

Df2<-as.data.frame(SSBratiots)
Df2$Year<-2020:2040
Df2<- Df2 %>% gather(Year, SSB, V1:V100)
Df2$Year<-rep(2020:2040,100)
Df2 <- ddply(Df2, "Year", summarise, median = MedianCI(SSB)[1], CI_lower=MedianCI(SSB)[2], CI_upper=MedianCI(SSB)[3])
Df2$HCR<-Scenarios[3]
Df<-full_join(Df,Df2)

setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[4],"/sim",sep=""))
sims <- list.files()

SSBratiots<-matrix(NA,ncol=length(sims),nrow=21)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Desktop/Council_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[4],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  SSBratiots[,k]<-omvalGlobal$codGOM$F_full[170:190]
}

Df2<-as.data.frame(SSBratiots)
Df2$Year<-2020:2040
Df2<- Df2 %>% gather(Year, SSB, V1:V100)
Df2$Year<-rep(2020:2040,100)
Df2 <- ddply(Df2, "Year", summarise, median = MedianCI(SSB)[1], CI_lower=MedianCI(SSB)[2], CI_upper=MedianCI(SSB)[3])
Df2$HCR<-Scenarios[4]
Df<-full_join(Df,Df2)

Df$HCR[Df$HCR==Scenarios[1]]<-'Ramped'
Df$HCR[Df$HCR==Scenarios[2]]<-'P*'
Df$HCR[Df$HCR==Scenarios[3]]<-'Step in F'
Df$HCR[Df$HCR==Scenarios[4]]<-'Ramped with variation constraint'
Df$HCR<-as.factor(Df$HCR)
Df$HCR<-ordered(Df$HCR,levels=c('Ramped','P*','Step in F','Ramped with variation constraint'))

ggplot(Df, aes(x=Year, y=median,color=HCR)) +
  geom_line(size=1, alpha=0.8) +
  geom_ribbon(aes(ymin=CI_lower, ymax=CI_upper,fill=HCR), alpha=0.2) +
  theme_classic()+
  theme(text=element_text(size=18),legend.position='top',axis.text.x = element_text(angle = 90))+
  scale_fill_manual(values=c("#EA4F12","#EACA00","#407331","#00608A"))+
  scale_color_manual(values=c("#EA4F12","#EACA00","#407331","#00608A"))+
  ylab('F')
