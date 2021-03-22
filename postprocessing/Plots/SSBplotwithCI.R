Scenarios<-c(6,32,58,116)
####Set up files####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(tidyr)
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
  SSBratiots[,k]<-omvalGlobal[[1]]$SSB[170:190]
}

Df<-as.data.frame(SSBratiots)
Df$Year<-2020:2040
Df<- Df %>% gather(Year, SSB, V1:V100)
Df$Year<-rep(2020:2040,100)
SSB_summary <- data.frame(Year=unique(Df$Year), n=tapply(Df$SSB, Df$Year, length), mean=tapply(Df$SSB, Df$Year, mean),median=tapply(Df$SSB, Df$Year, median))
SSB_summary$sd <- tapply(Df$SSB, Df$Year, sd)
SSB_summary$sem <- SSB_summary$sd/sqrt(SSB_summary$n-1)
SSB_summary$CI_lower <- SSB_summary$mean + qt((1-0.95)/2, df=SSB_summary$n-1)*SSB_summary$sem
SSB_summary$CI_upper <- SSB_summary$mean - qt((1-0.95)/2, df=SSB_summary$n-1)*SSB_summary$sem
Df<-SSB_summary
Df$n<-Df$mean<-Df$sd<-Df$sem<-NULL
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
  SSBratiots[,k]<-omvalGlobal[[1]]$SSB[170:190]
}

Df2<-as.data.frame(SSBratiots)
Df2$Year<-2020:2040
Df2<- Df2 %>% gather(Year, SSB, V1:V100)
Df2$Year<-rep(2020:2040,100)
SSB_summary <- data.frame(Year=unique(Df2$Year), n=tapply(Df2$SSB, Df2$Year, length), mean=tapply(Df2$SSB, Df2$Year, mean),median=tapply(Df2$SSB, Df2$Year, median))
SSB_summary$sd <- tapply(Df2$SSB, Df2$Year, sd)
SSB_summary$sem <- SSB_summary$sd/sqrt(SSB_summary$n-1)
SSB_summary$CI_lower <- SSB_summary$mean + qt((1-0.95)/2, df=SSB_summary$n-1)*SSB_summary$sem
SSB_summary$CI_upper <- SSB_summary$mean - qt((1-0.95)/2, df=SSB_summary$n-1)*SSB_summary$sem
Df2<-SSB_summary
Df2$n<-Df2$mean<-Df2$sd<-Df2$sem<-NULL
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
  SSBratiots[,k]<-omvalGlobal[[1]]$SSB[170:190]
}

Df2<-as.data.frame(SSBratiots)
Df2$Year<-2020:2040
Df2<- Df2 %>% gather(Year, SSB, V1:V100)
Df2$Year<-rep(2020:2040,100)
SSB_summary <- data.frame(Year=unique(Df2$Year), n=tapply(Df2$SSB, Df2$Year, length), mean=tapply(Df2$SSB, Df2$Year, mean),median=tapply(Df2$SSB, Df2$Year, median))
SSB_summary$sd <- tapply(Df2$SSB, Df2$Year, sd)
SSB_summary$sem <- SSB_summary$sd/sqrt(SSB_summary$n-1)
SSB_summary$CI_lower <- SSB_summary$mean + qt((1-0.95)/2, df=SSB_summary$n-1)*SSB_summary$sem
SSB_summary$CI_upper <- SSB_summary$mean - qt((1-0.95)/2, df=SSB_summary$n-1)*SSB_summary$sem
Df2<-SSB_summary
Df2$n<-Df2$mean<-Df2$sd<-Df2$sem<-NULL
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
  SSBratiots[,k]<-omvalGlobal[[1]]$SSB[170:190]
}

Df2<-as.data.frame(SSBratiots)
Df2$Year<-2020:2040
Df2<- Df2 %>% gather(Year, SSB, V1:V100)
Df2$Year<-rep(2020:2040,100)
SSB_summary <- data.frame(Year=unique(Df2$Year), n=tapply(Df2$SSB, Df2$Year, length), mean=tapply(Df2$SSB, Df2$Year, mean),median=tapply(Df2$SSB, Df2$Year, median))
SSB_summary$sd <- tapply(Df2$SSB, Df2$Year, sd)
SSB_summary$sem <- SSB_summary$sd/sqrt(SSB_summary$n-1)
SSB_summary$CI_lower <- SSB_summary$mean + qt((1-0.95)/2, df=SSB_summary$n-1)*SSB_summary$sem
SSB_summary$CI_upper <- SSB_summary$mean - qt((1-0.95)/2, df=SSB_summary$n-1)*SSB_summary$sem
Df2<-SSB_summary
Df2$n<-Df2$mean<-Df2$sd<-Df2$sem<-NULL
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
  ylab('SSB (mt)')