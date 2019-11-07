



# Function to report the percent relative error given an estimate and a true
# value
# 
# est: the estimated value (or vector of values)
# 
# true: the true value (or vector of values)


get_relE <- function(est, true){
  
  out <- ((est - true) / true) *100
  
  return(out)
  
}
  
  
  
  


