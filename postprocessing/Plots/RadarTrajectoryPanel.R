library('fmsb')
library(matrixStats)
library(dplyr)
Scenarios<-c(20,21,22,23,24,25,26,27,28,10,11,12,13,14,15,16,17,18)
#wd<-"C:/Users/mmazur/Desktop/COCA_Sims"
wd<-setwd("C:/Users/jjesse/Desktop/GMRI/MSE/Manuscript_Sims")
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
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
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
Catchstab<-1/median(Catchstab,na.rm=T)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[1:5,])
Fprop[Fprop<1]<-1
Fprop[Fprop>1]<-0
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[1:5,])
Bprop[Bprop<1]<-0
Bprop[Bprop>1]<-1
Bfreq<-mean(Bprop)
d<-as.data.frame(cbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
d$HCR<-'Ramp'
d$Miss<-'None'
d$Stock<-'Overfished'
d$Term<-'Short-term'

for (m in 2:length(Scenarios)){
  setwd(paste(wd,"/Sim_",Scenarios[m],"/sim",sep=""))
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
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
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
  Catchstab<-1/median(Catchstab,na.rm=T)
  Fprop<-F_mort/Fproxy
  Fprop<-rowMeans(Fprop[1:5,])
  Fprop[Fprop<1]<-1
  Fprop[Fprop>1]<-0
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMeans(Bprop[1:5,])
  Bprop[Bprop<1]<-0
  Bprop[Bprop>1]<-1
  Bfreq<-mean(Bprop)
  d2<-as.data.frame(cbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
  if (m%in%seq(1,16,3)){d2$HCR<-'Ramp'}
  if (m%in%seq(2,17,3)){d2$HCR<-'F-step'}
  if (m%in%seq(3,18,3)){d2$HCR<-'Constrained ramp'}
  if (m<4 | 9<m & m<13){
    d2$Miss<-'None'
  }
  if (3<m & m<7 | 12<m & m<16){
    d2$Miss<-'Intermediate'
  }
  if (6<m & m<10 | 15<m & m<19){
    d2$Miss<-'High'
  }
  if (m<10){
    d2$Stock<-'Overfished'
  }
  if (m>9){
    d2$Stock<-'Not Overfished'
  }
  d2$Term<-'Short-term'
  d<-full_join(d,d2)
}

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
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
}

SSBFinal<-rowMedians(SSB[6:10,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catchmed<-rowMedians(Catch[6:10,],na.rm=T)
ShorttermCatch<-median(Catchmed,na.rm=T)
Catch<-Catch[6:10,]
catchdiff<-matrix(NA,4,length(Catch[1,]))
Catchstab<-rep(NA,length(Catch[1,]))
for (i in 1:length(Catch[1,])){
  for (j in 1:(length(Catch[,1])-1)){
    catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
  }
  Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
}
Catchstab<-1/median(Catchstab,na.rm=T)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[6:10,])
Fprop[Fprop<1]<-1
Fprop[Fprop>1]<-0
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[6:10,])
Bprop[Bprop<1]<-0
Bprop[Bprop>1]<-1
Bfreq<-mean(Bprop)
d2<-as.data.frame(cbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
d2$HCR<-'Ramp'
d2$Miss<-'None'
d2$Stock<-'Overfished'
d2$Term<-'Mid-term'

d<-full_join(d,d2)

for (m in 2:length(Scenarios)){
  setwd(paste(wd,"/Sim_",Scenarios[m],"/sim",sep=""))
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
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
  }
  
  SSBFinal<-rowMedians(SSB[6:10,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catchmed<-rowMedians(Catch[6:10,],na.rm=T)
  ShorttermCatch<-median(Catchmed,na.rm=T)
  Catch<-Catch[6:10,]
  catchdiff<-matrix(NA,4,length(Catch[1,]))
  Catchstab<-rep(NA,length(Catch[1,]))
  for (i in 1:length(Catch[1,])){
    for (j in 1:(length(Catch[,1])-1)){
      catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
    }
    Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
  }
  Catchstab<-1/median(Catchstab,na.rm=T)
  Fprop<-F_mort/Fproxy
  Fprop<-rowMeans(Fprop[6:10,])
  Fprop[Fprop<1]<-1
  Fprop[Fprop>1]<-0
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMeans(Bprop[6:10,])
  Bprop[Bprop<1]<-0
  Bprop[Bprop>1]<-1
  Bfreq<-mean(Bprop)
  d2<-as.data.frame(cbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
  if (m%in%seq(1,16,3)){d2$HCR<-'Ramp'}
  if (m%in%seq(2,17,3)){d2$HCR<-'F-step'}
  if (m%in%seq(3,18,3)){d2$HCR<-'Constrained ramp'}
  if (m<4 | 9<m & m<13){
    d2$Miss<-'None'
  }
  if (3<m & m<7 | 12<m & m<16){
    d2$Miss<-'Intermediate'
  }
  if (6<m & m<10 | 15<m & m<19){
    d2$Miss<-'High'
  }
  if (m<10){
    d2$Stock<-'Overfished'
  }
  if (m>9){
    d2$Stock<-'Not Overfished'
  }
  d2$Term<-'Mid-term'
  d<-full_join(d,d2)
}

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
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
}

SSBFinal<-rowMedians(SSB[11:21,],na.rm=T)
ShorttermSSB<-median(SSBFinal)
Catchmed<-rowMedians(Catch[11:21,],na.rm=T)
ShorttermCatch<-median(Catchmed,na.rm=T)
Catch<-Catch[11:21,]
catchdiff<-matrix(NA,10,length(Catch[1,]))
Catchstab<-rep(NA,length(Catch[1,]))
for (i in 1:length(Catch[1,])){
  for (j in 1:(length(Catch[,1])-1)){
    catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
  }
  Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
}
Catchstab<-1/median(Catchstab,na.rm=T)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[11:21,])
Fprop[Fprop<1]<-1
Fprop[Fprop>1]<-0
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[11:21,])
Bprop[Bprop<1]<-0
Bprop[Bprop>1]<-1
Bfreq<-mean(Bprop)
d2<-as.data.frame(cbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
d2$HCR<-'Ramp'
d2$Miss<-'None'
d2$Stock<-'Overfished'
d2$Term<-'Long-term'

d<-full_join(d,d2)

for (m in 2:length(Scenarios)){
  setwd(paste(wd,"/Sim_",Scenarios[m],"/sim",sep=""))
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
    Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
    SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
  }
  
  SSBFinal<-rowMedians(SSB[11:21,],na.rm=T)
  ShorttermSSB<-median(SSBFinal)
  Catchmed<-rowMedians(Catch[11:21,],na.rm=T)
  ShorttermCatch<-median(Catchmed,na.rm=T)
  Catch<-Catch[11:21,]
  catchdiff<-matrix(NA,10,length(Catch[1,]))
  Catchstab<-rep(NA,length(Catch[1,]))
  for (i in 1:length(Catch[1,])){
    for (j in 1:(length(Catch[,1])-1)){
      catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
    }
    Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
  }
  Catchstab<-1/median(Catchstab,na.rm=T)
  Fprop<-F_mort/Fproxy
  Fprop<-rowMeans(Fprop[11:21,])
  Fprop[Fprop<1]<-1
  Fprop[Fprop>1]<-0
  Ffreq<-mean(Fprop)
  Bprop<-SSB/(SSBproxy*0.5)
  Bprop<-rowMeans(Bprop[11:21,])
  Bprop[Bprop<1]<-0
  Bprop[Bprop>1]<-1
  Bfreq<-mean(Bprop)
  d2<-as.data.frame(cbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
  if (m%in%seq(1,16,3)){d2$HCR<-'Ramp'}
  if (m%in%seq(2,17,3)){d2$HCR<-'F-step'}
  if (m%in%seq(3,18,3)){d2$HCR<-'Constrained ramp'}
  if (m<4 | 9<m & m<13){
    d2$Miss<-'None'
  }
  if (3<m & m<7 | 12<m & m<16){
    d2$Miss<-'Intermediate'
  }
  if (6<m & m<10 | 15<m & m<19){
    d2$Miss<-'High'
  }
  if (m<10){
    d2$Stock<-'Overfished'
  }
  if (m>9){
    d2$Stock<-'Not Overfished'
  }
  d2$Term<-'Long-term'
  d<-full_join(d,d2)
}

d$ShorttermSSB<-as.numeric(d$ShorttermSSB)
d$ShorttermCatch<-as.numeric(d$ShorttermCatch)
d$Catchstab<-as.numeric(d$Catchstab)
d$Ffreq<-as.numeric(d$Ffreq)
d$Bfreq<-as.numeric(d$Bfreq)

d1<-d[d$Stock=='Overfished',]

colors_fill2<-c(alpha("#000000",0.2),
                alpha("#E69F00",0.2),
                alpha("#56B4E9",0.2),
                alpha("#009E73",0.2),
                alpha("#F0E442",0.2),
                alpha("#E69F00",0.2),
                alpha("#56B4E9",0.2),
                alpha("#009E73",0.2))

colors_line2<-c(alpha("#000000",0.9),
                alpha("#E69F00",0.9),
                alpha("#56B4E9",0.9),
                alpha("#009E73",0.9),
                alpha("#F0E442",0.9),
                alpha("#E69F00",0.9),
                alpha("#56B4E9",0.9),
                alpha("#009E73",0.9))

#colorblind
setwd("C:/Users/jjesse/Desktop/GMRI/MSE/Manuscript_Sims")
png("longradar_cod.png", res=300, height=60, width=50, units = "in")

par(mar=rep(0.1,4))
par(mfrow=c(3,2))
d2<-d1[d1$Term=='Short-term',]
d2$ShorttermSSB<-d2$ShorttermSSB/max(d2$ShorttermSSB)
d2$ShorttermCatch<-d2$ShorttermCatch/max(d2$ShorttermCatch)
d2$Catchstab<-d2$Catchstab/max(d2$Catchstab)
d2<-d2[d2$Miss=='None',]
maxs<-rep(1,9)
mins<-rep(0,9)
d2<-rbind(mins,d2)
d2<-rbind(maxs,d2)
rownames(d2)<-c('max','min',3:length(d2$HCR))
radarchart(d2[1:5],seg=5,pcol=colors_line2,
           pfcol=colors_fill2,plwd=5,
           vlabels=c("SSB","Catch","Catch\nStability","      Freq.\nNot\nOverfishing", "Freq.\nNot\n          Overfished"), vlcex=10,
           plty=c(rep(1,5),rep(2,5)), cglwd=5)

d2<-d1[d1$Term=='Long-term',]
d2$ShorttermSSB<-d2$ShorttermSSB/max(d2$ShorttermSSB)
d2$ShorttermCatch<-d2$ShorttermCatch/max(d2$ShorttermCatch)
d2$Catchstab<-d2$Catchstab/max(d2$Catchstab)
d2<-d2[d2$Miss=='None',]
maxs<-rep(1,9)
mins<-rep(0,9)
d2<-rbind(mins,d2)
d2<-rbind(maxs,d2)
rownames(d2)<-c('max','min',3:length(d2$HCR))
radarchart(d2[1:5],seg=5,pcol=colors_line2,
           pfcol=colors_fill2,plwd=5,
           vlabels=c("SSB","Catch","Catch\nStability","      Freq.\nNot\nOverfishing", "Freq.\nNot\n          Overfished"), vlcex=10,
           plty=c(rep(1,5),rep(2,5)), cglwd=5)

d2<-d1[d1$Term=='Short-term',]
d2$ShorttermSSB<-d2$ShorttermSSB/max(d2$ShorttermSSB)
d2$ShorttermCatch<-d2$ShorttermCatch/max(d2$ShorttermCatch)
d2$Catchstab<-d2$Catchstab/max(d2$Catchstab)
d2<-d2[d2$Miss=='Intermediate',]
maxs<-rep(1,9)
mins<-rep(0,9)
d2<-rbind(mins,d2)
d2<-rbind(maxs,d2)
rownames(d2)<-c('max','min',3:length(d2$HCR))
radarchart(d2[1:5],seg=5,pcol=colors_line2,
           pfcol=colors_fill2,plwd=5,
           vlabels=c("SSB","Catch","Catch\nStability","      Freq.\nNot\nOverfishing", "Freq.\nNot\n          Overfished"), vlcex=10,
           plty=c(rep(1,5),rep(2,5)), cglwd=5)

d2<-d1[d1$Term=='Long-term',]
d2$ShorttermSSB<-d2$ShorttermSSB/max(d2$ShorttermSSB)
d2$ShorttermCatch<-d2$ShorttermCatch/max(d2$ShorttermCatch)
d2$Catchstab<-d2$Catchstab/max(d2$Catchstab)
d2<-d2[d2$Miss=='Intermediate',]
maxs<-rep(1,9)
mins<-rep(0,9)
d2<-rbind(mins,d2)
d2<-rbind(maxs,d2)
rownames(d2)<-c('max','min',3:length(d2$HCR))
radarchart(d2[1:5],seg=5,pcol=colors_line2,
           pfcol=colors_fill2,plwd=5,
           vlabels=c("SSB","Catch","Catch\nStability","      Freq.\nNot\nOverfishing", "Freq.\nNot\n          Overfished"), vlcex=10,
           plty=c(rep(1,5),rep(2,5)), cglwd=5)


d2<-d1[d1$Term=='Short-term',]
d2$ShorttermSSB<-d2$ShorttermSSB/max(d2$ShorttermSSB)
d2$ShorttermCatch<-d2$ShorttermCatch/max(d2$ShorttermCatch)
d2$Catchstab<-d2$Catchstab/max(d2$Catchstab)
d2<-d2[d2$Miss=='High',]
maxs<-rep(1,9)
mins<-rep(0,9)
d2<-rbind(mins,d2)
d2<-rbind(maxs,d2)
rownames(d2)<-c('max','min',3:length(d2$HCR))
radarchart(d2[1:5],seg=5,pcol=colors_line2,
           pfcol=colors_fill2,plwd=5,
           vlabels=c("SSB","Catch","Catch\nStability","      Freq.\nNot\nOverfishing", "Freq.\nNot\n          Overfished"), vlcex=10,
           plty=c(rep(1,5),rep(2,5)), cglwd=5)

d2<-d1[d1$Term=='Long-term',]
d2$ShorttermSSB<-d2$ShorttermSSB/max(d2$ShorttermSSB)
d2$ShorttermCatch<-d2$ShorttermCatch/max(d2$ShorttermCatch)
d2$Catchstab<-d2$Catchstab/max(d2$Catchstab)
d2<-d2[d2$Miss=='High',]
maxs<-rep(1,9)
mins<-rep(0,9)
d2<-rbind(mins,d2)
d2<-rbind(maxs,d2)
rownames(d2)<-c('max','min',3:length(d2$HCR))
radarchart(d2[1:5],seg=5,pcol=colors_line2,
           pfcol=colors_fill2,plwd=5,
           vlabels=c("SSB","Catch","Catch\nStability","      Freq.\nNot\nOverfishing", "Freq.\nNot\n          Overfished"), vlcex=10,
           plty=c(rep(1,5),rep(2,5)), cglwd=5)
dev.off()
