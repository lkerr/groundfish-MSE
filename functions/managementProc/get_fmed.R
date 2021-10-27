#Function to get Fmed reference point
get_fmed <- function(parpop, rep_slp, ssbrGrid){
 
  # take the inverse of the slope to get the desired replacement-level
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



