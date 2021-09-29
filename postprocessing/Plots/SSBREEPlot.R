#####SSB REE Plot####
#Scenarios<-c(6,32,58,116)
Scenarios<-c(18)
####First Sims####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[1],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[1],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=11,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSBtrue<-omvalGlobal[[1]]$SSB[168:188]
  for (i in seq(170,190,2)){
    SSBest<-omvalGlobal[[1]]$SSBest[i,]
    SSBest<-na.omit(SSBest)
    SSBest<-tail(SSBest,1)
    Catchsim[(i-168)/2,k]<-((SSBest-SSBtrue[i-169])/SSBtrue[i-169])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2019,2039,2)
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

####Second Sims####
setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[2],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[2],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=11,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSBtrue<-omvalGlobal[[1]]$SSB[168:188]
  for (i in seq(170,190,2)){
    SSBest<-omvalGlobal[[1]]$SSBest[i,]
    SSBest<-na.omit(SSBest)
    SSBest<-tail(SSBest,1)
    Catchsim[(i-168)/2,k]<-((SSBest-SSBtrue[i-169])/SSBtrue[i-169])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2019,2039,2)
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[2]

df<-full_join(df,df2)

####Third Sims####
setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[3],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[3],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=11,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSBtrue<-omvalGlobal[[1]]$SSB[169:189]
  for (i in seq(170,190,2)){
    SSBest<-omvalGlobal[[1]]$SSBest[i,]
    SSBest<-na.omit(SSBest)
    SSBest<-tail(SSBest,1)
    Catchsim[((i-168)/2),k]<-((SSBest-SSBtrue[i-169])/SSBtrue[i-169])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2019,2039,2)
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[3]

df<-full_join(df,df2)
####Fourth Sims####
setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[4],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[4],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=11,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSBtrue<-omvalGlobal[[1]]$SSB[169:189]
  for (i in seq(170,190,2)){
    SSBest<-omvalGlobal[[1]]$SSBest[i,]
    SSBest<-na.omit(SSBest)
    SSBest<-tail(SSBest,1)
    Catchsim[((i-168)/2),k]<-((SSBest-SSBtrue[i-169])/SSBtrue[i-169])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2019,2039,2)
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[4]

df<-full_join(df,df2)

####Fifth Sims####
setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[5],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[4],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=11,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSBtrue<-omvalGlobal[[1]]$SSB[168:188]
  for (i in seq(170,190,2)){
    SSBest<-omvalGlobal[[1]]$SSBest[i,]
    SSBest<-na.omit(SSBest)
    SSBest<-tail(SSBest,1)
    Catchsim[((i-168)/2),k]<-((SSBest-SSBtrue[i-169])/SSBtrue[i-169])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2019,2039,2)
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[5]

df<-full_join(df,df2)

df$HCR[df$HCR==Scenarios[1]]<-'Base'
df$HCR[df$HCR==Scenarios[2]]<-'Lag and Two Year Updates'
df$HCR[df$HCR==Scenarios[3]]<-'Lag and Miss'
df$HCR[df$HCR==Scenarios[4]]<-'Two Year Updates and Miss'
df$HCR[df$HCR==Scenarios[5]]<-'Lag, Miss, and 2 Year Updates'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Base','Lag and Two Year Updates','Lag and Miss','Two Year Updates and Miss','Lag, Miss, and 2 Year Updates'))

ggplot(df)+geom_line(aes(x=Year,y=Catchsim,color=HCR),size=1)+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('%REE SSB')+ ylim(min(-15,min(df$Catchsim)),max(15,max(df$Catchsim)))+
  scale_color_colorblind()+
  scale_x_continuous(limits = c(2019,2040))

