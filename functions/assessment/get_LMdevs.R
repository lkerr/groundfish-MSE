

# function to get deviations from log-scale mean of a vector (i.e., 
# the same thing as a dev vector in admb). Returns a list including
# [[1]] the log-scale mean, and [[2]] the log-scale deviations.
# 
# x: the (arithmetic scale) vector you want deviations for


get_LMdevs <- function(x){
  
  lmean <- log(mean(x))
  lLMdevs <- log(x) - lmean
  
  return(list(lmean=lmean, lLMdevs=lLMdevs))

}


