#####F REE Plot####
Scenarios<-c(6,32,58,116)
####First Sims####
library(matrixStats)
library(dplyr)
library(ggplot2)
setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[1],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=20,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$relE_F[170:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-2020:2039
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

####Second Sims####
setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[2],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=20,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$relE_F[170:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-2020:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[2]

df<-full_join(df,df2)

####Third Sims####
setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[3],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=20,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$relE_F[170:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-2020:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[3]

df<-full_join(df,df2)
####Fourth Sims####
setwd(paste("C:/Users/mmazur/Desktop/Council_Sims/Sim_",Scenarios[4],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=20,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$relE_F[170:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-2020:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[4]

df<-full_join(df,df2)

df$HCR[df$HCR==Scenarios[1]]<-'Ramped'
df$HCR[df$HCR==Scenarios[2]]<-'P*'
df$HCR[df$HCR==Scenarios[3]]<-'Step in F'
df$HCR[df$HCR==Scenarios[4]]<-'Ramped with variation constraint'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Ramped','P*','Step in F','Ramped with variation constraint'))

ggplot(df)+geom_line(aes(x=Year,y=Catchsim,color=HCR))+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('%REE F')+ ylim(min(-15,min(df$Catchsim)),max(15,max(df$Catchsim)))+
  scale_color_manual(values=c("#EA4F12","#EACA00","#407331","#00608A"))
