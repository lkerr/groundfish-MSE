#Kobe Plot
Scenarios<-c(6,32,58,116)
####Set up files####
library(matrixStats)
library(dplyr)
library(ggrepel)
setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[1],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=21)
Fproxy<-matrix(NA,ncol=length(sims),nrow=21)
SSBreal<-matrix(NA,ncol=length(sims),nrow=21)
SSBproxy<-matrix(NA,ncol=length(sims),nrow=21)

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
  Freal[,k]<-omvalGlobal[[1]]$F_full[170:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
  SSBreal[,k]<-omvalGlobal[[1]]$SSB[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBreal<-rowMedians(SSBreal,na.rm=T)
SSBproxy<-rowMedians(SSBproxy,na.rm=T)
SSBratioreal<-SSBreal/SSBproxy
Year<-2020:2040
Dftrue<-as.data.frame(cbind(SSBratioreal,Fratioreal,Year))
Dftrue$Scenario<-Scenarios[1]

setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[2],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=21)
Fproxy<-matrix(NA,ncol=length(sims),nrow=21)
SSBreal<-matrix(NA,ncol=length(sims),nrow=21)
SSBproxy<-matrix(NA,ncol=length(sims),nrow=21)

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
  Freal[,k]<-omvalGlobal[[1]]$F_full[170:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
  SSBreal[,k]<-omvalGlobal[[1]]$SSB[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBreal<-rowMedians(SSBreal,na.rm=T)
SSBproxy<-rowMedians(SSBproxy,na.rm=T)
SSBratioreal<-SSBreal/SSBproxy
Year<-2020:2040
Dftrue2<-as.data.frame(cbind(SSBratioreal,Fratioreal,Year))
Dftrue2$Scenario<-Scenarios[2]
df<-full_join(Dftrue,Dftrue2)

setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[3],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=21)
Fproxy<-matrix(NA,ncol=length(sims),nrow=21)
SSBreal<-matrix(NA,ncol=length(sims),nrow=21)
SSBproxy<-matrix(NA,ncol=length(sims),nrow=21)

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
  Freal[,k]<-omvalGlobal[[1]]$F_full[170:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
  SSBreal[,k]<-omvalGlobal[[1]]$SSB[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBreal<-rowMedians(SSBreal,na.rm=T)
SSBproxy<-rowMedians(SSBproxy,na.rm=T)
SSBratioreal<-SSBreal/SSBproxy
Year<-2020:2040
Dftrue2<-as.data.frame(cbind(SSBratioreal,Fratioreal,Year))
Dftrue2$Scenario<-Scenarios[3]
df<-full_join(df,Dftrue2)

setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[4],"/sim",sep=""))

sims <- list.files()

Freal<-matrix(NA,ncol=length(sims),nrow=21)
Fproxy<-matrix(NA,ncol=length(sims),nrow=21)
SSBreal<-matrix(NA,ncol=length(sims),nrow=21)
SSBproxy<-matrix(NA,ncol=length(sims),nrow=21)

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
  Freal[,k]<-omvalGlobal[[1]]$F_full[170:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
  SSBreal[,k]<-omvalGlobal[[1]]$SSB[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
}

Freal<-rowMedians(Freal,na.rm=T)
Fproxy<-rowMedians(Fproxy,na.rm=T)
Fratioreal<-Freal/Fproxy

SSBreal<-rowMedians(SSBreal,na.rm=T)
SSBproxy<-rowMedians(SSBproxy,na.rm=T)
SSBratioreal<-SSBreal/SSBproxy
Year<-2020:2040
Dftrue2<-as.data.frame(cbind(SSBratioreal,Fratioreal,Year))
Dftrue2$Scenario<-Scenarios[4]
df<-full_join(df,Dftrue2)

####Kobe Plot####
library(ggplot2)
df$HCR<-df$Scenario
maxSSB<-max(1.1,max(SSBratioreal))
maxF<-max(1.1,max(Fratioreal))
df$HCR[df$HCR==Scenarios[1]]<-'Ramped'
df$HCR[df$HCR==Scenarios[2]]<-'P*'
df$HCR[df$HCR==Scenarios[3]]<-'Step in F'
df$HCR[df$HCR==Scenarios[4]]<-'Ramped with variation constraint'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Ramped','P*','Step in F','Ramped with variation constraint'))
kobe <- ggplot(df, aes(x = SSBratioreal, y = Fratioreal)) +
    theme_bw() 
  
  kobe <- kobe + annotate(geom = "rect", xmin = 1, xmax = maxSSB, ymin = 0, ymax = 1, fill = "green", colour = "green", alpha = 0.5) +
    annotate(geom = "rect", xmin = 0, xmax = 1, ymin = 1, ymax = maxF, fill = "red", colour = "red", alpha = 0.5) +
    annotate(geom = "rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1, fill = "yellow", colour = "yellow", alpha = 0.5) +
    annotate(geom = "rect", xmin = 1, xmax = maxSSB, ymin = 1, ymax = maxF, fill = "yellow", colour = "yellow", alpha = 0.5) +
    geom_path(aes(linetype = HCR,colour=HCR), size = 0.3) +
    geom_point(aes(colour=HCR)) + # colour = yr
    labs(x = 'SSB/SSB MSY Proxy',
         y = 'F/F MSY Proxy') +
    xlim(0,maxSSB)+
    ylim(0,maxF)+
    geom_vline(xintercept=0.5, linetype='dotted')+
    theme(text=element_text(size=16),legend.position='bottom')+
    geom_text_repel(data=subset(df, Year > 2039 | Year < 2021),aes(x = SSBratioreal, y = Fratioreal, label = Year)) +
    scale_color_manual(values=c("#EA4F12","#EACA00","#407331","#00608A"))
 kobe