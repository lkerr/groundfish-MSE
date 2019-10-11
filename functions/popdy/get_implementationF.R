

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
      
    }else{
      
      stop('get_implementationF: type not recognized')
      
    }

    
  })
  
}





