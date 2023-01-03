library('fmsb')
library(matrixStats)
library(dplyr)
Scenarios<-c(26,27,28)
#Load data and change to numeric
wd<-getwd()
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

x<-'7'
d<-as.data.frame(cbind(x,ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))


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

x<-'33'
d2<-as.data.frame(cbind(x,ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))

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

x<-'59'
d2<-as.data.frame(cbind(x,ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))

d<-full_join(d,d2)

# 
# setwd(paste(wd,"/Sim_",Scenarios[4],"/sim",sep=""))
# sims <- list.files()
# for (k in 1:length(sims)){
#   if (file.size(sims[k])==0){
#     sims[k]<-NA}
# }
# sims<-na.omit(sims)
# SSB<-matrix(NA,nrow=21,ncol=length(sims))
# Catch<-matrix(NA,nrow=21,ncol=length(sims))
# F_mort<-matrix(NA,nrow=21,ncol=length(sims))
# Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
# SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
# 
# for (k in 1:length(sims)){
#   load(sims[k])
#   SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
#   Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
#   F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
#   Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
#   SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
# }
# 
# SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
# ShorttermSSB<-median(SSBFinal)
# Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
# ShorttermCatch<-median(Catchmed,na.rm=T)
# Catch<-Catch[1:5,]
# catchdiff<-matrix(NA,4,length(Catch[1,]))
# Catchstab<-rep(NA,length(Catch[1,]))
# for (i in 1:length(Catch[1,])){
#   for (j in 1:(length(Catch[,1])-1)){
#     catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
#   }
#   Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
# }
# Catchstab<-1/median(Catchstab,na.rm=T)
# Fprop<-F_mort/Fproxy
# Fprop<-rowMeans(Fprop[1:5,],na.rm=T)
# Fprop[Fprop<1]<-1
# Fprop[Fprop>1]<-0
# Ffreq<-mean(Fprop)
# Bprop<-SSB/(SSBproxy*0.5)
# Bprop<-rowMeans(Bprop[1:5,],na.rm=T)
# Bprop[Bprop<1]<-0
# Bprop[Bprop>1]<-1
# Bfreq<-mean(Bprop)
# 
# x<-'117'
# d2<-as.data.frame(cbind(x,ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
# 
# d<-full_join(d,d2)
# 
# if (length(Scenarios)>4){
#   setwd(paste(wd,"/Sim_",Scenarios[5],"/sim",sep=""))
#   sims <- list.files()
#   for (k in 1:length(sims)){
#     if (file.size(sims[k])==0){
#       sims[k]<-NA}
#   }
#   sims<-na.omit(sims)
#   SSB<-matrix(NA,nrow=21,ncol=length(sims))
#   Catch<-matrix(NA,nrow=21,ncol=length(sims))
#   F_mort<-matrix(NA,nrow=21,ncol=length(sims))
#   Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
#   SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
#   
#   for (k in 1:length(sims)){
#     load(sims[k])
#     SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
#     Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
#     F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
#     Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
#     SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
#   }
#   
#   SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
#   ShorttermSSB<-median(SSBFinal)
#   Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
#   ShorttermCatch<-median(Catchmed,na.rm=T)
#   Catch<-Catch[1:5,]
#   catchdiff<-matrix(NA,4,length(Catch[1,]))
#   Catchstab<-rep(NA,length(Catch[1,]))
#   for (i in 1:length(Catch[1,])){
#     for (j in 1:(length(Catch[,1])-1)){
#       catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
#     }
#     Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
#   }
#   Catchstab<-1/median(Catchstab,na.rm=T)
#   Fprop<-F_mort/Fproxy
#   Fprop<-rowMeans(Fprop[1:5,])
#   Fprop[Fprop<1]<-1
#   Fprop[Fprop>1]<-0
#   Ffreq<-mean(Fprop)
#   Bprop<-SSB/(SSBproxy*0.5)
#   Bprop<-rowMeans(Bprop[1:5,])
#   Bprop[Bprop<1]<-0
#   Bprop[Bprop>1]<-1
#   Bfreq<-mean(Bprop)
#   
#   x<-'143'
#   d2<-as.data.frame(cbind(x,ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
#   
#   d<-full_join(d,d2)
#   
#   
#   setwd(paste(wd,"/Sim_",Scenarios[6],"/sim",sep=""))
#   sims <- list.files()
#   for (k in 1:length(sims)){
#     if (file.size(sims[k])==0){
#       sims[k]<-NA}
#   }
#   sims<-na.omit(sims)
#   SSB<-matrix(NA,nrow=21,ncol=length(sims))
#   Catch<-matrix(NA,nrow=21,ncol=length(sims))
#   F_mort<-matrix(NA,nrow=21,ncol=length(sims))
#   Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
#   SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
#   
#   for (k in 1:length(sims)){
#     load(sims[k])
#     SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
#     Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
#     F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
#     Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
#     SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
#   }
#   
#   SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
#   ShorttermSSB<-median(SSBFinal)
#   Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
#   ShorttermCatch<-median(Catchmed,na.rm=T)
#   Catch<-Catch[1:5,]
#   catchdiff<-matrix(NA,4,length(Catch[1,]))
#   Catchstab<-rep(NA,length(Catch[1,]))
#   for (i in 1:length(Catch[1,])){
#     for (j in 1:(length(Catch[,1])-1)){
#       catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
#     }
#     Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
#   }
#   Catchstab<-1/median(Catchstab)
#   Fprop<-F_mort/Fproxy
#   Fprop<-rowMeans(Fprop[1:5,])
#   Fprop[Fprop<1]<-1
#   Fprop[Fprop>1]<-0
#   Ffreq<-mean(Fprop)
#   Bprop<-SSB/(SSBproxy*0.5)
#   Bprop<-rowMeans(Bprop[1:5,])
#   Bprop[Bprop<1]<-0
#   Bprop[Bprop>1]<-1
#   Bfreq<-mean(Bprop)
#   
#   x<-'169'
#   d2<-as.data.frame(cbind(x,ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
#   
#   d<-full_join(d,d2)
#   
#   setwd(paste(wd,"/Sim_",Scenarios[7],"/sim",sep=""))
#   sims <- list.files()
#   for (k in 1:length(sims)){
#     if (file.size(sims[k])==0){
#       sims[k]<-NA}
#   }
#   sims<-na.omit(sims)
#   SSB<-matrix(NA,nrow=21,ncol=length(sims))
#   Catch<-matrix(NA,nrow=21,ncol=length(sims))
#   F_mort<-matrix(NA,nrow=21,ncol=length(sims))
#   Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
#   SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
#   
#   for (k in 1:length(sims)){
#     load(sims[k])
#     SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
#     Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
#     F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
#     Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
#     SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
#   }
#   
#   SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
#   ShorttermSSB<-median(SSBFinal)
#   Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
#   ShorttermCatch<-median(Catchmed,na.rm=T)
#   Catch<-Catch[1:5,]
#   catchdiff<-matrix(NA,4,length(Catch[1,]))
#   Catchstab<-rep(NA,length(Catch[1,]))
#   for (i in 1:length(Catch[1,])){
#     for (j in 1:(length(Catch[,1])-1)){
#       catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
#     }
#     Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
#   }
#   Catchstab<-1/median(Catchstab)
#   Fprop<-F_mort/Fproxy
#   Fprop<-rowMeans(Fprop[1:5,])
#   Fprop[Fprop<1]<-1
#   Fprop[Fprop>1]<-0
#   Ffreq<-mean(Fprop)
#   Bprop<-SSB/(SSBproxy*0.5)
#   Bprop<-rowMeans(Bprop[1:5,])
#   Bprop[Bprop<1]<-0
#   Bprop[Bprop>1]<-1
#   Bfreq<-mean(Bprop)
#   
#   x<-'195'
#   d2<-as.data.frame(cbind(x,ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
#   
#   d<-full_join(d,d2)
#   
#   
#   setwd(paste(wd,"/Sim_",Scenarios[8],"/sim",sep=""))
#   sims <- list.files()
#   for (k in 1:length(sims)){
#     if (file.size(sims[k])==0){
#       sims[k]<-NA}
#   }
#   sims<-na.omit(sims)
#   SSB<-matrix(NA,nrow=21,ncol=length(sims))
#   Catch<-matrix(NA,nrow=21,ncol=length(sims))
#   F_mort<-matrix(NA,nrow=21,ncol=length(sims))
#   Fproxy<-matrix(NA,nrow=21,ncol=length(sims))
#   SSBproxy<-matrix(NA,nrow=21,ncol=length(sims))
#   
#   for (k in 1:length(sims)){
#     load(sims[k])
#     SSB[,k]<-omvalGlobal[[1]]$SSB[170:190]
#     Catch[,k]<-omvalGlobal[[1]]$sumCW[169:189]
#     F_mort[,k]<-omvalGlobal[[1]]$F_full[170:190]
#     Fproxy[,k]<-omvalGlobal[[1]]$FPROXYT2[170:190]
#     SSBproxy[,k]<-omvalGlobal[[1]]$SSBPROXYT2[170:190]
#   }
#   
#   SSBFinal<-rowMedians(SSB[1:5,],na.rm=T)
#   ShorttermSSB<-median(SSBFinal)
#   Catchmed<-rowMedians(Catch[1:5,],na.rm=T)
#   ShorttermCatch<-median(Catchmed,na.rm=T)
#   Catch<-Catch[1:5,]
#   catchdiff<-matrix(NA,4,length(Catch[1,]))
#   Catchstab<-rep(NA,length(Catch[1,]))
#   for (i in 1:length(Catch[1,])){
#     for (j in 1:(length(Catch[,1])-1)){
#       catchdiff[j,i]<-(Catch[j+1,i]-Catch[j,i])
#     }
#     Catchstab[i]<-sqrt((1/(length(Catch[,i])-1))*sum(catchdiff[,i])^2)/((1/(length(Catch[,i])))*sum(Catch[,i]))
#   }
#   Catchstab<-1/median(Catchstab)
#   Fprop<-F_mort/Fproxy
#   Fprop<-rowMeans(Fprop[1:5,])
#   Fprop[Fprop<1]<-1
#   Fprop[Fprop>1]<-0
#   Ffreq<-mean(Fprop)
#   Bprop<-SSB/(SSBproxy*0.5)
#   Bprop<-rowMeans(Bprop[1:5,])
#   Bprop[Bprop<1]<-0
#   Bprop[Bprop>1]<-1
#   Bfreq<-mean(Bprop)
#   
#   x<-'254'
#   d2<-as.data.frame(cbind(x,ShorttermSSB,ShorttermCatch,Catchstab,Ffreq,Bfreq))
#   
#   d<-full_join(d,d2)
#   
# }

#Find maximum and minimum values
d$ShorttermSSB<-as.numeric(d$ShorttermSSB)
d$ShorttermCatch<-as.numeric(d$ShorttermCatch)
d$Catchstab<-as.numeric(d$Catchstab)
d$Ffreq<-as.numeric(d$Ffreq)
d$Bfreq<-as.numeric(d$Bfreq)
d$ShorttermSSB<-d$ShorttermSSB/max(d$ShorttermSSB)
d$ShorttermCatch<-d$ShorttermCatch/max(d$ShorttermCatch)
d$Catchstab<-d$Catchstab/max(d$Catchstab)
d$Ffreq<-d$Ffreq/max(d$Ffreq +0.001)
d$Bfreq<-d$Bfreq/max(d$Bfreq +0.001)
maxs<-rep(1,5)
mins<-rep(0,5)
#Add maximum and minimum values to dataframe
d<-rbind(mins,d)
d<-rbind(maxs,d)
rownames(d)<-c('max','min',d$x[3:length(d$x)])
d$x<-NULL
library(scales)
# #Pick colors
# colors_fill<-c(alpha("#EA4F12",0.1),
#                alpha("#EACA00",0.1),
#                alpha("#407331",0.1),
#                alpha("#00608A",0.1),
#                alpha("#EA4F12",0.1),
#                alpha("#EACA00",0.1),
#                alpha("#407331",0.1),
#                alpha("#00608A",0.1))
# colors_line<-c(alpha("#EA4F12",0.9),
#                alpha("#EACA00",0.9),
#                alpha("#407331",0.9),
#                alpha("#00608A",0.9),
#                alpha("#EA4F12",0.9),
#                alpha("#EACA00",0.9),
#                alpha("#407331",0.9),
#                alpha("#00608A",0.9))
#Create plot
# radarchart(d,seg=5,pcol=colors_line,
#            pfcol=colors_fill,plwd=10,vlcex=0.3,plty=c(rep(1,4),rep(2,4)))
# rows<<-rownames(d[-c(1,2),])
# colors_line<<-colors_line
# legend("topleft",
#        legend=c("Ramped","P*","Step in F","Ramped with variation constraint"),
#        pch=16,
#        col=c("#EA4F12","#EACA00","#407331","#00608A"),
#        lty=1, cex=0.7, bty= 'n')
# 
# if (length(Scenarios)>4){
#   legend("bottomleft",
#          legend=c('Misspecification','No misspecifciation'),
#          pch=16,
#          col="black",
#          lty=c(1,2),cex=0.7, bty= 'n')}

#NEW PLOT
#colorblind colors
colors_fill2<-c(alpha("#000000",0.2),
                alpha("#E69F00",0.2),
                alpha("#56B4E9",0.2),
                alpha("#009E73",0.2),
                alpha("#000000",0.2),
                alpha("#E69F00",0.2),
                alpha("#56B4E9",0.2),
                alpha("#009E73",0.2))
colors_line2<-c(alpha("#000000",0.9),
                alpha("#E69F00",0.9),
                alpha("#56B4E9",0.9),
                alpha("#009E73",0.9),
                alpha("#000000",0.9),
                alpha("#E69F00",0.9),
                alpha("#56B4E9",0.9),
                alpha("#009E73",0.9))

#colorblind
setwd("C:/Users/jjesse/Desktop/GMRI/MSE/Manuscript_Sims")
png("radar6.png", res=300, height=15, width=20, units = "in")
radarchart(d,seg=5,pcol=colors_line2,
           pfcol=colors_fill2,plwd=5, 
           vlabels=c("SSB","Catch","Catch\nStability","       Freq.\nNot\nOverfishing", "Freq.\nNot\n         Overfished"), vlcex=5,
           plty=c(rep(1,4),rep(2,4)), cglwd=5)
rows<<-rownames(d[-c(1,2),])
colors_line<<-colors_line

dev.off()


#ggsave("haddockradar.png",haddock, dpi=300, height=12, width=4)

# legend("topleft",inset=-.01,title ="HCR",title.adj = 0.2,
#        legend=c("Ramped","P*","Step in F","Ramped with\nvariation constraint"),
#        pch=16,
#        col=c("#000000","#E69F00","#56B4E9","#009E73"),
#        lty=1, cex=1, bty= 'n', y.intersp=0.4)
# if (length(Scenarios)>4){
#   legend("bottomleft",
#          legend=c('Misspecification','No misspecification'),
#          pch=16,
#          col="black",
#          lty=c(1,2),cex=0.7, bty= 'n')}
# 
