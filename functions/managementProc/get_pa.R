


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

get_pa <- function(parpop, Fmsy, Bmsy, Blim){

  if(tail(parpop$SSBhat, 1) >= Bmsy){
    
    F <- Fmsy
    
  }else if(tail(parpop$SSBhat, 1) < Bmsy & tail(parpop$SSBhat, 1)>=Blim){
    
    F<-Fmsy*((tail(parpop$SSBhat, 1)-Blim)/((Bmsy)-Blim))
    
  }else if (tail(parpop$SSBhat,1)<Blim){
    
    F <- 0
    
  }
  
  return(c(Fadvice = unname(F)))
  
}



