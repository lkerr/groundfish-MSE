

get_FRP <- function(type, par, sel=NULL, waa=NULL, M=NULL){
  
  
  if(type == 'YPR'){
   
    F <- get_perRecruit(type = 'YPR', 
                        par = par, 
                        sel = sel, 
                        waa = waa, 
                        M = M)
    
    return(Fref = F)

  }else if(type == 'SPR'){
    
    F <- get_perRecruit(type = 'SPR', 
                        par = par, 
                        sel = sel, 
                        waa = waa, 
                        M = M)
    
    return(Fref = F)
    
  }else if(type == 'simR'){
    
    
    return(Fref = F) 
  }
  
  
  
}





