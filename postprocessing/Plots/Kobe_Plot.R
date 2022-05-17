#Kobe Plot
#Lists numbers of scenarios that you want to compare here
Scenarios<-c(7,8,9)
#Set working directory--where the results you want to compare are stored
wd<-"C:/Users/mmazur/Desktop/COCA_Sims"
#List what is being compared
comparison<-c('Ramp','F-step','Constrained ramp')

library(matrixStats)
library(dplyr)
library(ggrepel)

####First simulation####
setwd(paste(wd,"/Sim_",Scenarios[1],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=22)
Fproxy<-matrix(NA,ncol=length(sims),nrow=22)
SSBreal<-matrix(NA,ncol=length(sims),nrow=22)
SSBproxy<-matrix(NA,ncol=length(sims),nrow=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

for (k in 1:length(sims)){
  load(sims[k])
  Freal[,k]<-omvalGlobal[[1]]$F_full[168:189]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[169:190]
  SSBreal[,k]<-omvalGlobal[[1]]$SSB[168:189]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[169:190]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBreal<-rowMedians(SSBreal,na.rm=T)
SSBproxy<-rowMedians(SSBproxy,na.rm=T)
SSBratioreal<-SSBreal/SSBproxy
Year<-2019:2040
Dftrue<-as.data.frame(cbind(SSBratioreal,Fratioreal,Year))
Dftrue$Scenario<-Scenarios[1]

df<-Dftrue

for (i in 2:length(Scenarios)){
  
setwd(paste(wd,"/Sim_",Scenarios[i],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=22)
Fproxy<-matrix(NA,ncol=length(sims),nrow=22)
SSBreal<-matrix(NA,ncol=length(sims),nrow=22)
SSBproxy<-matrix(NA,ncol=length(sims),nrow=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

for (k in 1:length(sims)){
  load(sims[k])
  Freal[,k]<-omvalGlobal[[1]]$F_full[168:189]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[169:190]
  SSBreal[,k]<-omvalGlobal[[1]]$SSB[168:189]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[169:190]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBreal<-rowMedians(SSBreal,na.rm=T)
SSBproxy<-rowMedians(SSBproxy,na.rm=T)
SSBratioreal<-SSBreal/SSBproxy
Year<-2019:2040
Dftrue2<-as.data.frame(cbind(SSBratioreal,Fratioreal,Year))
Dftrue2$Scenario<-Scenarios[i]
df<-full_join(Dftrue,Dftrue2)
}

####Kobe Plot####
library(ggplot2)

for (i in 1:length(comparison)){
  df$HCR[df$HCR==Scenarios[i]]<-comparison[i]
}
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=comparison)

maxSSBest<-max(1.1,max(df$SSBratioreal))
maxF<-max(1.1,max(df$Fratioreal))

kobe <- ggplot(df, aes(x = SSBratioreal, y = Fratioreal)) +
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
  geom_text_repel(data=subset(df, Year > 2039 | Year < 2020),aes(x = SSBratioreal, y = Fratioreal, label = Year))
kobe
