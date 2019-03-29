

# Function to help provide starting values for assessment model. x can be
# a vector to help with running this function on a list of starting
# values (for instance Rdevs). CV is given and sd is calculated from
# there. Truncated normal distribution is used to ensure that the
# starting values remain inside the parameter bounds.
# 
# x: either a number or a vector of "true" values that you want to
#    provide assessment model starting values for
# 
# cv: the cv for the starting value perturbation (normal scale). This
#     (along with the parameter bounds) governs how much deviation 
#     there will be in the assessment model starting value from the 
#     "true" operating model value.
#     
# lb: vector of the same length as x that gives the lower bounds for
#     the parameter estimates
# 
# ub: same as lb except for upper bounds.


get_svNoise <- function(x, cv, lb, ub){
  
  # add small constant to sd for the case where x = 0
  sd <- abs(cv * x)
  sd <- ifelse(sd != 0, sd, 1e-6)
  newsv <- sapply(1:length(x), function(i)
                                 rtnorm(n=1, mean=x[i], sd=sd[i], 
                                        lower=lb[i], upper=ub[i]))

  return(newsv)
  
}



