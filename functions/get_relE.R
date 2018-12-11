



# Function to report the relative error given an estimate and a true
# value
# 
# est: the estimated value (or vector of values)
# 
# true: thej true value (or vector of values)


get_relE <- function(est, true){
  
  out <- (est - true) / true
  
  return(out)
  
}
  
  
  
  


