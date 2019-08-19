

# Function to get Bmsy assuming an Fmsy, recruitment history and level of
# natural mortality.
# 
# ny: number of years to run out the projection for
#
# Fmsy: Fmsy or some proxy -- this will be the constant level applied in
#       all years of the projections/simulations
#       
# R: A vector of recruitment histories.
# 
# Rfun: Function defining what to do with the recruitment histories. Any 
#       function will do here, and extra arguments can be included using
#       the (...). A common function will be sample(), with size=1 included
#       as an extra argument. That just means a random draw from the
#       recruitment history. You could also use mean() or mean() with
#       the trim=p argument in the ... if you wanted to apply the mean
#       recruitment or a trimmed mean recruitment to every year of the
#       projection/simulation. Another option would be to do something 
#       like use rlnorm() and then specify an sd.
#       
# sel: Vector of selectivity to apply to each of the age classes
# 
# init: Initial numbers-at-age
# 
# waa: vector of weights-at-age
# 
# mat: vector of maturity-at-age
# 
# M: The level of natural mortality to apply to each year of the
#    projection/simulation. Can be a scalar to apply the same rate to all
#    age classes or a vector to apply a different rate.
#         



get_BmsySim <- function(ny, Fmsy, R, Rfun, sel, init, waa, mat, M, ...){
  
  # Ensure that all vectors are the same length
  if(!all(length(sel) == length(init),
          length(sel) == length(waa))){
    stop('get_BmsySim: check vector lengths')
  }
  
  # If M is a vector, ensure it is the same length as the rest
  if(length(M) > 1){
    if(length(sel) != length(M)){
      stop('get_BmsySim: check vector lengths (M)')
    }
  }
  
  # number of ages in the model
  nage <- length(sel)
  
  # if M is not given as a vector, make it one
  if(length(M) == 1){
    M <- rep(M, nage)
  }
  
  # set up containers
  N <- matrix(0, nrow=ny, ncol=nage)
  
  
  # set up initial conditions
  N[1,] <- init
  
  for(y in 2:ny){
    
    for(a in 2:(nage-1)){
      # exponential survival to the next year/age
      N[y,a] <- N[y-1, a-1] * exp(-sel[a-1]*Fmsy - M[a-1])
    }
    
    # Deal with the plus group
    N[y,nage] <- N[y-1,nage-1] * exp(-sel[nage-1] * Fmsy - 
                                     M[nage-1]) + 
                 N[y-1,nage] * exp(-sel[nage] * Fmsy - 
                                   M[nage])
    
    # Recruitment
    N[y,1] <- Rfun(R, ...)
    
  }
  
  # Get weight-at-age
  Waa <- sweep(N, MARGIN=2, STATS=waa, FUN='*')
  
  # Get mature biomass-at-age
  SSBaa <- sweep(Waa, MARGIN=2, STATS=mat, FUN='*')
  
  # Find the total SSB / year
  SSB <- apply(SSBaa, 1, sum)
  
  return(SSB)
  
}



R <- rlnorm(30, meanlog=log(1000), sdlog=1.5)
sel <- c(seq(0, 1, length.out=5), rep(1, 3))
init <- dgamma(1:8/8, shape=0.9) * mean(R)/10
waa <- seq(1, 10, length.out=8)
mat <- seq(0, 1, length.out=8)



# Using random sample from R history
ssb1 <- get_BmsySim(ny = 1000, Fmsy = 0.25, R = R, 
                    Rfun = sample, size=1, 
                    sel = sel, init = init, waa = waa, 
                    mat = mat, M = 0.2)

# Using the mean recruitment
ssb2 <- get_BmsySim(ny = 1000, Fmsy = 0.25, R = R, 
                    Rfun = mean, 
                    sel = sel, init = init, waa = waa, 
                    mat = mat, M = 0.2)

yrg <- range(ssb1, ssb2)
# random sample
plot(tail(ssb1, 100), xlab='year', ylab='SSB', 
     ylim=yrg, type='l', col='red')

# mean
lines(tail(ssb2, 100), xlab='year', ylab='SSB')
legend('topright', lty=1, col=c('black', 'red'),
       legend=c('mean R', 'random sample R'), bty='n')

# plot the mean of the stochastic series
abline(h=mean(tail(ssb1, 100)), lty=3, lwd=2, col='red')

