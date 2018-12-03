

# Function to recreate random walk deviations on a log scale
# (e.g., for recruitment deviations so you know what the true
# values are in the assessment model if you've coded that as
# a random walk). Note that the returned vector will have
# length(x) - 1 elements.
# 
# x: the vector that you want the random walk from


get_RWdevs <- function(x){
  
  lRWdev <- numeric(length(x)-1)
  
  for(i in 2:length(x)){
    lRWdev[i-1] <- log(x[i] / x[i-1])
  }
  
  return(lRWdev)
  
}


