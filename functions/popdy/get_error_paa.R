


# Function to return observation error for proportions-at-age
# 
# type: type of errors implemented
#       *"multinomial": multinomial errors. Output is divided by the
#        effective sample size so that the function returns proportions.
#       
# paa: matrix of proportions-at-age (rows are years and sum to 1.0)
# 
# par: observation error parameters
#      multinomial: rmultinom(n=1, size=ess, prob=paa) / par


get_error_paa <- function(type, paa, par){

  if(tolower(type) == 'multinomial'){
   
    paaE <- c(rmultinom(n=1, size=par, prob=paa)) / par
  
  }

  return(paaE)
  
}






