

# Function to get Bmsy assuming an Fmsy, recruitment history and level of
# natural mortality.
# 
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function are the (1-row) columns
#         "FREF_TYP" and "FREF_LEV". FREF_TYP/FREF_LEV determine
#         how the Fmsy proxy is set (i.e., what the level of fishing
#         mortality will be during the projections).
# 
# parpop: named ist of population parameters (vectors) needed for the 
#         simulation including selectivity (sel), weight-at-age (waa),
#         recruitment (R), maturity (mat) and natural mortality (M).
#         Natural mortality can be a vector or a scalar. Vectors have
#         one value per age class.
# 
# Rfun: Function defining what to do with the recruitment histories. Any 
#       function will do here, and extra arguments can be included using
#       the (...). A common function will be sample(), with size=1 included
#       as an extra argument. That just means a random draw from the
#       recruitment history. You could also use mean() or mean() with
#       the trim=p argument in the ... if you wanted to apply the mean
#       recruitment or a trimmed mean recruitment to every year of the
#       projection/simulation. Another option would be to do something 
#       like use rlnorm() and then specify an sd. Or you could define a
#       trend in the recruitment history and use that.
#       
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


### ** note: initial numbers-at-age is assuming age-1 is the minimum right now. model ages should be
###          passed under parpop and the minimum should be used instead of 1.0.



get_BmsySim <- function(parmgt, parpop, Rfun,
                        F_val, ny=1000, ...){

  # Get the initial population for the simulation -- assumes exponential survival based
  # on the given F, mean recruitment and M
  ages <- 1:length(parpop$sel)
  meanR <- mean(parpop$R)
  init <- meanR * exp(-ages * F_val*parpop$sel - as.numeric(parpop$M))
  
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
  SSBref <- mean(apply(SSBaa, 1, sum)[(ny - floor(0.1*ny)):ny])
 
  out <- list(RPlevel = parmgt$FREF_LEV,
              RPvalue = F_val,
              SSBvalue = SSBref)
  
  return(out)
  
}


