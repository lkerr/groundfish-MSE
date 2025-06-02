#####F_full REE Plot####
#Scenarios<-c(6,32,58,116)
####First Sims####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
nrep=10
assessfreq=2
Scenarios<-c(1,2)
setwd(paste("C:/Users/mazurm/Desktop/WGC_Scenarios/Sim_",Scenarios[1],"/sim",sep=""))
# setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[1],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[1],"/sim",sep=""))
sims <- list.files()

load(sims)

Catchsim<-matrix(NA,nrow=10,ncol=nrep)

for (k in 1:nrep){
  F_fulltrue<-omvalGlobal[[1]]$F_full[k,,171:189]
  for (i in seq(172,190,assessfreq)){
    Fest<-omvalGlobal[[1]]$Fest[k,,i,]
    Fest<-na.omit(Fest)
    Fest<-tail(Fest,1)
    Catchsim[(i-170)/assessfreq,k]<-((Fest-F_fulltrue[i-171])/F_fulltrue[i-171])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2022,2040,2)
df<-as.data.frame(cbind(Catchsim,Year))
df$Scenario<-Scenarios[1]

setwd(paste("C:/Users/mazurm/Desktop/WGC_Scenarios/Sim_",Scenarios[2],"/sim",sep=""))
# setwd(paste("C:/Users/mmazur/Desktop/COCA_Sims/Sim_",Scenarios[1],"/sim",sep=""))
#setwd(paste("C:/Users/jjesse/Box/HCR_Sims/Sim_",Scenarios[1],"/sim",sep=""))
sims <- list.files()

load(sims)

Catchsim<-matrix(NA,nrow=10,ncol=nrep)

for (k in 1:nrep){
  F_fulltrue<-omvalGlobal[[1]]$F_full[k,,171:189]
  for (i in seq(172,190,assessfreq)){
    Fest<-omvalGlobal[[1]]$Fest[k,,i,]
    Fest<-na.omit(Fest)
    Fest<-tail(Fest,1)
    Catchsim[(i-170)/assessfreq,k]<-((Fest-F_fulltrue[i-171])/F_fulltrue[i-171])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2022,2040,2)
df2<-as.data.frame(cbind(Catchsim,Year))
df2$Scenario<-Scenarios[2]
df<-full_join(df,df2)

df$Scenario[df$Scenario==Scenarios[1]]<-'Base'
df$Scenario[df$Scenario==Scenarios[2]]<-'Uncertainty in ages'
# df$HCR[df$HCR==Scenarios[3]]<-'Constrained ramp'
# df$HCR[df$HCR==Scenarios[4]]<-'Constrained ramp'
# df$HCR<-as.factor(df$HCR)
# df$HCR<-ordered(df$HCR,levels=c('Ramp','F-step','Constrained ramp'))

ggplot(df)+geom_line(aes(x=Year,y=Catchsim,color=Scenario),size=1)+
  theme_classic()+theme(text=element_text(size=18),legend.position='bottom')+
  ylab('%REE SSB')+ ylim(min(-15,min(df$Catchsim)),max(15,max(df$Catchsim)))+
  scale_color_colorblind()+
  scale_x_continuous(limits = c(2022,2040))
