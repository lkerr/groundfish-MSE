pstar<-function(OFL,parmgtproj,parpopproj,parenv,Rfun,stockEnv,level){
  getFpstar <- function(logF){
    F <- exp(logF)
    catchproj<-rep(NA,100)
  for (i in 1:100){
    catchproj[i]<-get_proj(type = 'current',
                            parmgt = parmgtproj, 
                            parpop = parpopproj, 
                            parenv = parenv, 
                            Rfun = Rfun,
                            F_val = F,
                            ny = 200,
                            stReportYr = 2,
                            stockEnv = stockEnv)$sumCW[1]
  }
    nage <- length(parpopproj$sel)
    N <- matrix(0, nrow=1, ncol=nage)
    init <- tail(parpopproj$J1N, 1)
    N[1,] <- init 
  for(a in 2:(nage-1)){
      #init= population at the beginning of the year in t-1  
      #exponential survival to the next year/age (t)
      N[1,a] <- init[a-1] * exp(-parpopproj$sel[a-1]*parpopproj$Fhat - 
                                  parpopproj$M[a-1])
    }
    # Deal with the plus group
    N[1,nage] <- init[nage-1] * exp(-parpopproj$sel[nage-1] * parpopproj$Fhat - 
                                      parpopproj$M[nage-1]) + 
      init[nage] * exp(-parpopproj$sel[nage] * parpopproj$Fhat - 
                         parpopproj$M[nage])
    
    R<-parpopproj$R
    
   if (mproc$rhoadjust==TRUE & y>165){
      R[length(R)]<-R[length(R)]/(1+stockEnv$Mohns_Rho_R[y])
    }
    
  N[1,1] <- prod(tail(R,5))^(1/5)
  
  Fvec<-rep(NA,length(catchproj[i]))
  for (i in 1:100){
  Fvec[i] <- get_F(x = catchproj[i],
             Nv = N, 
             slxCv = parpopproj$sel, 
             M = parpopproj$M, 
             waav = parpopproj$waa)
  }
  Fvec[Fvec>OFL]<-1
  Fvec[Fvec<OFL]<-0
  Fprob<-mean(Fvec)
  diff <- abs(level - Fprob)
  return(diff)
  }
  opt <- try(optimize(getFpstar, interval=c((log(OFL)-1.5), (log(OFL)+1.5)), tol=0.01))
  return(exp(opt$minimum))
}