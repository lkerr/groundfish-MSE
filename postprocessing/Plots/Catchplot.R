#####Catch Trajectory Plots####
#Lists numbers of scenarios that you want to compare here
Scenarios<-c(5,6,7,8)
#Set working directory--where the results you want to compare are stored
wd<-"C:/Users/mmazur/Box/Mackenzie_Mazur/HCR_Sims"
#List what is being compared
comparison<-c('Ramp','P*','F-step','Constrained ramp')
####Load packages####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
####First Sims####
setwd(paste(wd,"/Sim_",Scenarios[1],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))
Catchest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[136:188]
  Catchest[,k]<-omvalGlobal[[1]]$Catchest[190,]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2039
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]
Catchest<-rowMedians(Catchest,na.rm=T)
Catchest<-na.omit(Catchest)
df$Catchest<-Catchest

####Second Sims####
setwd(paste(wd,"/Sim_",Scenarios[2],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))
Catchest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[136:188]
  Catchest[,k]<-omvalGlobal[[1]]$Catchest[190,]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[2]
Catchest<-rowMedians(Catchest,na.rm=T)
Catchest<-na.omit(Catchest)
df2$Catchest<-Catchest

df<-full_join(df,df2)

####Third Sims####
setwd(paste(wd,"/Sim_",Scenarios[3],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))
Catchest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[136:188]
  Catchest[,k]<-omvalGlobal[[1]]$Catchest[190,]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[3]
Catchest<-rowMedians(Catchest,na.rm=T)
Catchest<-na.omit(Catchest)
df2$Catchest<-Catchest

df<-full_join(df,df2)

####Fourth Sims####
setwd(paste(wd,"/Sim_",Scenarios[4],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))
Catchest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[136:188]
  Catchest[,k]<-omvalGlobal[[1]]$Catchest[190,]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[4]
Catchest<-rowMedians(Catchest,na.rm=T)
Catchest<-na.omit(Catchest)
df2$Catchest<-Catchest

df<-full_join(df,df2)

Df$HCR[Df$HCR==Scenarios[1]]<-comparison[1]
Df$HCR[Df$HCR==Scenarios[2]]<-comparison[2]
Df$HCR[Df$HCR==Scenarios[3]]<-comparison[3]
Df$HCR[Df$HCR==Scenarios[4]]<-comparison[4]
df$HCR<-as.factor(df$HCR)
Df$HCR<-ordered(Df$HCR,levels=comparison)

df<-df[df$Year>1989,]
ggplot(df)+geom_line(aes(x=Year,y=Catchest,color=HCR))+geom_point(aes(x=Year,y=Catchsim,color=HCR))+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('Catch (mt)')+geom_vline(xintercept=2019, linetype='dotted')+
  scale_color_colorblind()



