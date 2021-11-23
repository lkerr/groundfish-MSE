####F Trajectory Plot####
#Lists numbers of scenarios that you want to compare here
Scenarios<-c(7,8,9)
#Set working directory--where the results you want to compare are stored
wd<-"C:/Users/mmazur/Desktop/COCA_Sims"
#List what is being compared
comparison<-c('Ramp','F-step','Constrained ramp')

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
  Catchsim[,k]<-omvalGlobal[[1]]$F_full[136:187]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2038
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

####First Assessment####
Fest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Fest[,k]<-omvalGlobal[[1]]$Fest[190,]
}

Fest<-rowMedians(Fest,na.rm=T)
Fest<-na.omit(Fest)

df$Fest<-Fest

####Other Sims####
for (m in 2:length(comparison)){
setwd(paste(wd,"/Sim_",Scenarios[m],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=52,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$F_full[136:187]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1987:2038
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[m]

Fest<-matrix(NA,nrow=54,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Fest[,k]<-omvalGlobal[[1]]$Fest[190,]
}

Fest<-rowMedians(Fest,na.rm=T)
Fest<-na.omit(Fest)

df2$Fest<-Fest

df<-full_join(df,df2)
}

for (i in 1:length(comparison)){
  df$HCR[df$HCR==Scenarios[i]]<-comparison[i]
}
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=comparison)

df<-df[df$Year>1989,]
ggplot(df)+geom_line(aes(x=Year,y=Fest,color=HCR))+geom_point(aes(x=Year,y=Catchsim,color=HCR))+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('F')+geom_vline(xintercept=2019, linetype='dotted')+
  scale_color_colorblind()


