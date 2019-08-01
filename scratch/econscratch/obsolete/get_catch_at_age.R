# July 8, 2019- ML believes this is unnecessary because 
# (a) we don't need to run the model at the daily level
# (b) we are going to back-calculate F at the end of the fishing year and then feed it through the get_popStep function

# Equation to calculate catch-at-age based on available numbers, selectivity, and catch.   This is pretty much an inversion of the get_catch.R function.
# 
# INPUTS:
# catch (1x1): scalar of removals. catch and waa should be in the same units (kilograms) 
# N (1xK): vector of Numbers by age (after growth and recruitment)
# kilograms_at_age (1xK): vector of weights at age, in kilograms. 
# selC (1xK): vector of fishery selectivity by age

# Outputs
# caa (1xK): vector of catch-at-age.  
# scaleup is like a pseudo F-full. It ignores natural mortality rates. I don't think we want to report this.  

#Notes
# Ignoring natural mortality, we have
# kilograms_at_age \cdot caa = catch 
# caa = selC*F_full*N
#
# waa \cdot [ selC*F_full*N]=catch
# waa \cdot [ selC*N] * F_full=catch
# waa \cdot [selcC*N] 


get_catch_at_age <- function(catch_kg, N, kilograms_at_age,selC){
  
  oneu<-selC*N
  oneuW<-t(kilograms_at_age)%*% oneu
  scaleup<-catch_kg/oneuW
  caa<-scaleup %*% oneu
# Note, I tested doing this in one line. It's not faster
  
  return(caa)
}



#Note, I tested 





