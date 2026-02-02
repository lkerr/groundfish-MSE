library(dplyr)
library(pacea)
library(RTMB)

df<-read.csv('PetraleSSB.csv')
colnames(df)<-c('Year','SSB')
df2<-read.csv('data/data_raw/AssessmentHistory/petraleBC.csv')
df2$F<-df2$M<-NULL
df<-full_join(df,df2)

sum.dat <- oisst_month %>%
  group_by(year) %>%
  summarise(median_val = median(sst, na.rm = TRUE))
sum.dat$geometry<-NULL
colnames(sum.dat)<-c('Year','Temp')
df<-full_join(df,sum.dat)

srdat <- as.data.frame(cbind(YEAR = df$Year,
                             T = df$Temp,
                             S = df$SSB,
                             R = df$R * 1000))
srdat <- srdat[complete.cases(srdat),]

# indexes to use for ssb and R data -- there is a one-year
# lag in this case.
idxSSB <- 1:(nrow(srdat)-1)
idxR <- 2:nrow(srdat)

data <- list(S = srdat$S[idxSSB],
             R = srdat$R[idxR],
             T = srdat$T[idxSSB] - mean(srdat$T[idxSSB]),
             nobs = length(idxSSB))

par<-list(log_a=-1.02,log_b=1,log_c=0,log_sig=-1)

drob <- function(x,m,s, p=0.05, log=FALSE){
  z<-(x-m)/s  
res<-((1-p)*dnorm(z)+p*dt(z,df=3))/s
if(log){
  return(log(res))
}else{
  return(res)
}
}

BH<-function(par){
  getAll(data,par)
  alpha<-exp(log_a)
  beta<-exp(log_b)
  c<-exp(log_c)
  sig<-exp(log_sig)
  
  lpred<-log(alpha*S/(1+beta*S))+(c*T)
  
  jnll<- -sum(drob(log(R),lpred,sig,log=TRUE))
  
  ADREPORT(alpha)
  ADREPORT(beta)
  ADREPORT(c)
  return(jnll)
}
 
obj <- MakeADFun(BH, par)
opt <- nlminb(obj$par, obj$fn, obj$gr)
newtonsteps <- 1
for(i in seq_len(newtonsteps)) {
  g <- as.numeric(obj$gr(opt$par))
  h <- stats::optimHess(opt$par, obj$fn, obj$gr) # Hessian matrix
  new_par <- opt$par - solve(h, g)
  # rewrite results
  opt <- nlminb(new_par, obj$fn, obj$gr,control = list(eval.max = 1e4, iter.max = 1e4))
}

Sdrep<-sdreport(obj)
est_par<-as.list(Sdrep, what="Est") #EXACT SAME STRUCTURE AS PARAMETER VECTOR
sd_par<-as.list(Sdrep, what="Std")

est_der<-as.list(Sdrep,report=TRUE, what="Est")
sd_der<-as.list(Sdrep,report=TRUE,  what="Std")

pred<-(exp(est_par$log_a)*data$S)/(1+exp(est_par$log_b)*data$S)*exp(exp(est_par$log_c)*data$T)
