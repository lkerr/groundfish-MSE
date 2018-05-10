

# The application of harvest control rules
#
# type: the type of HCR to apply. Options are:
# 
#      * "ns1": based on national standard 1 precautionary approach, this is
#               the classic harvest control rule that increases linearly and 
#               then reaches an asymptote at [Bmsy,Fmsy]
#        
#      * "simpleThresh": a simple threshold model where fishing is entirely
#                        cut off when the population is overfished 
#                        (i.e., B<Bmsy)

get_nextF <- function(type, par=NULL, Fmsy=NULL, Bmsy=NULL, M=NULL, SSB=NULL){
  
  
  if(tolower(type) == 'ns1'){
    
    F <- get_NS1HCR(SSB, Fmsy=Fmsy, Bmsy=Bmsy, M=M)$Fadvice.RPvalue
    
  }else if(tolower(type) == 'simplethresh'){
    
    if(length(par) != 1){
      stop('get_nextF: check length of parameter vector')
    }
    
    F <- ifelse(Bmsy < par, 0, Fmsy)
    
  }else{
    
    stop('get_nextF: type not recognized')
    
  }
  
  
}




