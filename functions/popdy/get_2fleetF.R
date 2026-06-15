

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



get_2fleetF <- function(x, Nv, slxCv,slxRv, M, waav){

  # Function to calculate the difference between the true catch weight (x)
  # and the catch weight calculated assuming a value of F.
  if(nfleet == 2){
    

    
    com.opt <- try(optim(par = c(-10, -10), get_2fleetCW, method = "L-BFGS-B",
                     lower = c(-10, -10), 
                     upper = c(5, 5), slxCv = slxCv ,slxRv =slxRv,
                        M = M, Nv = Nv, waav = waav, x = x))
    
    #rec.opt <- try(optim(par = c(-10, -10), get_2fleetCW, method = "L-BFGS-B",
                     #lower = c(-10, -10), 
                     #upper = c(5, 5), slxCv = slxCv ,slxRv =slxRv,
                     #M = M, Nv = Nv, waav = waav, comx = comx, recx = recx, type = "rec"))
   
    browser()
    return(exp(com.opt$value), exp(rec.opt$value))
    
  }else{
    
    opt <- try(optimize(getCW, interval=c(-10, 5),slxCv,M,Nv,waav,x))
    return(exp(opt$minimum))
    
  }
  
}


