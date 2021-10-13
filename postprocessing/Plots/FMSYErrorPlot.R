####Error in FMSY Plot####
#Lists numbers of scenarios that you want to compare here
Scenarios<-c(5,6,7,8)
#Set working directory--where the results you want to compare are stored
wd<-"C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims"
#List what is being compared
comparison<-c('Ramp','P*','F-step','Constrained ramp')
####Set up files####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
setwd(paste(wd,"/Sim_",Scenarios[1],"/sim",sep=""))
sims <- list.files()

Fratiot<-matrix(NA,nrow=length(sims),ncol=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

for (k in 1:length(sims)){
  load(sims[k])
  Fratiot[k,]<-omvalGlobal[[1]]$FPROXY[169:190]/omvalGlobal[[1]]$FPROXYT2[169:190]
}

Fratiots<-rowMedians(Fratiot[,1:5])
Df<-as.data.frame(Fratiots)
Df$Fratiot<-Fratiots
Df$Fratiots<-NULL
Df$Time<-'Short-term'

Fratiotm<-rowMedians(Fratiot[,6:10])
Df2<-as.data.frame(Fratiotm)
Df2$Fratiot<-Fratiotm
Df2$Fratiotm<-NULL
Df2$Time<-'Medium-term'
Df<-full_join(Df,Df2)

Fratiotl<-rowMedians(Fratiot[,11:21])
Df2<-as.data.frame(Fratiotl)
Df2$Fratiot<-Fratiotl
Df2$Fratiotl<-NULL
Df2$Time<-'Long-term'
Df<-full_join(Df,Df2)
Df$HCR<-Scenarios[1]

setwd(paste(wd,"/Sim_",Scenarios[2],"/sim",sep=""))
sims <- list.files()

Fratiot<-matrix(NA,nrow=length(sims),ncol=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

for (k in 1:length(sims)){
  load(sims[k])
  Fratiot[k,]<-omvalGlobal[[1]]$FPROXY[169:190]/omvalGlobal[[1]]$FPROXYT2[169:190]
}

Fratiots<-rowMedians(Fratiot[,1:5])
Df2<-as.data.frame(Fratiots)
Df2$Fratiot<-Fratiots
Df2$Fratiots<-NULL
Df2$Time<-'Short-term'

Fratiotm<-rowMedians(Fratiot[,6:10])
Df3<-as.data.frame(Fratiotm)
Df3$Fratiot<-Fratiotm
Df3$Fratiotm<-NULL
Df3$Time<-'Medium-term'
Df2<-full_join(Df2,Df3)

Fratiotl<-rowMedians(Fratiot[,11:21])
Df3<-as.data.frame(Fratiotl)
Df3$Fratiot<-Fratiotl
Df3$Fratiotl<-NULL
Df3$Time<-'Long-term'
Df2<-full_join(Df2,Df3)
Df2$HCR<-Scenarios[2]
Df<-full_join(Df,Df2)

setwd(paste(wd,"/Sim_",Scenarios[3],"/sim",sep=""))
sims <- list.files()

Fratiot<-matrix(NA,nrow=length(sims),ncol=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

for (k in 1:length(sims)){
  load(sims[k])
  Fratiot[k,]<-omvalGlobal[[1]]$FPROXY[169:190]/omvalGlobal[[1]]$FPROXYT2[169:190]
}

Fratiots<-rowMedians(Fratiot[,1:5])
Df2<-as.data.frame(Fratiots)
Df2$Fratiot<-Fratiots
Df2$Fratiots<-NULL
Df2$Time<-'Short-term'

Fratiotm<-rowMedians(Fratiot[,6:10])
Df3<-as.data.frame(Fratiotm)
Df3$Fratiot<-Fratiotm
Df3$Fratiotm<-NULL
Df3$Time<-'Medium-term'
Df2<-full_join(Df2,Df3)

Fratiotl<-rowMedians(Fratiot[,11:21])
Df3<-as.data.frame(Fratiotl)
Df3$Fratiot<-Fratiotl
Df3$Fratiotl<-NULL
Df3$Time<-'Long-term'
Df2<-full_join(Df2,Df3)
Df2$HCR<-Scenarios[3]
Df<-full_join(Df,Df2)

setwd(paste(wd,"/Sim_",Scenarios[4],"/sim",sep=""))
sims <- list.files()

Fratiot<-matrix(NA,nrow=length(sims),ncol=22)

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

for (k in 1:length(sims)){
  load(sims[k])
  Fratiot[k,]<-omvalGlobal[[1]]$FPROXY[169:190]/omvalGlobal[[1]]$FPROXYT2[169:190]
}

Fratiots<-rowMedians(Fratiot[,1:5])
Df2<-as.data.frame(Fratiots)
Df2$Fratiot<-Fratiots
Df2$Fratiots<-NULL
Df2$Time<-'Short-term'

Fratiotm<-rowMedians(Fratiot[,6:10])
Df3<-as.data.frame(Fratiotm)
Df3$Fratiot<-Fratiotm
Df3$Fratiotm<-NULL
Df3$Time<-'Medium-term'
Df2<-full_join(Df2,Df3)

Fratiotl<-rowMedians(Fratiot[,11:21])
Df3<-as.data.frame(Fratiotl)
Df3$Fratiot<-Fratiotl
Df3$Fratiotl<-NULL
Df3$Time<-'Long-term'
Df2<-full_join(Df2,Df3)
Df2$HCR<-Scenarios[4]
Df<-full_join(Df,Df2)

Df$HCR[Df$HCR==Scenarios[1]]<-comparison[1]
Df$HCR[Df$HCR==Scenarios[2]]<-comparison[2]
Df$HCR[Df$HCR==Scenarios[3]]<-comparison[3]
Df$HCR[Df$HCR==Scenarios[4]]<-comparison[4]
df$HCR<-as.factor(df$HCR)
Df$HCR<-ordered(Df$HCR,levels=comparison)

ggplot(Df)+
  geom_boxplot(aes(x=Time, y=Fratiot, fill=HCR)) +
  theme_classic()+
  ylab('Estimated/True Fmsy')+
  xlab('Time')+
  theme(text=element_text(size=18),legend.position='right')+
  scale_fill_colorblind()+
  scale_y_continuous(limits = c(0.5,1.5))+
  geom_hline(yintercept=1, linetype="dashed", color = "black", size=1)
