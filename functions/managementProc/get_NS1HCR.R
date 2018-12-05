


# Function that returns fishing mortality advice based on the control rule 
# outlined in the Technical Guidance on the Use of Precautionary
# Approaches to Implementing National Standard 1 of the MSA (see Gabriel
# and Mace 1999, Proceedings, 5th NMFS NSAW
# 
# parpop: list containing population parameters. Must include named element
#         "B" which is a vector of biomass history. Only the last number
#         in the history is used, so could put in a vector of length 1.
# 
# Fmsy: Fmsy reference point or proxy
# 
# Bmsy: Bmsy reference point or proxy
# 


get_NS1HCR <- function(parpop, Fmsy, Bmsy){
  
  # c is defined as the maximum of 1-M or 1/2 (Gabriel and Mace 1999)
  c <- max(1 - tail(parpop$M, 1), 1/2)
  
  # If estimated biomass is under Bmsy then use the linear relationship
  # that goes through (Bmsy, Fmsy) and the origin; if estimated biomass
  # is above Bmsy then use Fmsy
  
  if(tail(parpop$SSBhat, 1) <= c*Bmsy){
    
    # See Gabriel and Mace "A review of biological reference points in the
    # contrxt of the prcautionary approach" p.40
    F <- Fmsy * tail(parpop$SSBhat, 1) / (c*Bmsy)
    
  }else{
    
    F <- Fmsy
    
  }
  
  return(c(Fadvice = unname(F)))
  
}



