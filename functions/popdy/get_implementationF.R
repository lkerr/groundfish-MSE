

get_implementationF <- function(type, stock){

  within(stock, {

    if(type == 'advicenoError'){

      F_full[y]<- F_fullAdvice[y]
      
    } else if(type == 'adviceWithError'){

        # Borrowed error_idx function from survey function bank
        Fimpl <- F_fullAdvice[y] + F_fullAdvice[y]*ie_bias
        F_full[y] <- get_error_idx(type = ie_typ, 
                                   idx = Fimpl, 
                                   par = ie_F)
        
        
        # add implimentation bias to catch, need to convert from F to catch, back to F
        # get catch in numbers using the Baranov catch equation from advised F    
        
        if(stockName == 'codGOM'){
        CN_temp[y,] <- get_catch(F_full=F_full[y], M=natM[y],
                                 N=J1N[y,], selC=slxC[y,]) + 1e-3

        # Figure out the advised catch weight
        codCW[y,] <- CN_temp[y,] *  waa[y,]

        # add bias to catch weight
        codCW2[y,] <- sum(codCW[y,]) + (sum(codCW[y,]) * C_mult)

        # Determine what the fishing mortality would have to be to get
        # that biased catch level (convert biased catch back to F).
        # Update codGOM fully selected fishing mortality to that value.
        F_full[y] <- get_PopesF(yield = c(codCW2[y,]),
                                             naa = J1N[y,],
                                             waa = waa[y,],
                                             saa = slxC[y,],
                                             M = natM[y],
                                             ra = c(8))
        }
        
        # ST method using solver, either way works;
        # stock$codGOM$F_full[y] <- get_F(x = c(codCW2[y,]), 
        #                                    Nv = stock$codGOM$J1N[y,], 
        #                                    slxCv = stock$codGOM$slxC[y,], 
        #                                    M = stock$codGOM$natM[y,], 
        #                                    waav = stock$codGOM$waa[y,])
        
        
    }else{
      
      stop('get_implementationF: type not recognized')
      
    }

    
  })
  
}





