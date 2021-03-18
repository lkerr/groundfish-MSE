# The application of harvest control rules
#
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function is the (1-row) column
#         "HCR". Options are:
#  
#  **constF**: The harvest control rule is simply a flat line, in other words no matter what in each year 
#F will be determined by the F reference point.
#
#  **simplethresh**: A simple threshold model. If the estimated SSB is larger than the SSB reference point
#then the advice will be fishing at the F reference point. If the estimated SSB is smaller than the SSB 
#reference point F will be 0.
#
#  **slide**: A sliding control rule.  Similer to simplethresh, except when the estimated SSB is lower 
#than the SSB reference point fishing is reduced though not all the way to zero. Instead, a line is drawn
#between [SSBRefPoint, FRefPoint] and [0, 0] and the advice is the value for F on that line at the 
#corresponding estimate of SSB.
#
#  **pstar**: The P* method. The aim of this HCR option is to avoid overfishing by accounting for 
#scientific uncertainty with a probabilistic approach. In this scenario, the P* approach (Prager & 
#Shertzer, 2010) is used to derive target catch. The P* method derives target catch as a low percentile of
#projected catch at the OFL, to allow for scientific uncertainty. The distribution of the catch at the OFL
#was assumed to follow a lognormal distribution with a CV of 1 (Wiedenmann et al., 2016). The target catch
#will correspond to a probability of overfishing no higher than 50% (P* <0.5) in accordance with the 
#National Standard 1 guidelines.
#
#  **step**: Step in fishing mortality. If the SSB decreased below the biomass threshold, this HCR uses a
#target F of 70% FMSY that has recently been applied to New England groundfish as a default Frebuild. If 
#the SSB never decreased below the biomass threshold or increased to over SSBMSY after dropping below the 
#biomass threshold, this HCR uses a target F at the F threshold. This alternative directly emulates an HCR
#used for some New England groundfish. 
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
    if(names(stock) == 'codGOM' && stock$codGOM$M_typ == 'ramp'){
      
      #insert new M's
      parpop$M[1,] <- rep(0.2, 9) 

      #recalculate reference points
      parpop$switch<-FALSE
      Fref <- get_FBRP(parmgt = parmgt, parpop = parpop, 
                              parenv = parenv, Rfun_lst = Rfun_BmsySim, 
                              stockEnv = stockEnv)
      
      parmgtT<-parmgt
      parpopT<-parpop
      parpopT$switch<-TRUE
      parpopT$J1N<-stockEnv$J1N[1:(y-1),]
      parpopT$selC<-stockEnv$selC
      stockEnvT<-stockEnv
      stockEnvT$R_mis<-FALSE
      FrefT <- get_FBRP(parmgt = parmgtT, parpop = parpopT, #Also calculate the true Fmsy
                        parenv = parenv, Rfun_lst = Rfun_BmsySim, 
                        stockEnv = stockEnvT)
      
      # if using forecast start the BMSY initial population at the equilibrium
      # FMSY level (before any temperature projections). This is consistent
      # with how the Fmsy is calculated.
      parpopUpdate <- parpop
      parpopUpdateT <- parpopT
      
      if(parmgt$RFUN_NM == 'forecast'){
        parpopUpdate$J1N <- Fref$equiJ1N_MSY
      }

      Bref <- get_BBRP(parmgt = parmgt, parpop = parpopUpdate, 
                              parenv = parenv, Rfun_lst = Rfun_BmsySim,
                              FBRP = Fref[['RPvalue']], stockEnv = stockEnv)
   
      stockEnvT<-stockEnv
      stockEnvT$R_mis<-FALSE
      BrefT <- get_BBRP(parmgt = parmgtT, parpop = parpopUpdateT, #Also calculate the true Bmsy
                        parenv = parenv, Rfun_lst = Rfun_BmsySim,
                        FBRP = FrefT[['RPvalue']], stockEnv = stockEnvT)
      
 
    } else { 
    parpop$switch<-FALSE
    Fref <- get_FBRP(parmgt = parmgt, parpop = parpop, 
                     parenv = parenv, Rfun_lst = Rfun_BmsySim, 
                     stockEnv = stockEnv)
    parmgtT<-parmgt
    parpopT<-parpop
    parpopT$switch<-TRUE
    parpopT$J1N<-stockEnv$J1N[1:(y-1),]
    parpopT$selC<-stockEnv$selC
    stockEnvT<-stockEnv
    stockEnvT$R_mis<-FALSE
    FrefT <- get_FBRP(parmgt = parmgtT, parpop = parpopT, #Also calculate the true Fmsy
                     parenv = parenv, Rfun_lst = Rfun_BmsySim, 
                     stockEnv = stockEnvT)

    # if using forecast start the BMSY initial population at the equilibrium
    # FMSY level (before any temperature projections). This is consistent
    # with how the Fmsy is calculated.
    parpopUpdate <- parpop
    parpopUpdateT <- parpopT
    if(parmgt$RFUN_NM == 'forecast'){
      
      parpopUpdate$J1N <- Fref$equiJ1N_MSY
      
    }
 
    Bref <- get_BBRP(parmgt = parmgt, parpop = parpopUpdate, 
                     parenv = parenv, Rfun_lst = Rfun_BmsySim,
                     FBRP = Fref[['RPvalue']], stockEnv = stockEnv)
    
    stockEnvT<-stockEnv
    stockEnvT$R_mis<-FALSE
    BrefT <- get_BBRP(parmgt = parmgtT, parpop = parpopUpdateT, #Also calculate the true Bmsy
                     parenv = parenv, Rfun_lst = Rfun_BmsySim,
                     FBRP = FrefT[['RPvalue']], stockEnv = stockEnvT)
    
    }
    if(evalRP){
      FrefRPvalue <- Fref[['RPvalue']]
      BrefRPvalue <- Bref[['RPvalue']]
      FrefTRPvalue <- FrefT[['RPvalue']]
      BrefTRPvalue <- BrefT[['RPvalue']]
    }else{
      FrefRPvalue <- RPlast[1]
      BrefRPvalue <- RPlast[2]
      FrefTRPvalue <- FrefT[['RPvalue']]
      BrefTRPvalue <- BrefT[['RPvalue']]
    }
    
    # Determine whether the population is overfished and whether 
    # overfishing is occurring
    
    # otherwise just use same reference points values    
    BThresh <- BrefScalar * BrefRPvalue
    FThresh <- FrefScalar * FrefRPvalue
    
    overfished <- ifelse(tail(parpop$SSBhat,1) < BThresh, 1, 0)
    
    overfishing <- ifelse(tail(parpop$Fhat,1) > FrefRPvalue, 1, 0) #MDM
    
    if(tolower(parmgt$HCR) == 'slide'){
     
      F <- get_slideHCR(parpop, Fmsy=FThresh, Bmsy=BThresh)['Fadvice']

    }
    
    else if(tolower(parmgt$HCR) == 'tempslide'){
      
      F <- get_tempslideHCR(parpop, Fmsy=FThresh, Bmsy= BThresh, temp= Tanom[y])['Fadvice']
      
    }
    else if(tolower(parmgt$HCR) == 'simplethresh'){
     
      # added small value to F because F = 0 causes some estimation errors
      F <- ifelse(tail(parpop$SSBhat, 1) < BThresh, 0, FThresh)+1e-4
      
    }
    else if(tolower(parmgt$HCR) == 'constf'){
 
      F <- FThresh
      
    }
    else if(tolower(parmgt$HCR) == 'step'){
      if (y==fmyearIdx & overfished== 1){F<-FrefRPvalue*0.7}
      else if (y==fmyearIdx & overfished== 0){F<-FThresh}
      else if (y>fmyearIdx & overfished== 1){F<-FrefRPvalue*0.7}
      else if (y>fmyearIdx & overfished== 0){
        if(any(stockEnv$OFdStatus==1,na.rm=T)& tail(stockEnv$res$SSB,1)<BrefRPvalue){F<-FrefRPvalue*0.7}
        else{F<-FThresh}}
    }
    else if(tolower(parmgt$HCR) == 'pstar'){
      parmgtproj<-parmgt
      parmgtproj$RFUN_NM<-"forecast"
      parpopproj<-parpop
      parpopproj$SSBhat<-stockEnv$res$SSB
      parpopproj$R<-stockEnv$res$N.age[,1]
      parpopproj$J1N<-tail(stockEnv$res$N.age,1)
      parpopproj$catch<-stockEnv$res$catch.obs
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
      parpopproj$catch<-stockEnv$res$catch.obs
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
      if(tolower(parmgt$mincatch) == 'true'){
      if (stockEnv$stockName=='codGOM'){
        bycatch<-read.csv(paste('./data/data_raw/AssessmentHistory/codGOM_Discard.csv',sep=''))
        mincatch<-min(tail(bycatch$Discards),10)
      }
      if (stockEnv$stockName=='haddockGB'){
        bycatch<-read.csv(paste(getwd(),'/data/data_raw/AssessmentHistory/haddockGB_Discard.csv',sep=""))
        mincatch<-min(tail(bycatch$Discard),10)
      }
      if (catchproj[1]>mincatch & catchproj[2]>mincatch){mincatchcon<-0}
      if (catchproj[1]<mincatch){
        catchproj[1]<-mincatch
        mincatchcon<-1
      }
      if (catchproj[2]<mincatch){
        catchproj[2]<-mincatch
        mincatchcon<-1
      }
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
      if (F>2){F<-2}
      }
    }
    
    if(tolower(parmgt$projections) == 'false'){catchproj<-NA}
  
    if (F>2){F<-2}#Not letting actual F go over 2
    
    out <- list(F = F, RPs = c(FrefRPvalue, BrefRPvalue,FrefTRPvalue, BrefTRPvalue), 
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




