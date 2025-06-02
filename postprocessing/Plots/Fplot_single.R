#####F_full REE Plot####
#Scenarios<-c(6,32,58,116)
####First Sims####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
setwd("C:/Users/mazurm/Documents/groundfish-MSE/results_2023-04-17-11-16-56/sim")
nrep=10
assessfreq=2
# setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[1],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[1],"/sim",sep=""))
sims <- list.files()

load(sims)

sims <- list.files()

sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=75,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$F_full[k,,115:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1966:2040
df<-as.data.frame(cbind(Catchsim,Year))

Fest<-matrix(NA,nrow=75,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Fest[,k]<-na.omit(omvalGlobal[[1]]$Fest[k,,190,])
}

Fest<-rowMedians(Fest,na.rm=T)
Fest<-na.omit(Fest)

df$Fest<-Fest

ggplot(df)+geom_line(aes(x=Year,y=Fest))+geom_point(aes(x=Year,y=Catchsim))+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('F')+geom_vline(xintercept=2019, linetype='dotted')+
  scale_color_colorblind()


