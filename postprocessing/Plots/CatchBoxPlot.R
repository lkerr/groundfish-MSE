#Scenarios<-c(6,32,58,116)
Scenarios<-c(9,10,11,12)
####Set up files####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[1],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[1],"/sim",sep=""))
sims <- list.files()

SSBratiot<-matrix(NA,nrow=length(sims),ncol=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
#setwd("C:/Users/jjesse/Box/HCR_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[1],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  SSBratiot[k,]<-omvalGlobal[[1]]$sumCW[169:190]
}

SSBratiots<-rowMedians(SSBratiot[,1:5])
Df<-as.data.frame(SSBratiots)
Df$SSBratiot<-SSBratiots
Df$SSBratiots<-NULL
Df$Time<-'Short-term'

SSBratiotm<-rowMedians(SSBratiot[,6:10])
Df2<-as.data.frame(SSBratiotm)
Df2$SSBratiot<-SSBratiotm
Df2$SSBratiotm<-NULL
Df2$Time<-'Medium-term'
Df<-full_join(Df,Df2)

SSBratiotl<-rowMedians(SSBratiot[,11:21])
Df2<-as.data.frame(SSBratiotl)
Df2$SSBratiot<-SSBratiotl
Df2$SSBratiotl<-NULL
Df2$Time<-'Long-term'
Df<-full_join(Df,Df2)
Df$HCR<-Scenarios[1]

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[2],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[2],"/sim",sep=""))
sims <- list.files()

SSBratiot<-matrix(NA,nrow=length(sims),ncol=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
#setwd("C:/Users/jjesse/Box/HCR_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[2],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  SSBratiot[k,]<-omvalGlobal[[1]]$sumCW[169:190]
}

SSBratiots<-rowMedians(SSBratiot[,1:5])
Df2<-as.data.frame(SSBratiots)
Df2$SSBratiot<-SSBratiots
Df2$SSBratiots<-NULL
Df2$Time<-'Short-term'

SSBratiotm<-rowMedians(SSBratiot[,6:10])
Df3<-as.data.frame(SSBratiotm)
Df3$SSBratiot<-SSBratiotm
Df3$SSBratiotm<-NULL
Df3$Time<-'Medium-term'
Df2<-full_join(Df2,Df3)

SSBratiotl<-rowMedians(SSBratiot[,11:21])
Df3<-as.data.frame(SSBratiotl)
Df3$SSBratiot<-SSBratiotl
Df3$SSBratiotl<-NULL
Df3$Time<-'Long-term'
Df2<-full_join(Df2,Df3)
Df2$HCR<-Scenarios[2]
Df<-full_join(Df,Df2)

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[3],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[3],"/sim",sep=""))
sims <- list.files()

SSBratiot<-matrix(NA,nrow=length(sims),ncol=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
#setwd("C:/Users/jjesse/Box/HCR_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[3],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  SSBratiot[k,]<-omvalGlobal[[1]]$sumCW[169:190]
}

SSBratiots<-rowMedians(SSBratiot[,1:5])
Df2<-as.data.frame(SSBratiots)
Df2$SSBratiot<-SSBratiots
Df2$SSBratiots<-NULL
Df2$Time<-'Short-term'

SSBratiotm<-rowMedians(SSBratiot[,6:10])
Df3<-as.data.frame(SSBratiotm)
Df3$SSBratiot<-SSBratiotm
Df3$SSBratiotm<-NULL
Df3$Time<-'Medium-term'
Df2<-full_join(Df2,Df3)

SSBratiotl<-rowMedians(SSBratiot[,11:21])
Df3<-as.data.frame(SSBratiotl)
Df3$SSBratiot<-SSBratiotl
Df3$SSBratiotl<-NULL
Df3$Time<-'Long-term'
Df2<-full_join(Df2,Df3)
Df2$HCR<-Scenarios[3]
Df<-full_join(Df,Df2)

setwd(paste("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims/Sim_",Scenarios[4],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[4],"/sim",sep=""))
sims <- list.files()

SSBratiot<-matrix(NA,nrow=length(sims),ncol=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

####True Values (From Operating Model)####
setwd("C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims")
#setwd("C:/Users/jjesse/Box/HCR_Sims")
tempwd <- getwd()
setwd(paste(tempwd,"/Sim_",Scenarios[4],"/sim",sep=""))

for (k in 1:length(sims)){
  load(sims[k])
  SSBratiot[k,]<-omvalGlobal[[1]]$sumCW[169:190]
}

SSBratiots<-rowMedians(SSBratiot[,1:5])
Df2<-as.data.frame(SSBratiots)
Df2$SSBratiot<-SSBratiots
Df2$SSBratiots<-NULL
Df2$Time<-'Short-term'

SSBratiotm<-rowMedians(SSBratiot[,6:10])
Df3<-as.data.frame(SSBratiotm)
Df3$SSBratiot<-SSBratiotm
Df3$SSBratiotm<-NULL
Df3$Time<-'Medium-term'
Df2<-full_join(Df2,Df3)

SSBratiotl<-rowMedians(SSBratiot[,11:21])
Df3<-as.data.frame(SSBratiotl)
Df3$SSBratiot<-SSBratiotl
Df3$SSBratiotl<-NULL
Df3$Time<-'Long-term'
Df2<-full_join(Df2,Df3)
Df2$HCR<-Scenarios[4]
Df<-full_join(Df,Df2)

Df$HCR[Df$HCR==Scenarios[1]]<-'Ramp'
Df$HCR[Df$HCR==Scenarios[2]]<-'P*'
Df$HCR[Df$HCR==Scenarios[3]]<-'F-step'
Df$HCR[Df$HCR==Scenarios[4]]<-'Constrained ramp'
Df$HCR<-as.factor(Df$HCR)
Df$HCR<-ordered(Df$HCR,levels=c('Ramp','P*','F-step','Constrained ramp'))
Df$Time<-ordered(Df$Time,levels=c('Short-term','Medium-term','Long-term'))

ggplot(Df)+
  geom_violin(aes(x=Time, y=SSBratiot, fill=HCR,linetype=HCR)) +
  theme_classic()+
  ylab('F/Fmsy')+
  xlab('Time')+
  theme(text=element_text(size=18),legend.position='right')+
  scale_fill_manual(values=c("#EA4F12","#EACA00","#407331","#00608A"))+
  geom_hline(yintercept=1, linetype="dashed", color = "black", size=1)

#NEW PLOT
ggplot(Df)+
  geom_boxplot(aes(x=Time, y=SSBratiot, fill=HCR)) +
  theme_classic()+
  ylab('Catch (mt)')+
  xlab('Time')+
  theme(text=element_text(size=18),legend.position='right')+
  scale_fill_colorblind()+
  scale_y_continuous(breaks = pretty(c(0,5500), n=5),limits = c(0,5500))

