

get_implementationF <- function(type, stock){

  within(stock, {
    
  
    if(type == 'adviceWithError'){
    
      if(y < nyear){
        # Borrowed error_idx function from survey function bank
        F_full[y+1] <- get_error_idx(type = ie_typ, 
                                   idx = F_fullAdvice[y+1], 
                                   par = ie_F)
      }
      
    }else if(type == 'econModel'){
      
      
    }else{
      
      stop('get_implementationF: type not recognized')
      
    }

    
  })
  
}





