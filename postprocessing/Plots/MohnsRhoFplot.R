#####Mohn's Rho for F Plot####
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

Catchsim<-matrix(NA,nrow=56,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$Mohns_Rho_F[134:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1984:2039
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

for (i in 2:length(Scenarios)){
setwd(paste(wd,"/Sim_",Scenarios[i],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=56,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$Mohns_Rho_F[134:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1984:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[i]

df<-full_join(df,df2)
}

df$HCR[df$HCR==Scenarios[1]]<-'Ramp'
df$HCR[df$HCR==Scenarios[2]]<-'F-step'
df$HCR[df$HCR==Scenarios[3]]<-'Constrained ramp'
df$HCR[df$HCR==Scenarios[4]]<-'Constrained ramp'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Ramp','F-step','Constrained ramp'))

df<-na.omit(df)

ggplot(df)+geom_line(aes(x=Year,y=Catchsim,color=HCR),size=1)+
  theme_classic()+theme(text=element_text(size=18),legend.position='bottom')+
  ylab('Mohns Rho for F')+ylim(-0.5,0.5)+
  scale_color_colorblind()+
  scale_x_continuous(limits = c(2020,2040))
