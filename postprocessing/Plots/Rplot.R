#####R Trajectory Plots####
#####R Trajectory Plots####
Scenarios<-c(7,8,9)
RhoAdj<-FALSE
Stock<-'codGOM'
####First Sims####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
wd<-getwd()
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
  Catchsim[,k]<-omvalGlobal[[1]]$R[136:187]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2038
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_R[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

####First Assessment####
Rest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Rest[,k]<-omvalGlobal[[1]]$Rest[190,]
}

Rest<-rowMedians(Rest,na.rm=T)
Rest<-na.omit(Rest)

if (RhoAdj==TRUE){
  Rest[length(Rest)]<-Rest[length(Rest)]/(Mohn+1)
}

df$Rest<-Rest

####Second Sims####
setwd(paste(wd,"/Sim_",Scenarios[2],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=52,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$R[136:187]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2038
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[2]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_R[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

####Second Assessment####
Rest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Rest[,k]<-omvalGlobal[[1]]$Rest[190,]
}

Rest<-rowMedians(Rest,na.rm=T)
Rest<-na.omit(Rest)

if (RhoAdj==TRUE){
  Rest[length(Rest)]<-Rest[length(Rest)]/(Mohn+1)
}
df2$Rest<-Rest

df<-full_join(df,df2)

####Third Sims####
setwd(paste(wd,"/Sim_",Scenarios[3],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=52,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$R[136:187]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2038
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[3]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_R[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

####Third Assessment####
Rest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Rest[,k]<-omvalGlobal[[1]]$Rest[190,]
}

Rest<-rowMedians(Rest,na.rm=T)
Rest<-na.omit(Rest)

if (RhoAdj==TRUE){
  Rest[length(Rest)]<-Rest[length(Rest)]/(Mohn+1)
}
df2$Rest<-Rest

df<-full_join(df,df2)

####Fourth Sims####
setwd(paste(wd,"/Sim_",Scenarios[4],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=52,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$R[136:187]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2038
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[4]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_R[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

####Fourth Assessment####
Rest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Rest[,k]<-omvalGlobal[[1]]$Rest[190,]
}

Rest<-rowMedians(Rest,na.rm=T)
Rest<-na.omit(Rest)

if (RhoAdj==TRUE){
  Rest[length(Rest)]<-Rest[length(Rest)]/(Mohn+1)
}
df2$Rest<-Rest

df<-full_join(df,df2)

df$HCR[df$HCR==Scenarios[1]]<-'Ramp'
df$HCR[df$HCR==Scenarios[2]]<-'F-step'
df$HCR[df$HCR==Scenarios[3]]<-'Constrained ramp'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Ramp','F-step','Constrained ramp'))

df<-df[df$Year>1989,]
ggplot(df)+geom_line(aes(x=Year,y=Rest,color=HCR))+geom_point(aes(x=Year,y=Catchsim,color=HCR))+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('Recruitment')+geom_vline(xintercept=2019, linetype='dotted')+
  scale_color_colorblind()
