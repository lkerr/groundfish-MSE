

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
#         
# # Important note: If you want to use only the last n years of the
# recruitment history, you can use something like
#     function(x) sample(tail(x, n), 1)
# as Rfun. But note that if you ever only wanted to apply this function
# to the very last year (i.e., n=1), sample will not work because,
# for example, sample(5, n=1) samples the vector 1:5 rather than the
# number 5. Probably you wouldn't really want to use the last year
# anyhow though (so I guess this note isn't so critically important!)



get_BmsySim <- function(parmgt, parpop, Rfun,
                        F_val, ny=1000, ...){

  init <- rep(1000, length(parpop$sel))
  
  # Ensure that all vectors are the same length
  if(!all(length(parpop$sel) == length(init),
          length(parpop$sel) == length(parpop$waa))){
    stop('get_BmsySim: check vector lengths')
  }
  
  # If M is a vector, ensure it is the same length as the rest
  if(length(parpop$M) > 1){
    if(length(parpop$sel) != length(parpop$M)){
      stop('get_BmsySim: check vector lengths (M)')
    }
  }
  
  # number of ages in the model
  nage <- length(parpop$sel)
  
  # if M is not given as a vector, make it one
  if(length(parpop$M) == 1){
    parpop$M <- rep(parpop$M, nage)
  }
  
  # set up containers
  N <- matrix(0, nrow=ny, ncol=nage)
  
  
  # set up initial conditions
  N[1,] <- init
  for(y in 2:ny){
    for(a in 2:(nage-1)){
      # exponential survival to the next year/age
      N[y,a] <- N[y-1, a-1] * exp(-parpop$sel[a-1]*F_val - 
                                    parpop$M[a-1])
    }
    
    # Deal with the plus group
    N[y,nage] <- N[y-1,nage-1] * exp(-parpop$sel[nage-1] * F_val - 
                                       parpop$M[nage-1]) + 
                 N[y-1,nage] * exp(-parpop$sel[nage] * F_val - 
                                     parpop$M[nage])
    
    # Recruitment
    N[y,1] <- Rfun(parpop$R)
    
  }
  
  # Get weight-at-age
  Waa <- sweep(N, MARGIN=2, STATS=parpop$waa, FUN='*')
  
  # Get mature biomass-at-age
  SSBaa <- sweep(Waa, MARGIN=2, STATS=parpop$mat, FUN='*')
  
  # Find the total SSB / year
  SSBref <- mean(apply(SSBaa, 1, sum)[100:nrow(SSBaa)])
 
  out <- list(RPlevel = parmgt$FREF_LEV,
              RPvalue = F_val,
              SSBvalue = SSBref)
  
  return(out)
  
}


# parpop <- list()
# parpop$R <- rlnorm(30, meanlog=log(1000), sdlog=1.5)
# parpop$M <- 0.2
# parpop$sel <- c(seq(0, 1, length.out=5), rep(1, 3))
# init <- dgamma(1:8/8, shape=0.9) * mean(parpop$R)/10
# parpop$waa <- seq(1, 10, length.out=8)
# parpop$mat <- seq(0, 1, length.out=8)
# 
# 
# 
# # Using random sample from R history
# ssb1 <- get_BmsySim(ny = 1000, Fmsy = 0.25, 
#                     Rfun = sample, size=1, 
#                     parpop=parpop, init=init)
# 
# # Using the mean recruitment
# ssb2 <- get_BmsySim(ny = 1000, Fmsy = 0.25, 
#                     Rfun = mean, 
#                     parpop=parpop, init=init)
# 
# # Using only the last 5 years
# ssb3 <- get_BmsySim(ny = 1000, Fmsy = 0.25, 
#                     Rfun = sample, size=1, 
#                     parpop=parpop, init=init)
# 
# 
# yrg <- range(ssb1, ssb2)
# # random sample
# plot(tail(ssb1, 100), xlab='year', ylab='SSB', 
#      ylim=yrg, type='l', col='red')
# 
# # mean
# lines(tail(ssb2, 100), xlab='year', ylab='SSB')
# legend('topright', lty=1, col=c('black', 'red'),
#        legend=c('mean R', 'random sample R'), bty='n')
# 
# # plot the mean of the stochastic series
# abline(h=mean(tail(ssb1, 100)), lty=3, lwd=2, col='red')
# 
# # plot the version using the last 5 years
# abline(h=mean(tail(ssb3, 100)), lty=3, col='cornflowerblue',
#        lwd=3)
