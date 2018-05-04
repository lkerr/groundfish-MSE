

get_YPR <- function(sel, waa, ref=0.1){
  
  F_full <- seq(0, 2, length.out = 1000)
  N <- 1
  ages <- 1:50
  sel <- c(sel, rep(tail(sel, 1), 50-length(sel)))
  waa <- c(waa, rep(tail(waa, 1), 50-length(waa)))
  
  Y <- numeric(length(F_full))
  for(i in seq_along(Y)){

    F <- sel * F_full[i]
    Z <- F + M
    Ct <- F*ages / (Z*ages) * N*exp(-Z*ages) * (1 - exp(-Z*ages))
    
    Y[i] <- Ct %*% waa
  }
 
  ## find F(x)
  # get all slopes
  slp <- sapply(2:length(Y), function(i){
                 (Y[i] - Y[i-1]) / (F_full[i] - F_full[i-1])})
  # slope at the origin
  slpo <- slp[1]
  
  # reference slope
  slpr <- ref * slpo
  
  # find the F @ reference slope
  Fref <- F_full[which.min(abs(slp - slpr))]
  
  # index for outputs
  oidx <- seq(1, length(Y), by=round(length(Y)/100))
  
  out <- list(YPR = matrix(c(F_full[oidx], Y[oidx]), ncol=2),
              Fref = Fref,
              ref = ref)
}





