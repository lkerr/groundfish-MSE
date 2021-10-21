#' @title Implement Tempslide HCR
#' @description Implement the "tempslide" HCR option based on the control rule outlined in the Technical Guidance on the Use of Precautionary Approaches to Implementing National Standard 1 of the MSA (see Gabriel and Mace 1999, Proceedings, 5th NMFS NSAW).
#' 
#' @inheritParams get_nextF
#' Only the last year in the parpop$SSBhat timeseries is used.
#' @param Fmsy A number for the Fmsy reference point or proxy
#' @param Bmsy A number for the Bmsy reference point or proxy
#' @param temp ??? Probably a vector of temperatures
#' 
#' @return A number describing the F advice (i.e. the recommended target fishing mortality)
#' 
#' @family managementProcedure, regulations
#' 

get_tempslideHCR <- function(parpop, 
                             Fmsy, 
                             Bmsy, 
                             temp){
  
  # c is defined as the maximum of 1-M or 1/2 (Gabriel and Mace 1999)
  c <- max(1 - tail(parpop$M, 1), 1/2)
  
  # If estimated biomass is under Bmsy then use the linear relationship
  # that goes through (Bmsy, Fmsy) and the origin; if estimated biomass
  # is above Bmsy then use Fmsy
  tempeffect<-exp(parpop$Rpar[['g']]*temp)
  
  if(tail(parpop$SSBhat, 1) <= c*Bmsy){
    
    # See Gabriel and Mace "A review of biological reference points in the
    # contrxt of the prcautionary approach" p.40
  
  if (tempeffect<(2/3)){
    F <- ((2/3)*Fmsy) * tail(parpop$SSBhat, 1) / (c*Bmsy)
  }
  else if (tempeffect>(2/3) & tempeffect<(4/3)){
    F <- (tempeffect*Fmsy) * tail(parpop$SSBhat, 1) / (c*Bmsy)
  }
  else if (tempeffect>(4/3)){
    F <- ((4/3)*Fmsy) * tail(parpop$SSBhat, 1) / (c*Bmsy)
  }
    
  }else{
    if (tempeffect<(2/3)){
      F <- (2/3)*Fmsy
    }
    else if (tempeffect>(2/3) & tempeffect<(4/3)){
      F <- tempeffect*Fmsy
    }
    else if (tempeffect>(4/3)){
      F <- (4/3)*Fmsy
    }
  }
  
  return(c(Fadvice = unname(F)))
  
}


