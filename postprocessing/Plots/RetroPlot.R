Scenarios<-c(22)
RhoAdj<-FALSE
Stock<-'codGOM'
wd<-"C:/Users/mmazur/Desktop/COCA_Sims"
####First Sims####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
setwd(paste(wd,"/Sim_",Scenarios[1],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=52,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$SSB[137:188]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2038
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_F[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

SSBest<- matrix(NA,nrow=1092,ncol=length(sims))

for (i in 170:190){
for (k in 1:length(sims)){
  load(sims[k])
  SSBest[((i-169)*52-51):((i-169)*52),k]<-omvalGlobal[[1]]$SSBest[i,1:52]
}
}

SSBest<-rowMedians(SSBest,na.rm=T)
df2<-as.data.frame(cbind(SSBest,rep(Year,21)))
df2$Year<-df2$V2
df2$Type<-rep(170:190,each=52)
df2$V2<-NULL
df<-full_join(df,df2)
df$Type<-as.factor(df$Type)

ggplot(df)+geom_line(aes(x=Year,y=SSBest,color=Type))+geom_point(aes(x=Year,y=Catchsim))+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('SSB (mt)')+geom_vline(xintercept=2019, linetype='dotted')
