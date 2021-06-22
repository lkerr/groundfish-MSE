library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
#Scenarios<-c(6,32,58,116)
Scenarios<-c(13,14,15,16,17,18,19,20)
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
SSB<-matrix(NA,nrow=22,ncol=length(sims))
Catch<-matrix(NA,nrow=22,ncol=length(sims))
F_mort<-matrix(NA,nrow=22,ncol=length(sims))
Fproxy<-matrix(NA,nrow=22,ncol=length(sims))
SSBproxy<-matrix(NA,nrow=22,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSB[,k]<-omvalGlobal[[1]]$SSB[169:190]
  Catch[,k]<-omvalGlobal[[1]]$sumCW[168:189]
  F_mort[,k]<-omvalGlobal[[1]]$F_full[169:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[169:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[169:190]
}

SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
ShorttermCatch<-median(Catchmed,na.rm=T)
Catch<-Catch[1:5,]
catchdiff<-matrix(NA,4,length(Catch[1,]))
Catchstab<-rep(NA,length(Catch[1,]))
for (i in 1:length(Catch[1,])){
  for (j in 1:(length(Catch[,1])-1)){
    catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
  }
  Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
}
Catchstab<-1/median(Catchstab)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[1:5,])
Fprop[Fprop<1]<-0
Fprop[Fprop>1]<-1
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[1:5,])
Bprop[Bprop<1]<-1
Bprop[Bprop>1]<-0
Bfreq<-mean(Bprop)

HCR<-rep('1',4)
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
SSB<-matrix(NA,nrow=22,ncol=length(sims))
Catch<-matrix(NA,nrow=22,ncol=length(sims))
F_mort<-matrix(NA,nrow=22,ncol=length(sims))
Fproxy<-matrix(NA,nrow=22,ncol=length(sims))
SSBproxy<-matrix(NA,nrow=22,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSB[,k]<-omvalGlobal[[1]]$SSB[169:190]
  Catch[,k]<-omvalGlobal[[1]]$sumCW[168:189]
  F_mort[,k]<-omvalGlobal[[1]]$F_full[169:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[169:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[169:190]
}

SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
ShorttermCatch<-median(Catchmed,na.rm=T)
Catch<-Catch[1:5,]
catchdiff<-matrix(NA,4,length(Catch[1,]))
Catchstab<-rep(NA,length(Catch[1,]))
for (i in 1:length(Catch[1,])){
  for (j in 1:(length(Catch[,1])-1)){
    catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
  }
  Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
}
Catchstab<-1/median(Catchstab)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[1:5,])
Fprop[Fprop<1]<-0
Fprop[Fprop>1]<-1
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[1:5,])
Bprop[Bprop<1]<-1
Bprop[Bprop>1]<-0
Bfreq<-mean(Bprop)

HCR<-rep('2',4)
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
SSB<-matrix(NA,nrow=22,ncol=length(sims))
Catch<-matrix(NA,nrow=22,ncol=length(sims))
F_mort<-matrix(NA,nrow=22,ncol=length(sims))
Fproxy<-matrix(NA,nrow=22,ncol=length(sims))
SSBproxy<-matrix(NA,nrow=22,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSB[,k]<-omvalGlobal[[1]]$SSB[169:190]
  Catch[,k]<-omvalGlobal[[1]]$sumCW[168:189]
  F_mort[,k]<-omvalGlobal[[1]]$F_full[169:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[169:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[169:190]
}

SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
ShorttermCatch<-median(Catchmed,na.rm=T)
Catch<-Catch[1:5,]
catchdiff<-matrix(NA,4,length(Catch[1,]))
Catchstab<-rep(NA,length(Catch[1,]))
for (i in 1:length(Catch[1,])){
  for (j in 1:(length(Catch[,1])-1)){
    catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
  }
  Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
}
Catchstab<-1/median(Catchstab)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[1:5,])
Fprop[Fprop<1]<-0
Fprop[Fprop>1]<-1
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[1:5,])
Bprop[Bprop<1]<-1
Bprop[Bprop>1]<-0
Bfreq<-mean(Bprop)

HCR<-rep('3',4)
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
SSB<-matrix(NA,nrow=22,ncol=length(sims))
Catch<-matrix(NA,nrow=22,ncol=length(sims))
F_mort<-matrix(NA,nrow=22,ncol=length(sims))
Fproxy<-matrix(NA,nrow=22,ncol=length(sims))
SSBproxy<-matrix(NA,nrow=22,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSB[,k]<-omvalGlobal[[1]]$SSB[169:190]
  Catch[,k]<-omvalGlobal[[1]]$sumCW[168:189]
  F_mort[,k]<-omvalGlobal[[1]]$F_full[169:190]
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[169:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[169:190]
}

SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
ShorttermCatch<-median(Catchmed,na.rm=T)
Catch<-Catch[1:5,]
catchdiff<-matrix(NA,4,length(Catch[1,]))
Catchstab<-rep(NA,length(Catch[1,]))
for (i in 1:length(Catch[1,])){
  for (j in 1:(length(Catch[,1])-1)){
    catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
  }
  Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
}
Catchstab<-1/median(Catchstab)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[1:5,])
Fprop[Fprop<1]<-0
Fprop[Fprop>1]<-1
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[1:5,])
Bprop[Bprop<1]<-1
Bprop[Bprop>1]<-0
Bfreq<-mean(Bprop)

HCR<-rep('4',4)
values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
d2<-as.data.frame(cbind(HCR,values,metrics))

d<-full_join(d,d2)

d$Scenario<-1
d$V2<-as.numeric(d$V2)

df<-d

for (m in 1:((length(Scenarios)/4)-1)){
  setwd(paste(wd,"/Sim_",Scenarios[(m*4)+1],"/sim",sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  SSB<-matrix(NA,nrow=22,ncol=length(sims))
  Catch<-matrix(NA,nrow=22,ncol=length(sims))
  F_mort<-matrix(NA,nrow=22,ncol=length(sims))
  Fproxy<-matrix(NA,nrow=22,ncol=length(sims))
  SSBproxy<-matrix(NA,nrow=22,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    SSB[,k]<-omvalGlobal[[1]]$SSB[169:190]
    Catch[,k]<-omvalGlobal[[1]]$sumCW[168:189]
    F_mort[,k]<-omvalGlobal[[1]]$F_full[169:190]
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[169:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[169:190]
  }
  
  SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
  ShorttermCatch<-median(Catchmed,na.rm=T)
  Catch<-Catch[1:5,]
  catchdiff<-matrix(NA,4,length(Catch[1,]))
  Catchstab<-rep(NA,length(Catch[1,]))
  for (i in 1:length(Catch[1,])){
    for (j in 1:(length(Catch[,1])-1)){
      catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
    }
    Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
  }
  Catchstab<-1/median(Catchstab)
  Fprop<-F_mort/Fproxy
  Fprop<-rowMeans(Fprop[1:5,])
  Fprop[Fprop<1]<-0
  Fprop[Fprop>1]<-1
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMeans(Bprop[1:5,])
  Bprop[Bprop<1]<-1
  Bprop[Bprop>1]<-0
  Bfreq<-mean(Bprop)
  
  HCR<-rep('1',4)
  values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
  metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
  d<-as.data.frame(cbind(HCR,values,metrics))
  
  setwd(paste(wd,"/Sim_",Scenarios[(m*4)+2],"/sim",sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  SSB<-matrix(NA,nrow=22,ncol=length(sims))
  Catch<-matrix(NA,nrow=22,ncol=length(sims))
  F_mort<-matrix(NA,nrow=22,ncol=length(sims))
  Fproxy<-matrix(NA,nrow=22,ncol=length(sims))
  SSBproxy<-matrix(NA,nrow=22,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    SSB[,k]<-omvalGlobal[[1]]$SSB[169:190]
    Catch[,k]<-omvalGlobal[[1]]$sumCW[168:189]
    F_mort[,k]<-omvalGlobal[[1]]$F_full[169:190]
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[169:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[169:190]
  }
  
  SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
  ShorttermCatch<-median(Catchmed,na.rm=T)
  Catch<-Catch[1:5,]
  catchdiff<-matrix(NA,4,length(Catch[1,]))
  Catchstab<-rep(NA,length(Catch[1,]))
  for (i in 1:length(Catch[1,])){
    for (j in 1:(length(Catch[,1])-1)){
      catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
    }
    Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
  }
  Catchstab<-1/median(Catchstab)
  Fprop<-F_mort/Fproxy
  Fprop<-rowMeans(Fprop[1:5,])
  Fprop[Fprop<1]<-0
  Fprop[Fprop>1]<-1
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMeans(Bprop[1:5,])
  Bprop[Bprop<1]<-1
  Bprop[Bprop>1]<-0
  Bfreq<-mean(Bprop)
  
  HCR<-rep('2',4)
  values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
  metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
  d2<-as.data.frame(cbind(HCR,values,metrics))
  
  d<-full_join(d,d2)
  
  
  setwd(paste(wd,"/Sim_",Scenarios[(m*4)+3],"/sim",sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  SSB<-matrix(NA,nrow=22,ncol=length(sims))
  Catch<-matrix(NA,nrow=22,ncol=length(sims))
  F_mort<-matrix(NA,nrow=22,ncol=length(sims))
  Fproxy<-matrix(NA,nrow=22,ncol=length(sims))
  SSBproxy<-matrix(NA,nrow=22,ncol=length(sims))
  
  for (k in 1:length(sims)){
    load(sims[k])
    SSB[,k]<-omvalGlobal[[1]]$SSB[169:190]
    Catch[,k]<-omvalGlobal[[1]]$sumCW[168:189]
    F_mort[,k]<-omvalGlobal[[1]]$F_full[169:190]
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[169:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[169:190]
  }
  
  SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
  ShorttermCatch<-median(Catchmed,na.rm=T)
  Catch<-Catch[1:5,]
  catchdiff<-matrix(NA,4,length(Catch[1,]))
  Catchstab<-rep(NA,length(Catch[1,]))
  for (i in 1:length(Catch[1,])){
    for (j in 1:(length(Catch[,1])-1)){
      catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
    }
    Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
  }
  Catchstab<-1/median(Catchstab)
  Fprop<-F_mort/Fproxy
  Fprop<-rowMeans(Fprop[1:5,])
  Fprop[Fprop<1]<-0
  Fprop[Fprop>1]<-1
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMeans(Bprop[1:5,])
  Bprop[Bprop<1]<-1
  Bprop[Bprop>1]<-0
  Bfreq<-mean(Bprop)
  
  HCR<-rep('3',4)
  values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
  metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
  d2<-as.data.frame(cbind(HCR,values,metrics))
  
  d<-full_join(d,d2)
  
  
  setwd(paste(wd,"/Sim_",Scenarios[(m*4)+4],"/sim",sep=""))
  sims <- list.files()
  for (k in 1:length(sims)){
    if (file.size(sims[k])==0){
      sims[k]<-NA}
  }
  sims<-na.omit(sims)
  SSB<-matrix(NA,nrow=22,ncol=length(sims)-1)
  Catch<-matrix(NA,nrow=22,ncol=length(sims)-1)
  F_mort<-matrix(NA,nrow=22,ncol=length(sims)-1)
  Fproxy<-matrix(NA,nrow=22,ncol=length(sims)-1)
  SSBproxy<-matrix(NA,nrow=22,ncol=length(sims)-1)
    
    for (k in 1:(length(sims)-1)){
      load(sims[k])
      SSB[,k]<-omvalGlobal[[1]]$SSB[169:190]
      Catch[,k]<-omvalGlobal[[1]]$sumCW[168:189]
      F_mort[,k]<-omvalGlobal[[1]]$F_full[169:190]
      Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[169:190]
      SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[169:190]
    }
    
    SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
    ShorttermSSB<-median(SSBFinal)
    Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
    ShorttermCatch<-median(Catchmed,na.rm=T)
    Catch<-Catch[1:5,]
    catchdiff<-matrix(NA,4,length(Catch[1,]))
    Catchstab<-rep(NA,length(Catch[1,]))
    for (i in 1:length(Catch[1,])){
      for (j in 1:(length(Catch[,1])-1)){
        catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
      }
      Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
    }
    Catchstab<-1/median(Catchstab)
    Fprop<-F_mort/Fproxy
    Fprop<-rowMeans(Fprop[1:5,])
    Fprop[Fprop<1]<-0
    Fprop[Fprop>1]<-1
    Ffreq<-mean(Fprop)
    Bprop<-SSB/(SSBproxy*0.5)
    Bprop<-rowMeans(Bprop[1:5,])
    Bprop[Bprop<1]<-1
    Bprop[Bprop>1]<-0
    Bfreq<-mean(Bprop)
  
  HCR<-rep('4',4)
  values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
  metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
  d2<-as.data.frame(cbind(HCR,values,metrics))
  
  d<-full_join(d,d2)
  d$Scenario<-m+1
  d$V2<-as.numeric(d$V2)
  df<-full_join(d,df)
  df$V2[df$Scenario==m+1]<-(df$V2[df$Scenario==m+1]-df$V2[df$Scenario==1])/(df$V2[df$Scenario==1]+0.00001)
  }

####Plot####
df<-df[df$Scenario>1,]
df$HCR<-ordered(df$HCR,levels=c('1','2','3','4'))
df$metrics[df$metrics=='Catch']<-'Catch (mt)'
df$metrics[df$metrics=='Catchstability']<-'Catch stability'
df$metrics[df$metrics=='SSB']<-'SSB (mt)'
df$metrics[df$metrics=='Freq.NotOverfished']<-'Freq. Overfished'
df$metrics[df$metrics=='Freq.NotOverfishing']<-'Freq. Overfishing'
df$Scenario[df$Scenario==2]<-'a'
df$Scenario[df$Scenario==3]<-'b'
df$Scenario[df$Scenario==4]<-'c'
df$Scenario[df$Scenario==5]<-'d'
df$Scenario[df$Scenario==6]<-'e'
df$Scenario<-ordered(df$Scenario,levels=c('a','b','c','d','e'))

df$V2[df$V2>1.1]<-1.1
df$V2[df$V2<(-0.5)]<-(-0.5)
ggplot(df, aes(x=HCR, y=V2, fill=HCR))+
geom_bar(stat="identity")+
scale_fill_colorblind()+
facet_grid(metrics~Scenario,scales='free', switch="y")+
theme_classic(base_size = 8)+
ylab(NULL)+
ylim(-0.5,0.5)+
coord_flip()+
geom_hline(yintercept=0, linetype="dashed", color = "grey")
