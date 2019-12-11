

# Function to get the initial population. Determine a starting
# level and the function will return numbers-at-age assuming
# equilibrium conditions.  F and M are provided separately rather 
# than Z because the M should probably be the same as in the rest
# of the simulation. Varying this function should have no
# impact on the simulation results because a long enough burn in
# period would be used to nullify any initial effects.
#
# type: how to create initial numbers-at-age. Available options are
#
#     *'expDecline' calculated as N0 * exp((-F_full - M) * 0:(nage-1)) where:
#        par[nage]: number of ages in the simulation
#        par[N0]: population numbers in the first age
#        par[F]: value for fishing mortality
#        par[M]: value for natural mortality (probably should be the same as in
#        the rest of the simulation)
#
#     *'input' 
#        give a vector of initial numbers-at-age
#



get_init <- function(type, par){
  
  if(type == "expDecline"){
   
     ivec <- par['N0'] * exp((-par['F_full'] - par['M']) * 0:(par['nage']-1))
  
    }else if(type == "input"){
   
       ivec <- par
  
       }else{
    stop("get_init: incorrect type given")
       }
  
  return(ivec)
}



