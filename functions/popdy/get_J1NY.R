

# Function to determine numbers-at-age at the start of each year
# after recruitment has occurred.
# 
# J1Ny0: vector of numbers-at-age in year y-1
# 
# Zy0: vector of total mortality-at-age in year y-1
# 
# Ry1 recruitment in year y
# 
# devs: survival deviations on numbers-at-age transitions. Only used in historical period.

get_J1Ny <- function(J1Ny0, Zy0, Ry1, devs = 0){
  
  # calculate number of ages
  nage <- length(J1Ny0)
  if(length(devs == 1)){devs <- rep(devs, nage)}
  
  
  ## get the numbers-at-age for the specific year
  
  # loop through ages except recruit age and plus age
  J1Ny1 <- numeric(nage)
  for(a in 2:(nage-1)){
    J1Ny1[a] <- J1Ny0[a-1] * exp(-Zy0[a-1] + devs[a])
  }
  
  # deal with the plus group
  J1Ny1[nage] <- J1Ny0[nage-1] * exp(-Zy0[nage-1] + devs[nage]) + 
                 J1Ny0[nage] * exp(-Zy0[nage] + devs[nage])
  
  # add in recruitment (don't need to add naa deviations)
  J1Ny1[1] <- Ry1
   
  return(J1Ny1)
  
}






