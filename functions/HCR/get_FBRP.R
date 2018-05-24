

# Function to calculate F-based reference points
# 
# type: type of reference point to calculate
#     
#     * YPR: yield-per-recruit-based reference point. See get_perRecruit.R.
#            Basically the parameters (par) are just the reference point 
#            level.
#     
#     * SPR: spawning potential ratio-based refence point. See 
#            get_perRecruit.R. Basically the parameters (par) are just the 
#            reference point level.
#            
#     * Mbased: natural mortality-based (data poor) option (see Gabriel and
#               Mace (1999), p.42. In some cases M or some factor of M has
#               been considered as a proxy for Fmsy.
#               
#               par[1]: the factor to multiply M by to get the Fmsy proxy
#     
# par: parameters needed (see type definitions above)
#       
# sel: vector of selectivity if necessary
#     
# waa: vector of weights-at-age if necessary
#     
# M: natural mortality scalar if necessary





get_FBRP <- function(parmgt, parpop){
  
  
  if(parmgt$FREF_TYP == 'YPR' | parmgt$FREF_TYP == 'SPR'){
   
    F <- get_perRecruit(parmgt = parmgt, parpop = parpop)
    
    return(Fref = F)
    
  }else if(parmgt$FREF_TYP == 'simR'){
    
    # stuff here
    
    return(Fref = F) 

  }else if(parmgt$FREF_TYP == 'Mbased'){
    
    F <- parmgt$FREF_VAL * mean(parpop$M)
    
    return(Fref = F)
    
  }else{
    
    stop('get_FBRP: parmgt FREF_TYP not recognized')
    
  }
  
  
}





