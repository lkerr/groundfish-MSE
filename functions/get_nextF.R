

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

get_nextF <- function(parmgt, parpop){
  
  
  if(tolower(parmgt$HCR) == 'ns1'){
    
    # For NS1 need F reference points and B reference points
    Fref <- get_FBRP(parmgt = parmgt, parpop = parpop)
    Bref <- get_FBRP(parmgt = parmgt, parpop = parpop)
 
    F <- get_NS1HCR(parpop, Fmsy=Fref$RPlevel, Bmsy=Bref$RPlevel)['Fadvice']
    
  }else if(tolower(parmgt$HCR) == 'simplethresh'){
    
    F <- ifelse(Bmsy < parmgt$BREF_VAL, 0, Fmsy)
    
  }else{
    
    stop('get_nextF: type not recognized')
    
  }
  
  
}




