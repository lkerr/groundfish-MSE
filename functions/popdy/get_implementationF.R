

get_implementationF <- function(type, stock){

  within(stock, {
    
  
    if(type == 'adviceWithError'){
    
      if(y < nyear){
        # Borrowed error_idx function from survey function bank
        F_full[y+1] <- get_error_idx(type = ie_typ, 
                                     idx = F_fullAdvice[y+1], 
                                     par = ie_F)
      }
      
    }else if(type == 'sslm'){
      
      browser()


      stMatch <- sapply(1:length(names(stock)), 
                        function(i) startsWith(names(stock)[i], 
                                               prefix=names(sslm)))
      sapply(1:ncol(stMatch), function(i) which(stMatch[,i]))
      
      
      x <- c('codGBError', 'codGB2', 'haddockGB')
      y <- c('codGB', 'haddockGB')
      sapply(1:length(x), function(i) startsWith(x[i], prefix=y))
      
    }else{
      
      stop('get_implementationF: type not recognized')
      
    }

    
  })
  
}





