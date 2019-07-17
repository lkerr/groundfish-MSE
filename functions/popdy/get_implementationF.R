

get_implementationF <- function(type, stock){

  within(stock, {
    if(type == 'advicenoError'){

      F_full[y]<- F_fullAdvice[y]
      
    } else if(type == 'adviceWithError'){

        # Borrowed error_idx function from survey function bank
        F_full[y] <- get_error_idx(type = ie_typ, 
                                   idx = F_fullAdvice[y], 
                                   par = ie_F)
      
      
    }else{
      
      stop('get_implementationF: type not recognized')
      
    }

    
  })
  
}





