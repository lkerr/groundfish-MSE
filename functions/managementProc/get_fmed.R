#' @title Double check this documentation 
#' @description 
#' 
#' @inheritParams get_FBRP
#' @param rep_slp ??? @seealso \code{\link{get_replacement}}
#' @param ssbrGrid A matrix of SSBR, @seealso \code{\link{get_perRecruit}}
#' 
#' @return A list containing F_star ???
#' 
#' @family managementProcedure, regulations
#' 

get_fmed <- function(parpop, 
                     rep_slp, 
                     ssbrGrid){
 
  # Take the inverse of the slope to get the desired replacement-level
  # SSBR
  ssbr_star <- 1 / rep_slp

  # Find the SSBR from the SSBR matrix
  F_star_ind <- which.min(abs(ssbrGrid[,2] - ssbr_star))
  F_star <- ssbrGrid[F_star_ind,1]

  # Print a warning if outside the sampled range of SSBRs
  if(F_star_ind == 1 | F_star_ind == nrow(ssbrGrid)){
    print('WARNING: SSBR outside sample range')
  }
  
  return(list(RPvalue=F_star))
}



