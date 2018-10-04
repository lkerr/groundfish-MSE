

# Function to find fishing mortality given a catch biomass. Assumes known 
# numbers=at=age, selectivity-at-age, natural mortality and weight-at-age.
# True values are used here rather than any sort of estimates involving
# noise because all we're trying to do is to link a catch biomass to
# what would be the actual corresponding F so that we can embed the planB
# approach into the rest of the simulation.
# 
# 
# x: The true catch weight that you are trying to find the corresponding
#    F for
#    
# Nv: a true vector of numbers-at-age in the population
# 
# slxCv: a vector of the true selectivity-at-age in the population
# 
# M: the true natural mortality rate
# 
# waav: a vector of the true weight-at-age in the population



getF <- function(x, Nv, slxCv, M, waav){
  
  # Function to calculate the difference between the true catch weight (x)
  # and the catch weight calculated assuming a value of F.
  getCW <- function(logF){
    
    F <- exp(logF)
    
    # First calculate the components of the catch equation
    
    # Fraction of dead fish that come from fishing
    fracF <- slxCv * F / (slxCv * F + M)
    
    # Fraction of dead fish in the population
    fracDead <- 1 - exp(-slxCv * F - M)
    
    # Catch in weight by age
    CWaa <- fracF * fracDead * Nv * waav
    
    # Total catch
    CW <- sum(CWaa)
    
    # Calculate the difference from the total weight we are trying to
    # match
    diff <- abs(x - CW)
    
    return(diff)
    
  }
  
  opt <- try(optimize(getCW, interval=c(-10, 5)))
  
  return(exp(opt$minimum))
  
}


## Tested example

# Cw <- c(2.776505, 464.621177, 2288.239995, 2220.715640, 4277.889049,
#         31075.888506, 11507.953441, 12265.655066, 9278.169168, 3304.541189,
#         7818.299586, 3738.791000, 867.343440, 1118.935194, 3214.345814)
# 
# Nv <- c(7344188.4, 38412891.5, 26987284.4, 8301950.4, 8092755.3, 38442783.8,
#         10724560.8, 9362551.2, 6119036.1, 1952605.1, 4247294.4, 1903113.9,
#         419610.3, 520122.6, 1447733.4)
# 
# slxCv <- c(0.0299869, 0.1218750, 0.3165642, 0.5492346, 0.7258689, 0.8315518,
#            0.8905680, 0.9239824, 0.9437299, 0.9559780, 0.9639243, 0.9692845,
#            0.9730205, 0.9756957, 0.9776538)
# 
# M <- 0.1
# 
# waav <- c(6.162753e-05, 4.898678e-04, 1.349414e-03, 2.513996e-03, 3.828504e-03,
#           5.166565e-03, 6.442675e-03, 7.607385e-03, 8.637986e-03, 9.529590e-03,
#           1.028811e-02, 1.092526e-02, 1.145527e-02, 1.189286e-02, 1.225201e-02)
# 
# # The true F
# F <- 0.2156563
# 
# 
# Ftest <- getF(x = sum(Cw),
#               Nv = Nv,
#               slxCv = slxCv,
#               M = M,
#               waav = waav)
# 
# print(F)
# print(Ftest)

