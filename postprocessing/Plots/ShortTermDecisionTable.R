library(matrixStats)
library(dplyr)
library(ggplot2)
#Scenarios<-c(6,32,58,116)
Scenarios<-c(6,32,58,116,7,33,59,117,1,27,53,111,8,34,60,118)
#Load data and change to numeric
wd<-getwd()
#wd<-setwd("C:/Users/jjesse/Box/HCR_Sims")

setwd(paste(wd,"/Sim_",Scenarios[1],"/sim",sep=""))
sims <- list.files()
for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)
SSB<-matrix(NA,nrow=21,ncol=length(sims))
Catch<-matrix(NA,nrow=21,ncol=length(sims))
F_mort<-matrix(NA,nrow=21,ncol=length(sims))
Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
  Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
  F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
}

SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catch<-rowMedians(Catch[1:5,],na.rm=T)
ShorttermCatch<-median(Catch,na.rm=T)
catchdiff<-rep(NA,(length(Catch)-1))
for (i in 1:(length(Catch)-1)){
  catchdiff[i]<-(Catch[i+1]-Catch[i])
}
Catchstab<-sqrt((1/(length(Catch)-1))*sum(catchdiff)^2)/((1/(length(Catch)))*sum(Catch))
Catchstab<-1/Catchstab
Fprop<-F_mort/Fproxy
Fprop<-rowMedians(Fprop[1:5,])
Fprop[Fprop<1]<-1
Fprop[Fprop>1]<-0
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMedians(Bprop[1:5,])
Bprop[Bprop<1]<-0
Bprop[Bprop>1]<-1
Bfreq<-mean(Bprop)

HCR<-rep('Ramp',4)
values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
d<-as.data.frame(cbind(HCR,values,metrics))

setwd(paste(wd,"/Sim_",Scenarios[2],"/sim",sep=""))
sims <- list.files()
for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)
SSB<-matrix(NA,nrow=21,ncol=length(sims))
Catch<-matrix(NA,nrow=21,ncol=length(sims))
F_mort<-matrix(NA,nrow=21,ncol=length(sims))
Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
  Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
  F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
}

SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catch<-rowMedians(Catch[1:5,],na.rm=T)
ShorttermCatch<-median(Catch,na.rm=T)
catchdiff<-rep(NA,(length(Catch)-1))
for (i in 1:(length(Catch)-1)){
  catchdiff[i]<-(Catch[i+1]-Catch[i])
}
Catchstab<-sqrt((1/(length(Catch)-1))*sum(catchdiff)^2)/((1/(length(Catch)))*sum(Catch))
Catchstab<-1/Catchstab
Fprop<-F_mort/Fproxy
Fprop<-rowMedians(Fprop[1:5,])
Fprop[Fprop<1]<-1
Fprop[Fprop>1]<-0
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMedians(Bprop[1:5,])
Bprop[Bprop<1]<-0
Bprop[Bprop>1]<-1
Bfreq<-mean(Bprop)

HCR<-rep('P*',4)
values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
d2<-as.data.frame(cbind(HCR,values,metrics))

d<-full_join(d,d2)


setwd(paste(wd,"/Sim_",Scenarios[3],"/sim",sep=""))
sims <- list.files()
for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)
SSB<-matrix(NA,nrow=21,ncol=length(sims))
Catch<-matrix(NA,nrow=21,ncol=length(sims))
F_mort<-matrix(NA,nrow=21,ncol=length(sims))
Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
  Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
  F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
}

SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catch<-rowMedians(Catch[1:5,],na.rm=T)
ShorttermCatch<-median(Catch,na.rm=T)
catchdiff<-rep(NA,(length(Catch)-1))
for (i in 1:(length(Catch)-1)){
  catchdiff[i]<-(Catch[i+1]-Catch[i])
}
Catchstab<-sqrt((1/(length(Catch)-1))*sum(catchdiff)^2)/((1/(length(Catch)))*sum(Catch))
Catchstab<-1/Catchstab
Fprop<-F_mort/Fproxy
Fprop<-rowMedians(Fprop[1:5,])
Fprop[Fprop<1]<-1
Fprop[Fprop>1]<-0
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMedians(Bprop[1:5,])
Bprop[Bprop<1]<-0
Bprop[Bprop>1]<-1
Bfreq<-mean(Bprop)

HCR<-rep('F-step',4)
values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
d2<-as.data.frame(cbind(HCR,values,metrics))

d<-full_join(d,d2)

setwd(paste(wd,"/Sim_",Scenarios[4],"/sim",sep=""))
sims <- list.files()
for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)
SSB<-matrix(NA,nrow=21,ncol=length(sims))
Catch<-matrix(NA,nrow=21,ncol=length(sims))
F_mort<-matrix(NA,nrow=21,ncol=length(sims))
Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
  Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
  F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
}

SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catch<-rowMedians(Catch[1:5,],na.rm=T)
ShorttermCatch<-median(Catch,na.rm=T)
catchdiff<-rep(NA,(length(Catch)-1))
for (i in 1:(length(Catch)-1)){
  catchdiff[i]<-(Catch[i+1]-Catch[i])
}
Catchstab<-sqrt((1/(length(Catch)-1))*sum(catchdiff)^2)/((1/(length(Catch)))*sum(Catch))
Catchstab<-1/Catchstab
Fprop<-F_mort/Fproxy
Fprop<-rowMedians(Fprop[1:5,])
Fprop[Fprop<1]<-1
Fprop[Fprop>1]<-0
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMedians(Bprop[1:5,])
Bprop[Bprop<1]<-0
Bprop[Bprop>1]<-1
Bfreq<-mean(Bprop)

HCR<-rep('Constrained ramp',4)
values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
d2<-as.data.frame(cbind(HCR,values,metrics))

d<-full_join(d,d2)

d$Scenario<-1

df<-d

for (j in 1:((length(Scenarios)/4)-1)){
  setwd(paste(wd,"/Sim_",Scenarios[(j*4)+1],"/sim",sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  SSB<-matrix(NA,nrow=21,ncol=length(sims))
  Catch<-matrix(NA,nrow=21,ncol=length(sims))
  F_mort<-matrix(NA,nrow=21,ncol=length(sims))
  Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
  SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
    Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
    F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
  }
  
  SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catch<-rowMedians(Catch[1:5,],na.rm=T)
  ShorttermCatch<-median(Catch,na.rm=T)
  catchdiff<-rep(NA,(length(Catch)-1))
  for (i in 1:(length(Catch)-1)){
    catchdiff[i]<-(Catch[i+1]-Catch[i])
  }
  Catchstab<-sqrt((1/(length(Catch)-1))*sum(catchdiff)^2)/((1/(length(Catch)))*sum(Catch))
  Catchstab<-1/Catchstab
  Fprop<-F_mort/Fproxy
  Fprop<-rowMedians(Fprop[1:5,])
  Fprop[Fprop<1]<-1
  Fprop[Fprop>1]<-0
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMedians(Bprop[1:5,])
  Bprop[Bprop<1]<-0
  Bprop[Bprop>1]<-1
  Bfreq<-mean(Bprop)
  
  HCR<-rep('Ramp',4)
  values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
  metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
  d<-as.data.frame(cbind(HCR,values,metrics))
  
  setwd(paste(wd,"/Sim_",Scenarios[(j*4)+2],"/sim",sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  SSB<-matrix(NA,nrow=21,ncol=length(sims))
  Catch<-matrix(NA,nrow=21,ncol=length(sims))
  F_mort<-matrix(NA,nrow=21,ncol=length(sims))
  Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
  SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
    Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
    F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
  }
  
  SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catch<-rowMedians(Catch[1:5,],na.rm=T)
  ShorttermCatch<-median(Catch,na.rm=T)
  catchdiff<-rep(NA,(length(Catch)-1))
  for (i in 1:(length(Catch)-1)){
    catchdiff[i]<-(Catch[i+1]-Catch[i])
  }
  Catchstab<-sqrt((1/(length(Catch)-1))*sum(catchdiff)^2)/((1/(length(Catch)))*sum(Catch))
  Catchstab<-1/Catchstab
  Fprop<-F_mort/Fproxy
  Fprop<-rowMedians(Fprop[1:5,])
  Fprop[Fprop<1]<-1
  Fprop[Fprop>1]<-0
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMedians(Bprop[1:5,])
  Bprop[Bprop<1]<-0
  Bprop[Bprop>1]<-1
  Bfreq<-mean(Bprop)
  
  HCR<-rep('P*',4)
  values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
  metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
  d2<-as.data.frame(cbind(HCR,values,metrics))
  
  d<-full_join(d,d2)
  
  
  setwd(paste(wd,"/Sim_",Scenarios[(j*4)+3],"/sim",sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  SSB<-matrix(NA,nrow=21,ncol=length(sims))
  Catch<-matrix(NA,nrow=21,ncol=length(sims))
  F_mort<-matrix(NA,nrow=21,ncol=length(sims))
  Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
  SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
    Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
    F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
  }
  
  SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catch<-rowMedians(Catch[1:5,],na.rm=T)
  ShorttermCatch<-median(Catch,na.rm=T)
  catchdiff<-rep(NA,(length(Catch)-1))
  for (i in 1:(length(Catch)-1)){
    catchdiff[i]<-(Catch[i+1]-Catch[i])
  }
  Catchstab<-sqrt((1/(length(Catch)-1))*sum(catchdiff)^2)/((1/(length(Catch)))*sum(Catch))
  Catchstab<-1/Catchstab
  Fprop<-F_mort/Fproxy
  Fprop<-rowMedians(Fprop[1:5,])
  Fprop[Fprop<1]<-1
  Fprop[Fprop>1]<-0
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMedians(Bprop[1:5,])
  Bprop[Bprop<1]<-0
  Bprop[Bprop>1]<-1
  Bfreq<-mean(Bprop)
  
  HCR<-rep('F-step',4)
  values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
  metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
  d2<-as.data.frame(cbind(HCR,values,metrics))
  
  d<-full_join(d,d2)
  
  
  setwd(paste(wd,"/Sim_",Scenarios[(j*4)+4],"/sim",sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  SSB<-matrix(NA,nrow=21,ncol=length(sims))
  Catch<-matrix(NA,nrow=21,ncol=length(sims))
  F_mort<-matrix(NA,nrow=21,ncol=length(sims))
  Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
  SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
    Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
    F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[170:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[170:190]
  }
  
  SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catch<-rowMedians(Catch[1:5,],na.rm=T)
  ShorttermCatch<-median(Catch,na.rm=T)
  catchdiff<-rep(NA,(length(Catch)-1))
  for (i in 1:(length(Catch)-1)){
    catchdiff[i]<-(Catch[i+1]-Catch[i])
  }
  Catchstab<-sqrt((1/(length(Catch)-1))*sum(catchdiff)^2)/((1/(length(Catch)))*sum(Catch))
  Catchstab<-1/Catchstab
  Fprop<-F_mort/Fproxy
  Fprop<-rowMedians(Fprop[1:5,])
  Fprop[Fprop<1]<-1
  Fprop[Fprop>1]<-0
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMedians(Bprop[1:5,])
  Bprop[Bprop<1]<-0
  Bprop[Bprop>1]<-1
  Bfreq<-mean(Bprop)
  
  HCR<-rep('Constrained ramp',4)
  values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
  metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
  d2<-as.data.frame(cbind(HCR,values,metrics))
  
  d<-full_join(d,d2)
  
  d$Scenario<-j+1
  
  df<-full_join(d,df)
}

####Plot####
df$V2<-as.numeric(df$V2)
df$HCR<-ordered(df$HCR,levels=c('Ramp','P*','F-step','Constrained ramp'))
df$metrics[df$metrics=='Catch']<-'Catch (mt)'
df$metrics[df$metrics=='Catchstability']<-'Catch stability'
df$metrics[df$metrics=='SSB']<-'SSB (mt)'
df$metrics[df$metrics=='Freq.NotOverfished']<-'Freq. Not Overfished'
df$metrics[df$metrics=='Freq.NotOverfishing']<-'Freq. Not Overfishing'
df$Scenario[df$Scenario==1]<-'Overfished Scenario 1'
df$Scenario[df$Scenario==2]<-'Misspecified Scenario 1'
df$Scenario[df$Scenario==3]<-'Misspecified Scenario 1 with Rho-adjustment'
df$Scenario[df$Scenario==4]<-'Misspecified Scenario 2'

ggplot(df, aes(x=HCR, y=V2, fill=HCR))+
geom_bar(stat="identity")+
scale_fill_colorblind()+
facet_grid(metrics~Scenario,scales='free', switch="y")+
theme_classic(base_size = 8)+
ylab(NULL)
