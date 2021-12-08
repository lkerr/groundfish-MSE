#' @title Calculate Numbers-At-Age at Start of Year
#' @description Calculate numbers-at-age at the start of each year after recruitment has occurred.
#' 
#' @param J1Ny0 A vector of numbers-at-age in year y-1.
#' @param Zy0 A vector of total mortality-at-age in year y-1.
#' @param Ry1 Recruitment in year y
#' @param nage Number of ages in the model
#' 
#' @return A vector of numbers-at-age at the start of the year.
#' 
#' @family operatingModel, population
#' 
#' @export

get_J1Ny <- function(J1Ny0, 
                     Zy0, 
                     Ry1){
  
  # calculate number of ages
  nage <- length(J1Ny0)
  
  ## get the numbers-at-age for the specific year
  
  # loop through ages except recruit age and plus age
  J1Ny1 <- numeric(nage)
  for(a in 2:(nage-1)){
    J1Ny1[a] <- J1Ny0[a-1] * exp(-Zy0[a-1])
  }
  
  # deal with the plus group
  J1Ny1[nage] <- J1Ny0[nage-1] * exp(-Zy0[nage-1]) + 
                 J1Ny0[nage] * exp(-Zy0[nage])
  
  # add in recruitment
  J1Ny1[1] <- Ry1
   
  return(J1Ny1)
}
