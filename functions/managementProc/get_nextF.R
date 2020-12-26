# The application of harvest control rules
#
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function is the (1-row) column
#         "HCR". Options are:
#  
#           * "slide": based on national standard 1 precautionary approach, this is
#               the classic harvest control rule that increases linearly and 
#               then reaches an asymptote at [Bmsy,Fmsy]
#        
#           * "simpleThresh": a simple threshold model where fishing is entirely
#               cut off when the population is overfished (i.e., B<Bmsy)
#
#           * "constF": fishing mortlality is constant at the fishing mortality target
#               regardless of population size
#                        
# parpop: named ist of population parameters (vectors) needed for the 
#         simulation including selectivity (sel), weight-at-age (waa),
#         recruitment (R), maturity (mat) and natural mortality (M).
#         Natural mortality can be a vector or a scalar. Vectors have
#         one value per age class.
#         
# Rlast: a vector of length 2 representing the Fmsy and Bmsy reference points
#        that were used in the previous year of the simulation. The reason
#        for this is so you can evaluate management procedures that only
#        update reference points once every N number of years.
#        
# evalRP: True/False variable indicating whether reference points should
#         be evaluated at all -- if not then just use RPlast. Function
#         could be simplified a little to combine RPlast and evalRP but
#         it is pretty clear this way at least.


get_nextF <- function(parmgt, parpop, parenv, RPlast, evalRP, stockEnv){

  # A general application of national standard 1 reference points. There
  # are different ways to grab the F reference point and the B reference
  # point and those will be implemented in get_FBRP
  
  if(parmgt$ASSESSCLASS == 'CAA' || parmgt$ASSESSCLASS == 'ASAP'){
    
    # for GOM cod, Mramp model uses M = 0.2 for status determination
    # browser()
    if(names(stock) == 'codGOM' && stock$codGOM$M_typ == 'ramp'){
      
      #insert new M's
      parpop$M[1,] <- rep(0.2, 9) 

      #recalculate reference points
      Fref <- get_FBRP(parmgt = parmgt, parpop = parpop, 
                              parenv = parenv, Rfun_lst = Rfun_BmsySim, 
                              stockEnv = stockEnv)
      
      # if using forecast start the BMSY initial population at the equilibrium
      # FMSY level (before any temperature projections). This is consistent
      # with how the Fmsy is calculated.
      parpopUpdate <- parpop
      if(parmgt$RFUN_NM == 'forecast'){
        parpopUpdate$J1N <- Fref$equiJ1N_MSY
      }

      Bref <- get_BBRP(parmgt = parmgt, parpop = parpopUpdate, 
                              parenv = parenv, Rfun_lst = Rfun_BmsySim,
                              FBRP = Fref[['RPvalue']], stockEnv = stockEnv)
      
 
    } else { 
   
    Fref <- get_FBRP(parmgt = parmgt, parpop = parpop, 
                     parenv = parenv, Rfun_lst = Rfun_BmsySim, 
                     stockEnv = stockEnv)

    # if using forecast start the BMSY initial population at the equilibrium
    # FMSY level (before any temperature projections). This is consistent
    # with how the Fmsy is calculated.
    parpopUpdate <- parpop
    if(parmgt$RFUN_NM == 'forecast'){
      
      parpopUpdate$J1N <- Fref$equiJ1N_MSY
      
    }
    
    Bref <- get_BBRP(parmgt = parmgt, parpop = parpopUpdate, 
                     parenv = parenv, Rfun_lst = Rfun_BmsySim,
                     FBRP = Fref[['RPvalue']], stockEnv = stockEnv)
    
    }
    if(evalRP){
      FrefRPvalue <- Fref[['RPvalue']]
      BrefRPvalue <- Bref[['RPvalue']]
    }else{
      FrefRPvalue <- RPlast[1]
      BrefRPvalue <- RPlast[2]
    }
    
    # Determine whether the population is overfished and whether 
    # overfishing is occurring
    


    # otherwise just use same reference points values    
    BThresh <- BrefScalar * BrefRPvalue
    FThresh <- FrefScalar * FrefRPvalue
    
    overfished <- ifelse(tail(parpop$SSBhat,1) < BThresh, 1, 0)
    
    overfishing <- ifelse(tail(parpop$Fhat,1) > FThresh, 1, 0) #AEW
    
    if(tolower(parmgt$HCR) == 'slide' |tolower(parmgt$HCR) == 'reject'){
     
      F <- get_slideHCR(parpop, Fmsy=FThresh, Bmsy=BThresh)['Fadvice']

    }else if(tolower(parmgt$HCR) == 'simplethresh'){
     
      # added small value to F because F = 0 causes some estimation errors
      F <- ifelse(tail(parpop$SSBhat, 1) < BThresh, 0, FThresh)+1e-4
      
    }else if(tolower(parmgt$HCR) == 'constf'){
 
      F <- FThresh
      
    }
    else if(tolower(parmgt$HCR) == 'xyrconstc'){
      if ((y-fmyearIdx) %% as.numeric(tolower(parmgt$AssessFreq)) == 0){
        F <- FThresh
      }
      else{
        F <- get_F(x = stock$codGOM$quota,
                         Nv = stock$codGOM$J1N[y,], 
                         slxCv = stock$codGOM$slxC[y,], 
                         M = stock$codGOM$natM[y], 
                         waav = stock$codGOM$waa[y,])
      }
      }
    else if(tolower(parmgt$HCR) == 'step'){
      if (y==fmyearIdx & overfished== 1){F<-FrefRPvalue*0.7}
      else if (y==fmyearIdx & overfished== 0){F<-FThresh}
      else if (y>fmyearIdx & overfished== 1){F<-FrefRPvalue*0.7}
      else if (y>fmyearIdx & overfished== 0){
        if(any(stockEnv$OFdStatus==1)& tail(stockEnv$res$SSB,1)<BrefRPvalue){F<-FrefRPvalue*0.7}
        else{F<-FThresh}}
    }
    else if(tolower(parmgt$HCR) == 'pstar'){
      parmgtproj<-parmgt
      parmgtproj$RFUN_NM<-"forecast"
      parpopproj<-parpop
      parpopproj$SSBhat<-stockEnv$res$SSB
      parpopproj$R<-stockEnv$res$N.age[,1]
      parpopproj$J1N<-tail(stockEnv$res$N.age,1)
      Rfun<-Rfun_BmsySim$forecast
      F<-pstar(maxp=0.4,relB=tail(stockEnv$res$SSB,1)/BThresh,parmgtproj=parmgtproj,parpopproj=parpopproj,parenv=parenv,Rfun=Rfun,stockEnv=stockEnv,FrefRPvalue=FrefRPvalue)
    }
    else{
      
      stop('get_nextF: type not recognized')
      
    }
    if(tolower(parmgt$projections) == 'true'){
      if ((y-fmyearIdx) %% as.numeric(tolower(parmgt$AssessFreq)) == 0){
      parmgtproj<-parmgt
      parmgtproj$RFUN_NM<-"forecast"
      catchproj<-matrix(ncol=2,nrow=100)
      parpopproj<-parpop
      parpopproj$SSBhat<-stockEnv$res$SSB
      parpopproj$R<-stockEnv$res$N.age[,1]
      parpopproj$J1N<-tail(stockEnv$res$N.age,1)
      for (i in 1:100){
          catchproj[i,]<-get_proj(type = 'current',
                                  parmgt = parmgtproj, 
                                  parpop = parpopproj, 
                                  parenv = parenv, 
                                  Rfun = Rfun_BmsySim$forecast,
                                  F_val = F,
                                  ny = 200,
                                  stReportYr = 2,
                                  stockEnv = stockEnv)$sumCW}
      catchproj<-c(median(catchproj[,1]),median(catchproj[,2]))
      if(tolower(parmgt$HCR) == 'reject'){
        if (y>fmyearIdx & stockEnv$Mohns_Rho_F[y]>0.5 | y>fmyearIdx & stockEnv$Mohns_Rho_SSB[y]>0.5 | y>fmyearIdx & stockEnv$Mohns_Rho_R[y]>0.5){
     catchproj<-c(stockEnv$obs_sumCW[y-1],stockEnv$obs_sumCW[y-1])
        }} 
      if(tolower(parmgt$mincatch) == 'true'){
      if (stockNames == 'codGOM'){
         mincatchv<-tail(read.csv('data/data_raw/AssessmentHistory/codGOM_Discard.csv'),10)
         colnames(mincatchv)<-c('Year','Catch')
         mincatchv$Catch<-mincatchv$Catch
         mincatchv$Year<-155:164
         }
      if (stockNames == 'haddockGB'){
         mincatchv<-as.data.frame(cbind(155:164,stock$haddockGB$sumCW[(y-10):(y-1)]))
         colnames(mincatchv)<-c('Year','Catch')
      }
      if (y>fmyearIdx){
          for (i in fmyearIdx:(y-1)){
          catchadd<-c(i,stockEnv$obs_sumCW[i])
          mincatchv<-rbind(mincatchv,catchadd)
          }
      }
      if (catchproj[1]<min(tail(mincatchv$Catch,10))){catchproj[1]<-min(tail(mincatchv$Catch,10))}
      if (catchproj[2]<min(c(tail(mincatchv$Catch,9),catchproj[1]))){catchproj[2]<-min(c(tail(mincatchv$Catch,9),catchproj[1]))}
      }
      if(tolower(mproc$varlimit) == 'true'){
        if(((catchproj[1]-(stockEnv$sumCW[y-1]*stockEnv$ob_sumCW))/catchproj[1])*100<(-20)){
          catchproj[1]<-(stockEnv$sumCW[y-1]*stockEnv$ob_sumCW)-((stockEnv$sumCW[y-1]*stockEnv$ob_sumCW)*.2)}
        if(((catchproj[1]-(stockEnv$sumCW[y-1]*stockEnv$ob_sumCW))/catchproj[1])*100>20){
          catchproj[1]<- (stockEnv$sumCW[y-1]*stockEnv$ob_sumCW)+((stockEnv$sumCW[y-1]*stockEnv$ob_sumCW)*.2)}
        if(((catchproj[2]-catchproj[1])/catchproj[2])*100<(-20)){
          catchproj[2]<- catchproj[1]-(catchproj[1]*.2)}
        if(((catchproj[2]-catchproj[1])/catchproj[2])*100>20){
          catchproj[2]<- catchproj[1]+(catchproj[1]*.2)}
      }
      Fest<-get_estF(catchproj=catchproj[1],parmgtproj=parmgtproj,parpopproj=parpopproj,parenv=parenv,Rfun=Rfun,stockEnv=stockEnv)
      if (Fest>FrefRPvalue){
        catchproj<-matrix(ncol=2,nrow=100)
        for (i in 1:100){
            catchproj[i,]<-get_proj(type = 'current',
                                    parmgt = parmgtproj, 
                                    parpop = parpopproj, 
                                    parenv = parenv, 
                                    Rfun = Rfun_BmsySim$forecast,
                                    F_val = FrefRPvalue,
                                    ny = 200,
                                    stReportYr = 2,
                                    stockEnv = stockEnv)$sumCW}
        catchproj<-c(median(catchproj[,1]),median(catchproj[,2]))
        if(tolower(mproc$varlimit) == 'true'){
          if(((catchproj[2]-catchproj[1])/catchproj[2])*100>20){
            catchproj[2]<- catchproj[1]+(catchproj[1]*.2)}
        }
      }
      F <- get_F(x = catchproj[1],
                   Nv = stockEnv$J1N[y,], 
                   slxCv = stockEnv$slxC[y,], 
                   M = stockEnv$natM[y], 
                   waav = stockEnv$waa[y,])
      }
      else{
      F <- get_F(x = stockEnv$catchproj[2],
                 Nv = stockEnv$J1N[y,], 
                 slxCv = stockEnv$slxC[y,], 
                 M = stockEnv$natM[y], 
                 waav = stockEnv$waa[y,])
      catchproj<-stockEnv$catchproj
      }
    }
  
    out <- list(F = F, RPs = c(FrefRPvalue, BrefRPvalue), 
                ThresholdRPs = c(FThresh, BThresh), OFdStatus = overfished,
                OFgStatus = overfishing, catchproj=catchproj) #AEW
    
  }else if(parmgt$ASSESSCLASS == 'PLANB'){
    
    # Find the recommended level for catch in weight
    CWrec <- tail(parpop$obs_sumCW, 1) * parpop$mult
    
    #### NEXT MIGRATE THE WEIGHT TO A FISHING MORTALITY
    #### you know what the selectivity is going to be 
    #### (use the real one here) and you know what the weight is
    #### going to be (use the real one) so drive the F as hard as
    #### required in each of the age classes until you land on
    #### the desired catch biomass.
    
    # Calculate what the corresponding true F is that matches with
    # the actual biomass-at-age in the current year
    trueF <- get_F(x = CWrec,
                  Nv = parpop$Ntrue_y, 
                  slxCv = parpop$slxCtrue_y, 
                  M = parpop$Mtrue_y, 
                  waav = parpop$waatrue_y)
    
    out <- list(F = trueF, RPs = c(NA, NA), OFdStatus=NA,
                OFgStatus = NA) #AEW
    
  }else{
    
    stop('Assessment class not recognized')
    
  }
  
}




