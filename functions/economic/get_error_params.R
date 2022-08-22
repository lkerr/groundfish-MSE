
# Function to return the mean and sdlog. This 'inverts' the get_implementationF() function for the 'adviceWwithError" model runs.
# Modified from MASS::densfun
# Didn't want to load a new library for one small function.
# I'm using ieF_hat to denote the sdlog, which is related to how different F_full is from the bias-adjusted F_fullAdvice
# I'm using iebias_hat to denote the point estimate of ie_b -- the average difference between F_fullAdvice and the F_full.


get_lognormal_error_params<-function(F_full, F_fullAdvice){
  x<-F_full/F_fullAdvice
  if (any(x <= 0)) 
    stop("need positive values to fit a log-Normal")
  
  n <- length(x)
  lx <- log(x)
  mx <- mean(lx)
  
  #ieF_hat is simply the sdlog term.
  ie_F_hat <- sqrt((n - 1)/n) * sd(lx)
  iebias_hat<-exp(mx)-1
  estimate <- c(mx, iebias_hat, ie_F_hat)
  names(estimate) <- c("meanlog", "iebias_hat", "ie_F_hat")
  return(estimate)
}



###########From get_implementation_F.R 
#   Borrowed error_idx function from survey function bank
#   Fimpl <- F_fullAdvice[y] + F_fullAdvice[y]*ie_bias
#   F_full[y] <- get_error_idx(type = ie_typ,
#                               idx = Fimpl,
#                               par = ie_F)

# From get_error_idx
#
#   idxE <- rlnorm(1, meanlog = log(idx), sdlog = par)
#
# iebias_hat is the estimate of ie_bias
# ie_F_hat is the estimate of ie_F

