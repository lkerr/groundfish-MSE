

get_implementationF <- function(type, stock){

  within(stock, {

    if(type == 'advicenoError'){

      F_full[y]<- F_fullAdvice[y]
      F_comfull[y]<- F_comfullAdvice[y]
      F_recfull[y]<- F_recfullAdvice[y]

    }
    if(type == 'adviceWithError'){

        # Borrowed error_idx function from survey function bank
        Fimpl <- F_fullAdvice[y] + F_fullAdvice[y]*ie_bias #0 = no bias
        F_full[y] <- get_error_idx(type = ie_typ,
                                   idx = Fimpl,
                                   par = ie_F)
        
        comFimpl <- comF_fullAdvice[y] + comF_fullAdvice[y]*ie_bias
        comF_full[y] <- get_error_idx(type = ie_typ,
                                   idx = comFimpl,
                                   par = ie_F)
        
        recFimpl <- recF_fullAdvice[y] + recF_fullAdvice[y]*ie_bias
        recF_full[y] <- get_error_idx(type = ie_typ,
                                   idx = recFimpl,
                                   par = ie_F)
        
        
}
        # add implimentation bias to catch, need to convert from F to catch, back to F
        # get catch in numbers using the Baranov catch equation from advised F

    else if(type == 'advicewithcatchbias'){
      if(nfleet == 2){
        stop('advicewithcatchbias has not been updated to work with two fleets')
      }
        CN_temp[y,] <- get_catch(F_full=F_full[y], M=natM[y],
                                 N=J1N[y,], selC=slxC[y,]) + 1e-3

        # Figure out the advised catch weight-at-age
        codCW[y,] <- CN_temp[y,] *  waa[y,]

        # add bias to sum catch weight

        codCW2[y] <- sum(codCW[y,]) + (sum(codCW[y,]) * C_mult)

        if(Change_point2==TRUE && yrs[y]>=Change_point_yr){
        codCW2[y] <- sum(codCW[y,])
        }

        if(Change_point3==TRUE && yrs[y]>=Change_point_yr1){
          codCW2[y] <- sum(codCW[y,]) + (sum(codCW[y,]) * 0.5)
        }

        if(Change_point3==TRUE && yrs[y]>=Change_point_yr2){
          codCW2[y] <-sum(codCW[y,])
        }

        # Determine what the fishing mortality would have to be to get
        # that biased catch level (convert biased catch back to F).
        # Update codGOM fully selected fishing mortality to that value.

        # ST method using solver;
         F_full[y] <- get_F(x = c(codCW2[y]),
                           Nv = J1N[y,],
                           slxCv = slxC[y,],
                           M = natM[y],
                           waav = waa[y,])
}

         # Using Pope's approximation;
         # codCW2 needs to be converted to at-age to use
         
         # F_full[y] <- get_PopesF(yield = c(codCW2[y,]),
         #                                      naa = J1N[y,],
         #                                      waa = waa[y,],
         #                                      saa = slxC[y,],
         #                                      M = natM[y],
         #                                      ra = c(8))

    else if(type == '2fleeterror'){
      
      if(nfleet != 2){
        stop('2fleeterror only works with two fleets')
      }
      

      comCN_temp[y,] <- get_2fcatch(comF_full = comF_fullAdvice[y], recF_full = recF_fullAdvice[y], 
                                    M=natM[y],  N=J1N[y,], selC=slxC[y,], selR = slxR[y,], type = "com") + 1e-3
      
      recCN_temp[y,] <- get_2fcatch(comF_full = comF_fullAdvice[y], recF_full = recF_fullAdvice[y], 
                                    M=natM[y],  N=J1N[y,], selC=slxC[y,], selR = slxR[y,], type = "rec") + 1e-3
      
      
      # Figure out the advised commercial catch weight-at-age 
      codcomCW[y,] <- comCN_temp[y,] *  waa[y,]
      
      # add bias to sum commercial catch weight
      codcomCW2[y] <- sum(codcomCW[y,]) #+ (sum(codCW[y,]) * C_mult)
      
      codcomCW2[y] <- sum(codcomCW[y,]) * get_error_idx(type = ie_typ,
                                                        idx = 0.99,
                                                        par = 0.01)
      
      # Figure out the advised recreational catch weight-at-age
      codrecCW[y,] <- recCN_temp[y,] *  waa[y,]
      
      # add bias to sum rec catch weight
      codrecCW2[y] <- sum(codrecCW[y,]) * get_error_idx(type = ie_typ,
                                                        idx = 0.90,
                                                        par = 0.15)
      
      
      # add to get total 
      codCW[y,]  <- codcomCW[y,] + codrecCW[y,]
      codCW2[y] <- codcomCW2[y] + codrecCW2[y]

      # Determine what the fishing mortality would have to be to get
      # that biased catch level (convert biased catch back to F).
      # Update codGOM fully selected fishing mortality to that value.
      
      # ST method using solver;
      
      # use proportional catch for sel, as in get_nextF
      
      pcom.temp <- codcomCW2[y] / codCW2[y]
      
      
      scom <- selC * pcom.temp
      srec <- selR * (1-pcom.temp)
      sel.z <- scom + srec
      
      F_full[y] <- get_F(x = c(codCW2[y]),
                         Nv = J1N[y,],
                         slxCv = sel.z,
                         M = natM[y],
                         waav = waa[y,])

      comF_full[y] <-  F_full[y]  * pcom.temp
      recF_full[y] <-  F_full[y]  * (1-pcom.temp)
      

      
    }else{

      stop('get_implementationF: type not recognized')

    }


  })

}
