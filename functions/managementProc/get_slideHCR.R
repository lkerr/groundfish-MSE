#' @title Implement Slide HCR
#' @description Implement the "slide" HCR option. If SSBhat is less than the Bmsy reference point F is adjusted, otherwise F is set at Fmsy.
#' 
#' @inheritParams get_nextF
#' Only the last year in the parpop$SSBhat timeseries is used.
#' @param Fmsy A number for the Fmsy reference point or proxy
#' @param Bmsy A number for the Bmsy reference point or proxy
#' 
#' @return A number describing the F advice (i.e. the recommended target fishing mortality)
#' 
#' @family managementProcedure, regulations
#' 


# Function that returns fishing mortality advice based on the ramped control rule.
# 
# parpop: list containing population parameters. Must include named element
#         "B" which is a vector of biomass history. Only the last number
#         in the history is used, so could put in a vector of length 1. ??? I don't think parpop has "B" but it does have "SSBhat" ???
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
