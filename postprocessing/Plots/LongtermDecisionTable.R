library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)

#Long Term Decision Table 
#Lists numbers of scenarios that you want to compare here
Scenarios<-c(7,8,9)
#Set working directory--where the results you want to compare are stored
wd<-"C:/Users/mmazur/Desktop/COCA_Sims"

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
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[169:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[169:190]
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
Catchstab<-1/median(Catchstab)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[11:21,])
Fprop[Fprop<1]<-0
Fprop[Fprop>1]<-1
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[11:21,])
Bprop[Bprop<1]<-1
Bprop[Bprop>1]<-0
Bfreq<-mean(Bprop)

HCR<-rep('1',4)
values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
d<-as.data.frame(cbind(HCR,values,metrics))

for (i in 2:length(Scenarios){
setwd(paste(wd,"/Sim_",Scenarios[i],"/sim",sep=""))
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
  Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT[169:190]
  SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT[169:190]
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
Catchstab<-1/median(Catchstab)
Fprop<-F_mort/Fproxy
Fprop<-rowMeans(Fprop[11:21,])
Fprop[Fprop<1]<-0
Fprop[Fprop>1]<-1
Ffreq<-mean(Fprop)
Bprop<-SSB/(SSBproxy*0.5)
Bprop<-rowMeans(Bprop[11:21,])
Bprop[Bprop<1]<-1
Bprop[Bprop>1]<-0
Bfreq<-mean(Bprop)

HCR<-rep(i,4)
values<-rbind(ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq)
metrics<-c('SSB','Catch','Catchstability','Freq.NotOverfishing','Freq.NotOverfished')
d2<-as.data.frame(cbind(HCR,values,metrics))

d<-full_join(d,d2)
}

####Plot####
df<-d
df$HCR<-ordered(df$HCR,levels=1:length(Scenarios))
df$metrics[df$metrics=='Catch']<-'Catch (mt)'
df$metrics[df$metrics=='Catchstability']<-'Catch stability'
df$metrics[df$metrics=='SSB']<-'SSB (mt)'
df$metrics[df$metrics=='Freq.NotOverfished']<-'Freq. Overfished'
df$metrics[df$metrics=='Freq.NotOverfishing']<-'Freq. Overfishing'
df$V2[df$V2>0.5]<-0.5
df$V2[df$V2<(-1)]<-(-1)
     
ggplot(df, aes(x=HCR, y=V2, fill=HCR))+
  geom_bar(stat="identity")+
  scale_fill_colorblind()+
  facet_grid(metrics~Scenario,scales='free', switch="y")+
  theme_classic(base_size = 8)+
  ylab(NULL)+
  coord_flip()+
  ylim(-0.5,0.5)+
  geom_hline(yintercept=0, linetype="dashed", color = "grey")
