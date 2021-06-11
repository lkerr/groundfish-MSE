#Kobe Plot
Scenarios<-c(9,10,11,12)
####Set up files####
library(matrixStats)
library(dplyr)
library(ggrepel)
library(ggthemes)
setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[1],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=20)
Fproxy<-matrix(NA,ncol=length(sims),nrow=20)
SSBestreal<-matrix(NA,ncol=length(sims),nrow=20)
SSBestproxy<-matrix(NA,ncol=length(sims),nrow=20)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[1],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  Freal[,k]<-na.omit(tail(omvalGlobal[[1]]$Fest[190,],22))
  SSBestreal[,k]<-na.omit(tail(omvalGlobal[[1]]$SSBest[190,],22))
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXY[169:188]
  SSBestproxy[,k]<-omvalGlobal[[1]]$SSBPROXY[169:188]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBestreal<-rowMedians(SSBestreal,na.rm=T)
SSBestproxy<-rowMedians(SSBestproxy,na.rm=T)
SSBestratioreal<-SSBestreal/SSBestproxy
Year<-2019:2038
Dftrue<-as.data.frame(cbind(SSBestratioreal,Fratioreal,Year))
Dftrue$Scenario<-Scenarios[1]

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[2],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=20)
Fproxy<-matrix(NA,ncol=length(sims),nrow=20)
SSBestreal<-matrix(NA,ncol=length(sims),nrow=20)
SSBestproxy<-matrix(NA,ncol=length(sims),nrow=20)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[2],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  Freal[,k]<-na.omit(tail(omvalGlobal[[1]]$Fest[190,],22))
  SSBestreal[,k]<-na.omit(tail(omvalGlobal[[1]]$SSBest[190,],22))
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXY[169:188]
  SSBestproxy[,k]<-omvalGlobal[[1]]$SSBPROXY[169:188]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBestreal<-rowMedians(SSBestreal,na.rm=T)
SSBestproxy<-rowMedians(SSBestproxy,na.rm=T)
SSBestratioreal<-SSBestreal/SSBestproxy
Year<-2019:2038
Dftrue2<-as.data.frame(cbind(SSBestratioreal,Fratioreal,Year))
Dftrue2$Scenario<-Scenarios[2]
df<-full_join(Dftrue,Dftrue2)

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[3],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=20)
Fproxy<-matrix(NA,ncol=length(sims),nrow=20)
SSBestreal<-matrix(NA,ncol=length(sims),nrow=20)
SSBestproxy<-matrix(NA,ncol=length(sims),nrow=20)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[3],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  Freal[,k]<-na.omit(tail(omvalGlobal[[1]]$Fest[190,],22))
  SSBestreal[,k]<-na.omit(tail(omvalGlobal[[1]]$SSBest[190,],22))
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXY[169:188]
  SSBestproxy[,k]<-omvalGlobal[[1]]$SSBPROXY[169:188]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBestreal<-rowMedians(SSBestreal,na.rm=T)
SSBestproxy<-rowMedians(SSBestproxy,na.rm=T)
SSBestratioreal<-SSBestreal/SSBestproxy
Year<-2019:2038
Dftrue2<-as.data.frame(cbind(SSBestratioreal,Fratioreal,Year))
Dftrue2$Scenario<-Scenarios[3]
df<-full_join(df,Dftrue2)

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[4],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=20)
Fproxy<-matrix(NA,ncol=length(sims),nrow=20)
SSBestreal<-matrix(NA,ncol=length(sims),nrow=20)
SSBestproxy<-matrix(NA,ncol=length(sims),nrow=20)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[4],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  Freal[,k]<-na.omit(tail(omvalGlobal[[1]]$Fest[190,],22))
  SSBestreal[,k]<-na.omit(tail(omvalGlobal[[1]]$SSBest[190,],22))
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXY[169:188]
  SSBestproxy[,k]<-omvalGlobal[[1]]$SSBPROXY[169:188]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBestreal<-rowMedians(SSBestreal,na.rm=T)
SSBestproxy<-rowMedians(SSBestproxy,na.rm=T)
SSBestratioreal<-SSBestreal/SSBestproxy
Year<-2019:2038
Dftrue2<-as.data.frame(cbind(SSBestratioreal,Fratioreal,Year))
Dftrue2$Scenario<-Scenarios[4]
df<-full_join(df,Dftrue2)

####Kobe Plot####
library(ggplot2)
maxSSBest<-max(1.1,max(df$SSBestratioreal))
maxF<-max(1.1,max(df$Fratioreal))
df$HCR<-df$Scenario
df$HCR[df$HCR==Scenarios[1]]<-'Ramp'
df$HCR[df$HCR==Scenarios[2]]<-'P*'
df$HCR[df$HCR==Scenarios[3]]<-'F-step'
df$HCR[df$HCR==Scenarios[4]]<-'Constrained ramp'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Ramp','P*','F-step','Constrained ramp'))
kobe <- ggplot(df, aes(x = SSBestratioreal, y = Fratioreal)) +
  theme_bw() 
kobe <- kobe + annotate(geom = "rect", xmin = 1, xmax = maxSSBest, ymin = 0, ymax = 1, fill = "green", colour = "green", alpha = 0.5) +
  annotate(geom = "rect", xmin = 0, xmax = 1, ymin = 1, ymax = maxF, fill = "red", colour = "red", alpha = 0.5) +
  annotate(geom = "rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1, fill = "yellow", colour = "yellow", alpha = 0.5) +
  annotate(geom = "rect", xmin = 1, xmax = maxSSBest, ymin = 1, ymax = maxF, fill = "yellow", colour = "yellow", alpha = 0.5) +
  geom_path(aes(linetype = HCR,colour=HCR), size = 0.3) +
  geom_point(aes(colour=HCR)) + # colour = yr
  labs(x = 'SSB/SSB MSY',
       y = 'F/F MSY') +
  xlim(0,maxSSBest)+
  ylim(0,maxF)+
  scale_color_colorblind()+
  geom_vline(xintercept=0.5, linetype='dotted')+
  theme(text=element_text(size=16),legend.position='bottom')+
  geom_text_repel(data=subset(df, Year > 2037 | Year < 2020),aes(x = SSBestratioreal, y = Fratioreal, label = Year))
kobe
