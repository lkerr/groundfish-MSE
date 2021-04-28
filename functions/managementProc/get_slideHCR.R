


# Function that returns fishing mortality advice based on the ramped control rule.
# 
# parpop: list containing population parameters. Must include named element
#         "B" which is a vector of biomass history. Only the last number
#         in the history is used, so could put in a vector of length 1.
# 
# Fmsy: Fmsy reference point or proxy
# 
# Bmsy: Bmsy reference point or proxy
# 


get_slideHCR <- function(parpop, Fmsy, Bmsy){
  
  if(tail(parpop$SSBhat, 1) <= Bmsy){

    F <- Fmsy * tail(parpop$SSBhat, 1) / Bmsy
    
  }else{
    
    F <- Fmsy
    
  }
  
  return(c(Fadvice = unname(F)))
  
}



