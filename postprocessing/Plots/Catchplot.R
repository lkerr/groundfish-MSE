#####sumCW Trajectory Plots####
Scenarios<-c(40,41,42,43)
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

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[136:188]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1988:2039
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_sumCW[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

####First Assessment####
Catchest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchest[,k]<-omvalGlobal[[1]]$Catchest[190,]
}

Catchest<-rowMedians(Catchest,na.rm=T)
Catchest<-na.omit(Catchest)

if (RhoAdj==TRUE){
  Catchest[length(Catchest)]<-Catchest[length(Catchest)]/(Mohn+1)
}

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

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[136:188]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1988:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[2]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_sumCW[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

####Second Assessment####
Catchest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchest[,k]<-omvalGlobal[[1]]$Catchest[190,]
}

Catchest<-rowMedians(Catchest,na.rm=T)
Catchest<-na.omit(Catchest)

if (RhoAdj==TRUE){
  Catchest[length(Catchest)]<-Catchest[length(Catchest)]/(Mohn+1)
}
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

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[136:188]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1988:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[3]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_sumCW[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

####Third Assessment####
Catchest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchest[,k]<-omvalGlobal[[1]]$Catchest[190,]
}

Catchest<-rowMedians(Catchest,na.rm=T)
Catchest<-na.omit(Catchest)

if (RhoAdj==TRUE){
  Catchest[length(Catchest)]<-Catchest[length(Catchest)]/(Mohn+1)
}
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

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[136:188]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1988:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[4]

if (RhoAdj==TRUE){
  Mohn<-rep(NA,length(sims))
  for (k in 1:length(sims)){
    load(sims[k])
    Mohn[k]<-omvalGlobal[[1]]$Mohns_Rho_sumCW[190]
  }
  Mohn<-mean(Mohn,na.rm=T)
}

####Fourth Assessment####
Catchest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchest[,k]<-omvalGlobal[[1]]$Catchest[190,]
}

Catchest<-rowMedians(Catchest,na.rm=T)
Catchest<-na.omit(Catchest)

if (RhoAdj==TRUE){
  Catchest[length(Catchest)]<-Catchest[length(Catchest)]/(Mohn+1)
}
df2$Catchest<-Catchest

df<-full_join(df,df2)

df$HCR[df$HCR==Scenarios[1]]<-'Ramp'
df$HCR[df$HCR==Scenarios[2]]<-'P*'
df$HCR[df$HCR==Scenarios[3]]<-'F-step'
df$HCR[df$HCR==Scenarios[4]]<-'Constrained ramp'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Ramp','P*','F-step','Constrained ramp'))

df<-df[df$Year>1989,]
df$Year<-df$Year-1
ggplot(df)+geom_line(aes(x=Year,y=Catchest,color=HCR))+geom_point(aes(x=Year,y=Catchsim,color=HCR))+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('Catch (mt)')+geom_vline(xintercept=2019, linetype='dotted')+
  scale_color_colorblind()



