get_f_from_advice <- function(advice, biomass, q, complex, docomplex=TRUE) {
  
  #library(lpSolve)
  # get the Fs by fleet given the catch advice
  # 2 fleet model
  
  #   #dummy inputs, comment out for application
  # advice <- c(8142,13495,4692)
  # complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2)
  # biomass <- c(2353.929 ,2485.127, 620.7602, 749.2529, 29301.07, 3359.718, 172096.6, 1625.388,39008.29, 608.7064)
  # if (!docomplex) advice <- biomass/10 #dummy, comment out for application
  # q <- matrix(c(1,0,0,1,1,1,1,1,1,1,
  #               0,1,1,0,0,0,0,0,0,0),
  #             nrow=2,byrow=TRUE)
  
  #maximize catch given the constraints
  
  #objective function is sum of FqB over fleets/species
  #q[1,]*biomass
  objective.fn <- c(sum(q[1,]*biomass), #sum(q*B) fleet 1
                    sum(q[2,]*biomass))
  
  if (docomplex) {
    #constraints (ABC by complex, and limit to SS exploitation)
    const.mat <- matrix(c(sum(q[1,complex==1]*biomass[complex==1]), sum(q[2,complex==1]*biomass[complex==1]),
                          sum(q[1,complex==2]*biomass[complex==2]), sum(q[2,complex==2]*biomass[complex==2]),
                          sum(q[1,complex==3]*biomass[complex==3]), sum(q[2,complex==3]*biomass[complex==3]),
                          c(q)),
                        ncol=2 , byrow=TRUE) 
    const.dir <- rep("<=", 13)  #direction of constraint (complex catches must be less than their ABCs)
    const.rhs <- c(advice,rep(0.99,10)) #the magnitude of the abc by complex and the limit on exploitation rate
  }
  if (!docomplex) {
    
    ##### if advcice is by single species
    #constraints (ABC by species, and limit to SS exploitation)
    const.mat <- rbind(cbind(q[1,]*biomass,q[2,]*biomass)
                       ,t(q))
    const.dir <- rep("<=", 20)  #direction of constraint (complex catches must be less than their ABCs)
    const.rhs <- c(advice,rep(0.99,10)) #the magnitude of the abc by complex and the limit on exploitation rate
  }
  
  #solve
  lp.solution <- lp("max", objective.fn, const.mat, 
                    const.dir, const.rhs, compute.sens=TRUE)
  #total expected realized catch
  lp.solution
  # solved exploitation rates by fleet
  lp.solution$solution
  f_use <- -1*log(1.-lp.solution$solution)
  
  return(f_use)
  
}

# 
# #testing
# docomplex = TRUE
# advice <- c(8142,13495,4692)
# complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2)
# biomass <- c(2353.929 ,2485.127, 620.7602, 749.2529, 29301.07, 3359.718, 172096.6, 1625.388,39008.29, 608.7064)
# if (!docomplex) advice <- biomass/10 
# q <- matrix(c(1,0,0,1,1,1,1,1,1,1,
#               0,1,1,0,0,0,0,0,0,0),
#             nrow=2,byrow=TRUE)
# new_f <- get_f_from_advice(advice, biomass, q, complex, docomplex)

