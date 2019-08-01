

# Function to get the initial population. Determine a starting
# level and the function will return numbers-at-age assuming
# equilibrium conditions.  F and M are provided separately rather 
# than Z because the M should probably be the same as in the rest
# of the simulation. Varying this function should have no
# impact on the simulation results because a long enough burn in
# period would be used to nullify any initial effects.
#
#
# nage: number of ages in the simulation
# 
# N0: population numbers in the first age
# 
# F: value for fishing mortality
# 
# M: value for natural mortality (probably should be the same as in
#    the rest of the simulation)


get_init <- function(nage, N0, F_full, M){
  
  ivec <- N0 * exp((-F_full - M) * 0:(nage-1))

  return(ivec)
  
}




