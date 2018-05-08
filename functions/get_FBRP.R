

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





get_FBRP <- function(type, par, sel=NULL, waa=NULL, M=NULL){
  
  
  if(type == 'YPR'){
   
    F <- get_perRecruit(type = 'YPR', 
                        par = par, 
                        sel = sel, 
                        waa = waa, 
                        M = mean(M))
    
    return(Fref = F)

  }else if(type == 'SPR'){
    
    F <- get_perRecruit(type = 'SPR', 
                        par = par, 
                        sel = sel, 
                        waa = waa, 
                        M = mean(M))
    
    return(Fref = F)
    
  }else if(type == 'simR'){
    
    
    return(Fref = F) 

  }else if(type == 'Mbased'){
    
    F <- par[1] * mean(M)
    
  }
  
  
}





