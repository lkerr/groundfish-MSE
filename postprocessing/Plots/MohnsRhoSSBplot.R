#####Mohn's Rho for SSB Plot####
#Scenarios<-c(6,32,58,116)
Scenarios<-c(7,8,9)
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

Catchsim<-matrix(NA,nrow=56,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$Mohns_Rho_SSB[134:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1984:2039
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

###Second Sims####
setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[2],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[2],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=56,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$Mohns_Rho_SSB[134:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1984:2039
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

Catchsim<-matrix(NA,nrow=56,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$Mohns_Rho_SSB[134:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1984:2039
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

Catchsim<-matrix(NA,nrow=56,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$Mohns_Rho_SSB[134:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1984:2039
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

Catchsim<-matrix(NA,nrow=56,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$Mohns_Rho_SSB[134:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1984:2039
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[5]

df<-full_join(df,df2)

df$HCR[df$HCR==Scenarios[1]]<-'Ramp'
df$HCR[df$HCR==Scenarios[2]]<-'F-step'
df$HCR[df$HCR==Scenarios[3]]<-'Constrained ramp'
# df$HCR[df$HCR==Scenarios[4]]<-'Two Year Updates and Miss'
# df$HCR[df$HCR==Scenarios[5]]<-'Lag, Miss, and 2 Year Updates'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Ramp','F-step','Constrained ramp'))

df<-na.omit(df)

ggplot(df)+geom_line(aes(x=Year,y=Catchsim,color=HCR),size=1)+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('Mohns Rho for SSB')+ylim(-0.5,0.9)+
  scale_color_colorblind()+
  scale_x_continuous(limits = c(2020,2040))

