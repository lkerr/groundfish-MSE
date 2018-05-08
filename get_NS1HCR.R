


# Function that returns fishing mortality advice based on the control rule 
# outlined in the Technical Guidance on the Use of Precautionary
# Approaches to Implementing National Standard 1 of the MSA (see Gabriel
# and Mace 1999, Proceedings, 5th NMFS NSAW
# 
# B: estimated biomass from assessment model
# 
# Fmsy: Fmsy reference point or proxy
# 
# Bmsy: Bmsy reference point or proxy
# 
# M: natural mortality

get_NS1HCR <- function(B, Fmsy, Bmsy, M){
  
  # c is defined as the maximum of 1-M or 1/2 (Gabriel and Mace 1999)
  c <- max(1-M, 1/2)
  
  # If estimated biomass is under Bmsy then use the linear relationship
  # that goes through (Bmsy, Fmsy) and the origin; if estimated biomass
  # is above Bmsy then use Fmsy
  if(B <= c*Bmsy){
    
    F <- Fmsy * B / (c*Bmsy)
    
  }else{
    
    F <- Fmsy
    
  }
  
  return(c(Fadvice = F))
  
}




